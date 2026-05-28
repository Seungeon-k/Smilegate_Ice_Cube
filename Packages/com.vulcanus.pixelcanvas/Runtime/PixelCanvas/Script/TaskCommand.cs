using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using Unity.Mathematics;
using UnityEngine;
using System.Diagnostics;
using System.Collections;

#if UNITY_EDITOR
using UnityEditor;
#endif

namespace PixelCanvas
{
    public enum ERedoUndo
    {
        Undo,
        Redo,
    }

    public enum ECanvasType
    {
        None,
        Albedo,
        Uber,
    }

    public struct ModifiedRect
    {
        public uint2 begin;
        public uint2 end;

        public ModifiedRect(uint2 begin, uint2 end)
        {
            this.begin = begin;
            this.end = end;
        }

        public bool IsValid()
        {
            if (end.x < begin.x)
                return false;
            if (end.y < begin.y)
                return false;
            return true;
        }
    }

    public class Deque<T> : IEnumerable<T>
    {
        private LinkedList<T> _data = new LinkedList<T>();

        public IEnumerator<T> GetEnumerator() => _data.GetEnumerator();

        IEnumerator IEnumerable.GetEnumerator() => _data.GetEnumerator();

        public void Clear() => _data.Clear();

        public int Count => _data.Count;

        public void Push(T data)
        {
            _data.AddLast(data);
        }

        public bool TryPop(out T data)
        {
            data = default;
            if (_data.Count == 0)
                return false;

            data = _data.Last.Value;
            _data.RemoveLast();
            return true;
        }

        public bool TryDequeue(out T data)
        {
            data = default;
            if (_data.Count == 0)
                return false;

            data = _data.First.Value;
            _data.RemoveFirst();
            return true;
        }
    }

    public class TaskCommandController
    {
        private Deque<TaskCommand> _commands = new Deque<TaskCommand>();
        private Deque<TaskCommand> _redoCommands = new Deque<TaskCommand>();

		private static int3 _threadGroupsDimension;
		private static ComputeBuffer _modifiedRectComputeBuffer;
        private static ModifiedRect[] _modifiedRectData;

        private const int maximumTaskCount = 300;

        public void Initialize(RenderTexture seedTexture)
        {
            Release();

            var elementCount = seedTexture.width * seedTexture.height;
            var rectSize = Marshal.SizeOf<ModifiedRect>();

            //unsafe
            //{
                //rectSize = sizeof(ModifiedRect);
            //}

            var modifiedRegionShader = ResourceManager.Instance.DiffRegionShader;
			var kernelIndex = modifiedRegionShader.FindKernel("CSCalculateModifiedRegion");
			modifiedRegionShader.GetKernelThreadGroupSizes(kernelIndex, out var numX, out var numY, out var numZ);
			_threadGroupsDimension = (int3)math.ceil(new float3(seedTexture.width, seedTexture.height, 1) / new float3(numX, numY, numZ));
			var nThreadGroup = _threadGroupsDimension.x * _threadGroupsDimension.y * _threadGroupsDimension.z;
			_modifiedRectComputeBuffer = new ComputeBuffer(nThreadGroup, rectSize);
            _modifiedRectData = new ModifiedRect[nThreadGroup];
        }

		public void Release()
		{
            foreach (var taskCommand in _commands)
                taskCommand.Dispose();
            _commands.Clear();

            foreach (var taskCommand in _redoCommands)
                taskCommand.Dispose();
            _redoCommands.Clear();

            if (_modifiedRectComputeBuffer != null)
                _modifiedRectComputeBuffer.Dispose();
            _modifiedRectComputeBuffer = null;

            EventManager.Notify(EPixelArtEventID.OnTaskCommandModified, _commands.Count, _redoCommands.Count);
            UpdateMonitor_DEBUG();
        }

        public void AddCommand(TaskCommand command)
        {
            //Checking whether Command is valid or not.
            if (command.Execute() == false)
                return;
             
            //Restrict Command Count
            _commands.Push(command);
            if (maximumTaskCount < _commands.Count)
                _commands.TryDequeue(out var _);

            foreach (var redoCommand in _redoCommands)
                redoCommand.Dispose();
            _redoCommands.Clear();

            EventManager.Notify(EPixelArtEventID.OnTaskCommandModified, _commands.Count, _redoCommands.Count);
            UpdateMonitor_DEBUG();
        }

        public static (Texture2D, uint2) CheckModification()
        {
            var seedTextureSize = new uint2((uint)ResourceManager.Instance.SeedTarget.width, (uint)ResourceManager.Instance.SeedTarget.height);
            ResourceManager.Instance.ColorDiffMaterial.SetTexture("_SourceTex", ResourceManager.Instance.MergedTarget);
            Graphics.Blit(ResourceManager.Instance.SeedTarget, ResourceManager.Instance.ColorDiffTarget, ResourceManager.Instance.ColorDiffMaterial, 0);

            var nThreadGroup = _threadGroupsDimension.x * _threadGroupsDimension.y * _threadGroupsDimension.z;
            for (var i = 0; i < nThreadGroup; ++i)
            {
                _modifiedRectData[i].begin = new uint2(seedTextureSize.x, seedTextureSize.y);
                _modifiedRectData[i].end = new uint2(0, 0);
            }
            _modifiedRectComputeBuffer.SetData(_modifiedRectData);

            var modifiedRegionShader = ResourceManager.Instance.DiffRegionShader;
            var kernelIndex = modifiedRegionShader.FindKernel("CSCalculateModifiedRegion");

            modifiedRegionShader.GetKernelThreadGroupSizes(kernelIndex, out var numX, out var numY, out var numZ);
            var nThreadGroups = (int3)math.ceil(new float3(seedTextureSize.x, seedTextureSize.y, 1) / new float3(numX, numY, numZ));

            modifiedRegionShader.SetVector(Shader.PropertyToID("groupDimension"), new Vector4(nThreadGroups.x, nThreadGroups.y, nThreadGroups.z, 0));
            modifiedRegionShader.SetTexture(kernelIndex, Shader.PropertyToID("mergedTexture"), ResourceManager.Instance.MergedTarget);
            modifiedRegionShader.SetTexture(kernelIndex, Shader.PropertyToID("colorDiffTexture"), ResourceManager.Instance.ColorDiffTarget);
            modifiedRegionShader.SetBuffer(kernelIndex, "modifiedRectBuffer", _modifiedRectComputeBuffer);

            var beg = default(uint2);
            var end = default(uint2);
            //using (var nanoTimer = new NanoTimer("Compute Shader"))
            {
                //Execute Compute Shader
                modifiedRegionShader.Dispatch(kernelIndex, nThreadGroups.x, nThreadGroups.y, nThreadGroups.z);

                _modifiedRectComputeBuffer.GetData(_modifiedRectData);
                beg = _modifiedRectData[0].begin;
                end = _modifiedRectData[0].end;
                for (var i = 0; i < _modifiedRectData.Length; ++i)
                {
                    beg = new uint2(Math.Min(beg.x, _modifiedRectData[i].begin.x), Math.Min(beg.y, _modifiedRectData[i].begin.y));
                    end = new uint2(Math.Max(end.x, _modifiedRectData[i].end.x), Math.Max(end.y, _modifiedRectData[i].end.y));
                }
            }

            var rect = new ModifiedRect(beg, end);
            var modifiedData = default(Texture2D);
            if (rect.IsValid() == true)
            {
                var width = (int)(end.x - beg.x + 1);
                var height = (int)(end.y - beg.y + 1);
                modifiedData = new Texture2D(width, height, TextureFormat.RGBAFloat, false, true);
                modifiedData.filterMode = FilterMode.Point;
                RenderTexture.active = ResourceManager.Instance.ColorDiffTarget;
                modifiedData.ReadPixels(new Rect(beg.x, beg.y, width, height), 0, 0, false);
                RenderTexture.active = null;
                modifiedData.Apply();
            }
            return (modifiedData, rect.begin);
        }

        public bool ExecuteRedoUndo(ERedoUndo redoUndo)
        {
            if (redoUndo == ERedoUndo.Undo)
            {
                if (_commands.TryPop(out var command) == false)
                    return false;
                command.Undo();
                _redoCommands.Push(command);
            }
            else
            {
                if (_redoCommands.TryPop(out var command) == false)
                    return false;
                command.Redo();
                _commands.Push(command);
            }

            EventManager.Notify(EPixelArtEventID.OnTaskCommandModified, _commands.Count, _redoCommands.Count);
            UpdateMonitor_DEBUG();
            return true;
        }

        [ConditionalAttribute("UNITY_EDITOR")]
        private void UpdateMonitor_DEBUG()
        {
            EventManager.Notify(EPixelArtEventID.OnTaskCommandUpdate, _commands, _redoCommands);
        }
    }

    public abstract class TaskCommand
    {
        public abstract void Dispose();
        public abstract bool Execute();
        public abstract void Undo();
        public abstract void Redo();
    }

    public class ColorChangeCommand : TaskCommand
    {
        private Texture2D _modifiedData;
        private uint2 _nUVOffset;
        private ECanvasType _canvasType;

        public ColorChangeCommand(ECanvasType canvasType)
        {
            _canvasType = canvasType;
        }

        public override void Dispose() => GameObject.DestroyImmediate(_modifiedData);

        public override bool Execute() 
        {
            //Generate Undo Redo Data
            (_modifiedData, _nUVOffset) = TaskCommandController.CheckModification();
            if (_modifiedData == null)
            {
                Graphics.Blit(Texture2D.blackTexture, ResourceManager.Instance.DrawingLayerTarget);
                return false;
            }
            else
            {
                //Apply Drawing Layer To Seed Texture
                Graphics.Blit(ResourceManager.Instance.MergedTarget, ResourceManager.Instance.SeedTarget);
                Graphics.Blit(Texture2D.blackTexture, ResourceManager.Instance.DrawingLayerTarget);

                //For Color Spoid Performance
                ResourceManager.Instance.SeedTarget.CopyTo(ResourceManager.Instance.SeedTexture);
                return true;
            }
		}

        public override void Undo() 
        {
			if (_modifiedData == null)
				return;
            var undoredoMaterial = ResourceManager.Instance.UndoRedoMaterial;
            undoredoMaterial.SetVector("_Params", new float4(_nUVOffset, _modifiedData.width, _modifiedData.height));
            undoredoMaterial.SetInteger("_Sign", 1);
            Graphics.Blit(_modifiedData, ResourceManager.Instance.SeedTarget, undoredoMaterial, 0);
            Graphics.Blit(_modifiedData, ResourceManager.Instance.SeedTarget, undoredoMaterial, 1);
            ResourceManager.Instance.SeedTarget.CopyTo(ResourceManager.Instance.SeedTexture);
        }

        public override void Redo() 
        {
			if (_modifiedData == null)
				return;	
			var undoredoMaterial = ResourceManager.Instance.UndoRedoMaterial;
            undoredoMaterial.SetVector("_Params", new float4(_nUVOffset, _modifiedData.width, _modifiedData.height));
            undoredoMaterial.SetInteger("_Sign", -1);
            Graphics.Blit(_modifiedData, ResourceManager.Instance.SeedTarget, undoredoMaterial, 0);
            Graphics.Blit(_modifiedData, ResourceManager.Instance.SeedTarget, undoredoMaterial, 1);
            ResourceManager.Instance.SeedTarget.CopyTo(ResourceManager.Instance.SeedTexture);
        }
    }

    public class BrushCommand : ColorChangeCommand
    {
        public BrushCommand(ECanvasType canvasType) : base(canvasType) {}

        public override bool Execute()
        {
            return base.Execute();
        }
    }

    public class PaintCommand : ColorChangeCommand
    {
        private int2 _paintNUV;
		private RectInt _partition;
        private Color _paintColor;
        private float _colorThreashold;
        private bool _xMirror;

        public PaintCommand(ECanvasType canvasType, int2 nUV, RectInt partition, Color paintColor, float colorThreashold, bool xMirror) : base(canvasType)
        {
            _paintNUV = nUV;
			_partition = partition;
			_paintColor = paintColor;
            _colorThreashold = colorThreashold;
            _xMirror = xMirror;
        }

        public override void Dispose() {}

        public override bool Execute()
        {
            var textureSize = new int2(ResourceManager.Instance.SeedTarget.width, ResourceManager.Instance.SeedTarget.height);
            var mergedTexture = new Texture2D(textureSize.x, textureSize.y, TextureFormat.ARGB32, false);
            RenderTexture.active = ResourceManager.Instance.SeedTarget;
            mergedTexture.ReadPixels(new Rect(0, 0, textureSize.x, textureSize.y), 0, 0);
            RenderTexture.active = null;

            var targetColor = mergedTexture.GetPixel(_paintNUV.x, _paintNUV.y);
            var pixels = mergedTexture.GetPixels();
            FloodFill_NonRecursive(pixels, _paintNUV, _partition, targetColor, _paintColor, _colorThreashold);
            if (_xMirror == true)
            {
                var paintNUV = _paintNUV;
                var xPartitionLength = (int)(_partition.xMax - _partition.xMin);
                paintNUV.x = (int)_partition.xMax - paintNUV.x + (int)_partition.xMin - 1;
                targetColor = mergedTexture.GetPixel(paintNUV.x, paintNUV.y);
                FloodFill_NonRecursive(pixels, paintNUV, _partition, targetColor, _paintColor, _colorThreashold);
            }

            mergedTexture.SetPixels(pixels);
            mergedTexture.Apply();
            Graphics.Blit(mergedTexture, ResourceManager.Instance.MergedTarget);
            Graphics.Blit(mergedTexture, ResourceManager.Instance.DrawingLayerTarget);
            GameObject.DestroyImmediate(mergedTexture);

            return base.Execute();

            void FloodFill_NonRecursive(Color[] colors, int2 nUV, RectInt partition, Color targetColor, Color paintColor, float colorThreashold = 0)
            {
                var maxCount = 0;

                var validCoordinate = new Queue<int2>();
                validCoordinate.Enqueue(nUV);
                while (0 < validCoordinate.Count)
                {
                    var coord = validCoordinate.Dequeue();
                    if (IsValidCoord(partition, coord) == true)
                    {
                        colors[GetIndex(coord)] = paintColor;
                    }

                    var tempCoord = coord + new int2(-1, 0);
                    if (IsValid(colors, partition, tempCoord, targetColor, paintColor, colorThreashold) == true)
                    {
                        colors[GetIndex(tempCoord)] = paintColor;
                        validCoordinate.Enqueue(tempCoord);
                    }
                    tempCoord = coord + new int2(0, 1);
                    if (IsValid(colors, partition, tempCoord, targetColor, paintColor, colorThreashold) == true)
                    {
                        colors[GetIndex(tempCoord)] = paintColor;
                        validCoordinate.Enqueue(tempCoord);
                    }
                    tempCoord = coord + new int2(1, 0);
                    if (IsValid(colors, partition, tempCoord, targetColor, paintColor, colorThreashold) == true)
                    {
                        colors[GetIndex(tempCoord)] = paintColor;
                        validCoordinate.Enqueue(tempCoord);
                    }
                    tempCoord = coord + new int2(0, -1);
                    if (IsValid(colors, partition, tempCoord, targetColor, paintColor, colorThreashold) == true)
                    {
                        colors[GetIndex(tempCoord)] = paintColor;
                        validCoordinate.Enqueue(tempCoord);
                    }
                    maxCount = math.max(maxCount, validCoordinate.Count);
                }
            }

            bool IsValidCoord(RectInt partition, int2 nUV)
            {
                var min = partition.min;
                var max = partition.max;

                if (nUV.x < min.x || max.x <= nUV.x)
                    return false;
                if (nUV.y < min.y || max.y <= nUV.y)
                    return false;
                return true;
            }

            bool IsValid(Color[] colors, RectInt partition, int2 nUV, Color targetColor, Color paintColor, float colorThreashold = 0)
            {
                if (IsValidCoord(partition, nUV) == false)
                    return false;

                var index = GetIndex(nUV);
                if (colors[index] == paintColor)
                    return false;
                if (colors[index] != targetColor && colorThreashold + 0.01f < targetColor.Distance(colors[index]))
                    return false;
                //if (colors[index] != targetColor)
                //    return false;
                    
                return true;
            }

            int GetIndex(int2 uv)
            {
                return (uv.y * textureSize.x) + uv.x;
            }
        }
    }

    public class ClearCommand : ColorChangeCommand
    {
        private Texture2D _snapshot;

        public ClearCommand(ECanvasType canvasType) : base(canvasType) {}

        public override void Dispose() 
        {
            GameObject.DestroyImmediate(_snapshot);
        }

        public override bool Execute()
        {
            return true;
            //_snapshot = targetTexture.Clone(TextureFormat.RGB24);

            ////RenderTexture rt;
            ////var currenttexture = new Texture2D(1, 1, TextureFormat.RGB24, false, true);
            ////RenderTexture.active = rt;
            ////currenttexture.ReadPixels(new Rect(0, 0, 1, 1), xOff, yOff, 0, 0, false);
            ////RenderTexture.active = null;

            //for (var y = 0; y < targetTexture.height; ++y)
            //{
            //    for (var x = 0; x < targetTexture.width; ++x)
            //    {
            //        targetTexture.SetPixel(x, y, Color.white);
            //    }
            //}
            //targetTexture.Apply();
        }
    }

    public class MarqueeActivationCommand : TaskCommand
    {
        private RectInt _regionRect;

        public MarqueeActivationCommand(RectInt selectedRegionRect)
        {
            _regionRect = selectedRegionRect;
        }

        public override void Dispose() {}

        public override bool Execute() => true;

        public override void Undo()
        {
            EventManager.Notify(EPixelArtEventID.ChangePaintBoardType, EPaintBoardType.PaintBoard2D);
            EventManager.Notify(EPixelArtEventID.OnRedoUndoMarqueeActivationCommand, ERedoUndo.Undo, _regionRect);
        }

        public override void Redo()
        {
            EventManager.Notify(EPixelArtEventID.ChangePaintBoardType, EPaintBoardType.PaintBoard2D);
            EventManager.Notify(EPixelArtEventID.OnRedoUndoMarqueeActivationCommand, ERedoUndo.Redo, _regionRect);
        }
    }

    public class MarqueeCutCommand : ColorChangeCommand
    {
        private RectInt _originRegionRect;
        private RectInt _regionRect;

        public MarqueeCutCommand(ECanvasType canvasType, RectInt originRegionRect, RectInt selectedRegionRect) : base(canvasType)
        {
            _originRegionRect = originRegionRect;
            _regionRect = selectedRegionRect;
        }

        public override bool Execute()
        {
            base.Execute();

            //Force true Flag, for Marquee Activation on non-Modified Case.
            return true;
        }

        public override void Undo()
        {
            base.Undo();
            EventManager.Notify(EPixelArtEventID.ChangePaintBoardType, EPaintBoardType.PaintBoard2D);
            EventManager.Notify(EPixelArtEventID.OnRedoUndoMarqueeInactivationCommand, ERedoUndo.Undo, _originRegionRect, _regionRect);
        }

        public override void Redo()
        {
            base.Redo();
            EventManager.Notify(EPixelArtEventID.ChangePaintBoardType, EPaintBoardType.PaintBoard2D);
            EventManager.Notify(EPixelArtEventID.OnRedoUndoMarqueeInactivationCommand, ERedoUndo.Redo, _originRegionRect, _regionRect);
        }
    }

    public class MarqueeInactivationCommand : ColorChangeCommand
    {
        private RectInt _originRegionRect;
        private RectInt _regionRect;

        public MarqueeInactivationCommand(ECanvasType canvasType, RectInt originRegionRect, RectInt selectedRegionRect) : base(canvasType)
        {
            _originRegionRect = originRegionRect;
            _regionRect = selectedRegionRect;
        }

        public override bool Execute()
        {
            base.Execute();

            //Force true Flag, for Marquee Activation on non-Modified Case.
            return true;
        }

        public override void Undo()
        {
            EventManager.Notify(EPixelArtEventID.ChangePaintBoardType, EPaintBoardType.PaintBoard2D);
            EventManager.Notify(EPixelArtEventID.ChangePartitionByIndex, 0);
            EventManager.Notify(EPixelArtEventID.OnRedoUndoMarqueeInactivationCommand, ERedoUndo.Undo, _originRegionRect, _regionRect);
            base.Undo();
        }

        public override void Redo()
        {
            base.Redo();
            EventManager.Notify(EPixelArtEventID.ChangePaintBoardType, EPaintBoardType.PaintBoard2D);
            EventManager.Notify(EPixelArtEventID.ChangePartitionByIndex, 0);
            EventManager.Notify(EPixelArtEventID.OnRedoUndoMarqueeInactivationCommand, ERedoUndo.Redo, _originRegionRect, _regionRect);
        }
    }

    public class MarqueeReallocateCommand : TaskCommand
    {
        private int2 _minModification;
        private int2 _maxModification;

        public MarqueeReallocateCommand(int2 minModification, int2 maxModification)
        {
            _minModification = minModification;
            _maxModification = maxModification;
        }

        public override void Dispose() {}

        public override bool Execute()
        {
            return true;
        }

        public override void Undo()
        {
            EventManager.Notify(EPixelArtEventID.ChangePaintBoardType, EPaintBoardType.PaintBoard2D);
            EventManager.Notify(EPixelArtEventID.ChangePartitionByIndex, 0);
            EventManager.Notify(EPixelArtEventID.OnUndoRedoMarqueeReallocateCommand, ERedoUndo.Undo, _minModification, _maxModification);
        }

        public override void Redo()
        {
            EventManager.Notify(EPixelArtEventID.ChangePaintBoardType, EPaintBoardType.PaintBoard2D);
            EventManager.Notify(EPixelArtEventID.ChangePartitionByIndex, 0);
            EventManager.Notify(EPixelArtEventID.OnUndoRedoMarqueeReallocateCommand, ERedoUndo.Redo, _minModification, _maxModification);
        }
    }

    public class MarqueeTranslateCommand : TaskCommand
    {
        private float2 _draggedDelta;

        public MarqueeTranslateCommand(float2 draggedDelta)
        {
            _draggedDelta = draggedDelta;
        }

        public override void Dispose() {}

        public override bool Execute()
        {
            return true;
        }

        public override void Undo()
        {
            EventManager.Notify(EPixelArtEventID.ChangePaintBoardType, EPaintBoardType.PaintBoard2D);
            EventManager.Notify(EPixelArtEventID.ChangePartitionByIndex, 0);
            EventManager.Notify(EPixelArtEventID.OnUndoRedoMarqueeTranslateCommand, ERedoUndo.Undo, _draggedDelta);
        }

        public override void Redo()
        {
            EventManager.Notify(EPixelArtEventID.ChangePaintBoardType, EPaintBoardType.PaintBoard2D);
            EventManager.Notify(EPixelArtEventID.ChangePartitionByIndex, 0);
            EventManager.Notify(EPixelArtEventID.OnUndoRedoMarqueeTranslateCommand, ERedoUndo.Redo, _draggedDelta);
        }
    }

    //public class MarqueeTranslateCommand : ColorChangeCommand
    //{
    //    private float2 _draggedDelta;

    //    public MarqueeTranslateCommand(float2 draggedDelta)
    //    {
    //        _draggedDelta = draggedDelta;
    //    }

    //    public override bool Execute()
    //    {
    //        base.Execute();

    //        return true;
    //    }

    //    public override void Undo()
    //    {
    //        base.Undo();
    //        EventManager.Notify(EPixelArtEventID.ChangePaintBoardType, EPaintBoardType.PaintBoard2D);
    //        EventManager.Notify(EPixelArtEventID.OnUndoRedoMarqueeTranslateCommand, ERedoUndo.Undo, _draggedDelta);
    //    }

    //    public override void Redo()
    //    {
    //        base.Redo();
    //        EventManager.Notify(EPixelArtEventID.ChangePaintBoardType, EPaintBoardType.PaintBoard2D);
    //        EventManager.Notify(EPixelArtEventID.OnUndoRedoMarqueeTranslateCommand, ERedoUndo.Redo, _draggedDelta);
    //    }
    //}
}