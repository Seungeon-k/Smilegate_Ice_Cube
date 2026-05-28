using System;
using System.Collections.Generic;
using UnityEngine;

#if UNITY_EDITOR
#endif

namespace PixelCanvas
{
    public enum EPixelArtEventID
    {
		/// <summary>
		/// [0]Vector2Int : Screen Size
		/// </summary>
		OnScreenSizeChanged,

        /// <summary>
        /// [0] : EPaintBoardType
        /// </summary>
        ChangePaintBoardType,

        /// <summary>
        /// [0] : EPaintBoardType
        /// </summary>
        OnPaintBoardTypeChanged,

        /// <summary>
        /// [0] Stack<TaskCommand> : Tasks
        /// [1] Stack<TaskCommand> : redoTasks
        /// </summary>
        OnTaskCommandUpdate,

        /// <summary>
        /// [0] : TaskCommand
        /// </summary>
        AddTaskCommand,

        /// <summary>
        /// <para>[0] int : Command Count Flag</para>
        /// <para>[1] int : Redo Command Count Flag</para>
        /// </summary>
        OnTaskCommandModified,

        /// <summary>
		/// </summary>
        MarqueePaste,

        /// <summary>
        /// [0] Texture2D : CopiedTexture
        /// </summary>
        OnMarqueeCopy,

        /// <summary>
		/// [0]ERedoUndo
        /// [1]RectInt
		/// </summary>
        OnRedoUndoMarqueeActivationCommand,

        /// <summary>
		/// [0]ERedoUndo
        /// [1]RectInt : PrvRegionRect
        /// [2]RectInt : RegionRect
		/// </summary>
        OnRedoUndoMarqueeInactivationCommand,

        /// <summary>
        /// [0] ERedoUndo
        /// [1] int2 MinModifiaction
        /// [2] int2 MaxModifiaction
        /// </summary>
        OnUndoRedoMarqueeReallocateCommand,

        /// <summary>
        /// [0] ERedoUndo
        /// [1] float : Dragged Delta(RectTransform Space)
        /// </summary>
        OnUndoRedoMarqueeTranslateCommand,

        /// <summary>
        /// [0] : Seed Data
        /// </summary>
        OpenCanvas,
        OnOpenCanvas,

        OnTextureGenerated,

        /// <summary>
        /// [0] : Seed Data
        /// </summary>
        OnSeedDataChanged,

        /// <summary>
        /// [0] : SeedData
        /// </summary>
        ChangeFilterMode,

        /// <summary>
        /// [0] : SeedData
        /// </summary>
        ChangeUpscaleMultiplier,

        OpenSeedDataListViewer,
        CloseSeedDataListViewer,

        /// <summary>
        /// [0] : New Seed Data Path
        /// </summary>
        AddItemToSeedDataListViewer,
        UpdateSeedDataListViewer,

        /// <summary>
        /// [0] bool : Toggle
        /// </summary>
        OnColorSpoidTriggered,

        /// <summary>
        ///  [0]int : Index
        /// </summary>
        ChangePartitionByIndex,

        /// <summary>
        ///  [0]int : Additional Index
        /// </summary>
        ChangePartitionByAddingIndex, //Deprecated

        /// <summary>
        ///  [0]Vector2 : UV
        /// </summary>
        ChangePartitionByUV,

        /// <summary>
        ///  [0]Partition : Partition
        /// </summary>
        OnPartitionChanged,

        /// <summary>
        ///  [0]int2 : nUV
        /// </summary>
        ChangeSelectedUV,

        /// <summary>
        /// <para>[0] bool : Lock Flag</para>
        /// <para>[1] bool : Reserve Canvas Update</para>
        /// </summary>
        /// <param name="a">첫 번째 숫자</param>
        /// <param name="b">두 번째 숫자</param>
        LockPartition,

        /// <summary>
        ///  [0] bool : Lock Flag
        /// </summary>
        OnLockPartition,

        /// <summary>
        /// [0] EBitPaintActionTrigger : bitTrigger
        /// </summary>
        ExecutePaintAction,

        /// <summary>
        /// [0] Bool : trigger
        /// </summary>
        TriggerMainTool,

            /// <summary>
            /// [0] Bool : trigger
            /// </summary>
            OnTriggerMainTool,

        /// <summary>
        /// [0] Bool : trigger
        /// [1] Selectable : UI Selectable
        /// </summary>
        ToggleInteraction,

        /// <summary>
        /// [0]Vector2 : Drag Delta
        /// </summary>
        OnActionButtonDragged,

        /// <summary>
        /// [0]bool : Is Moving Mode
        /// </summary>
        SwapMovingMode,

		/// <summary>
		/// [0] : EToolType
		/// </summary>
		ChangeTool,

        /// <summary>
        /// [0] : EToolType
        /// </summary>
        OnToolChanged,

        /// <summary>
        /// [0] : Color
        /// </summary>
        ChangeColor,

        /// <summary>
        /// [0] : ColorPreset
        /// </summary>
        SelectColorPreset,

        /// <summary>
        /// [0] : Color
        /// </summary>
        OnColorChanged,

        ToggleColorPickerWindow,
        CloseColorPickerWindow,

        /// <summary>
        /// [0] float : Thickness
        /// [1] float : Softness
        /// </summary>
        OnChangeBrushSetting,

        ReserveCanvasUpdate,
        ForceExecuteCanvasUpdate,

        ResetAimPosition,

        /// <summary>
        /// [0]ERedoUndo
        /// </summary>
        UndoRedo,

        /// <summary>
        /// [0]ERedoUndo
        /// </summary>
        OnUndoRedo,

        OnCanvasModified,

        /// <summary>
        /// [0] : SeedData
        /// </summary>
        OpenSeedDataViewer,
        CloseSeedDataViewer,

        OnPainboardTouch,

        /// <summary>
        /// [0] : SeedData
        /// [1] : SeedDataPath
        /// </summary>
        OpenSeedDataPopup,
        CloseSeedDataPopup,

        /// <summary>
        /// [0] : Mesh
        /// </summary>
        ChangeModel,

        /// <summary>
        /// None
        /// </summary>
        RevertSeedData,

        /// <summary>
        /// [0]Mesh : Mesh
        /// </summary>
        OnModelMeshChanged,

		/// <summary>
		/// [0]Bool : toggle
		/// </summary>
		ToggleJoystick,

        ///// <summary>
        ///// [0] : Canvas
        ///// [1] : PointEventData
        ///// [2] : PointEventData
        ///// </summary>
        //OnDoubleFingerDragged,
        ///// <summary>
        ///// [0] : Canvas
        ///// [1] : PointEventData
        ///// </summary>
        //OnOneFingerDragged,
        //RotateToIdle_Paintboard3D,

        //ResultViewer================================================

        /// <summary>
        /// [0] PointerEventData
        /// </summary>
        OnScrollResultViewer,
        //ResultViewer================================================

        /// <summary>
        /// [0] EComfirmPopupType : type
        /// [1] string : Label text
        /// [2] Aciton : Callback 0
        /// [3] Action : Callback 1
        /// </summary>
        OpenComfirmPopup,
        OnUXModeChanged,

        /// <summary>
        /// [0] string : Message
        /// </summary>
        ShowToastMessage,

        /// <summary>
        /// [0] string[] : File Paths
        /// </summary>
        FileDragDrop,

        /// <summary>
        /// -----------------Editor Purpose.
        /// </summary>
        Editor_OnModelDataGenerated,
    }

    public enum EQueryEventID
    {
        AimPosition,
    }

    public static class EventManager
    {
        private static Dictionary<EPixelArtEventID, List<Action<EPixelArtEventID, object[]>>> _event;

        //[RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]
        //private static void OnBeforeSceneLoad()
        //{
        //    _event = new Dictionary<EPixelArtEventID, List<Action<EPixelArtEventID, object[]>>>();
        //}

        //static EventManager()
        //{
        //    _event = new Dictionary<EPixelArtEventID, List<Action<EPixelArtEventID, object[]>>>();
        //}

        public static void Destroy()
        {
            if (_event != null)
                _event.Clear();
            _event = null;
        }

        public static void Register(EPixelArtEventID id, Action<EPixelArtEventID, object[]> action)
        {
            if (_event == null)
                _event = new Dictionary<EPixelArtEventID, List<Action<EPixelArtEventID, object[]>>>();

            if (_event.TryGetValue(id, out var actions) == false)
            {
                actions = new List<Action<EPixelArtEventID, object[]>>();
                _event.Add(id, actions);
            }
            actions.Add(action);
        }

        public static void Unregister(EPixelArtEventID id, Action<EPixelArtEventID, object[]> action)
        {
            if (_event == null)
                return;

            if (_event.TryGetValue(id, out var actions) == false)
                return;
            actions.Remove(action);
        }

        public static void Notify(EPixelArtEventID id, params object[] args)
        {
            if (_event == null)
                return;

            if (_event.TryGetValue(id, out var actions) == false)
                return;

            for (var i = 0; i < actions.Count; ++i)
            {
                actions[i].Invoke(id, args);
            }
        }


        //Value Query================================================================================================================
        private static Dictionary<EQueryEventID, Func<EQueryEventID, object>> _queryEvent;

        public static void Register(EQueryEventID id, Func<EQueryEventID, object> func)
        {
            if (_queryEvent == null)
                _queryEvent = new Dictionary<EQueryEventID, Func<EQueryEventID, object>>();

            _queryEvent[id] = func;
        }

        public static void Unregister(EQueryEventID id)
        {
            if (_queryEvent == null)
                return;

            _queryEvent.Remove(id);
        }

        public static bool QueryValue<T>(EQueryEventID id, out T value)
        {
            if (_queryEvent == null)
            {
                value = default;
                return false;
            }

            if (_queryEvent.TryGetValue(id, out var func) == false)
            {
                value = default;
                return false;
            }

            try
            {
                value = (T)func.Invoke(id);
            }
            catch (Exception e)
            {
                value = default;
                Debug.LogError($"EventManater.QueryValue() Failure on : {id}");
            }

            return true;
        }
    }
}
