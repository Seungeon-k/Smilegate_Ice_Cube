using Newtonsoft.Json.Linq;

using System;
using System.Drawing;

using Unity.Mathematics;

using UnityEngine;
using UnityEngine.UI;

using System.IO;
using System.IO.Compression;
using System.Runtime.Serialization.Formatters.Binary;

using Graphics = UnityEngine.Graphics;
using Color = UnityEngine.Color;

using System.Linq;
using UnityEngine.Experimental.Rendering;



#if UNITY_EDITOR
using UnityEditor;
#endif

namespace PixelCanvas
{

    public static partial class ExtensionMethod
    {
        public static bool Contains(this EBitFlagSave @this, EBitFlagSave flag) => (@this & flag) != 0;

        public static bool Contains(this EBitFlagGenerateThumbnail @this, EBitFlagGenerateThumbnail flag) => (@this & flag) != 0;

        public static bool Contains(this EBitPaintActionTrigger @this, EBitPaintActionTrigger flag) => (@this & flag) != 0;

        public static Vector2 ToVector2(this Vector2Int v) => new Vector2(v.x, v.y);

        public static int2 ToInt2(this Vector2Int v) => new int2(v.x, v.y);

        public static int3 ToInt2(this Vector3Int v) => new int3(v.x, v.y, v.z);

        public static bool AreEqual(this byte[] a, byte[] b)
        {
            if (ReferenceEquals(a, b))
                return true;

            if (a is null || b is null)
                return false;

            return a.SequenceEqual(b);
        }

        public static void OverlapRegion(this Texture2D dest, Texture2D source, Rectangle region)
        {
            if (dest.width < source.width)
                return;
            if (dest.height < source.height)
                return;
            if (source.width != region.Width)
                return;
            if (source.height != region.Height)
                return;

            for (var y = 0; y < source.height; ++y)
            {
                for (var x = 0; x < source.width; ++x)
                {
                    var color = source.GetPixel(x, y);
                    var newX = x + region.X;
                    var newY = y + region.Y;
                    dest.SetPixel(newX, newY, color);
                }
            }
            dest.Apply();
        }

        //public static void OverlapRegion(this Texture2D dest, cImage source, Rectangle region)
        //{
        //    if (dest.width < source.Width)
        //        return;
        //    if (dest.height < source.Height)
        //        return;
        //    if (source.Width != region.Width)
        //        return;
        //    if (source.Height != region.Height)
        //        return;

        //    for (var y = 0; y < source.Height; ++y)
        //    {
        //        for (var x = 0; x < source.Width; ++x)
        //        {
        //            var pixel = source.GetPixel(x, y);
        //            var r = (float)pixel.DoubleRed;
        //            var g = (float)pixel.DoubleGreen;
        //            var b = (float)pixel.DoubleBlue;
        //            var a = (float)pixel.DoubleAlpha;
        //            var color = new UnityEngine.Color(r, g, b, a);
        //            color.a = 1;

        //            var newX = x + region.X;
        //            var newY = y + region.Y;
        //            dest.SetPixel(newX, newY, color);
        //        }
        //    }
        //    dest.Apply();
        //}

        public static Transform Findrecursive(this Transform root, string name)
        {
            return FindRecursive(root, name);

            Transform FindRecursive(Transform transform, string name)
            {
                if (transform.name == name)
                    return transform;

                for (var i = 0; i < transform.childCount; ++i)
                {
                    var temp = transform.GetChild(i);
                    var result = FindRecursive(temp, name);
                    if (result != null)
                        return result;
                }
                return null;
            }
        }

        public static Texture2D Clone(this Texture2D source, TextureFormat format)
        {
            var newTexture = new Texture2D(source.width, source.height, format, source.mipmapCount, false);
            newTexture.SetPixels(source.GetPixels());
            newTexture.Apply();
            //Graphics.CopyTexture(source, newTexture);
            return newTexture;
        }

        public static Texture2D Clone(this Texture2D source)
        {
            //Graphics.CopyTexture(source, newTexture);
            //var newTexture = new Texture2D(source.width, source.height, source.format, source.mipmapCount);
            var newTexture = GameObject.Instantiate(source);
            newTexture.SetPixels(source.GetPixels());
            newTexture.Apply();
            return newTexture;
        }

        public static void CopyTo(this RenderTexture source, Texture2D texture)
        {
            RenderTexture.active = source;
            var size = new Vector2(source.width, source.height);
            texture.ReadPixels(new Rect(0, 0, size.x, size.y), 0, 0);
            texture.Apply();
            RenderTexture.active = null;
        }

        //public static Texture2D CloneToTexture2D(this RenderTexture source)
        //{
        //    //var texture2D = new Texture2D(source.width, source.height, source.graphicsFormat, TextureCreationFlags.None);
        //    var texture2D = new Texture2D(source.width, source.height, source.descriptor., 0, );
        //    texture2D.filterMode = source.filterMode;

        //    RenderTexture.active = source;
        //    var size = new Vector2(source.width, source.height);
        //    texture2D.ReadPixels(new Rect(0, 0, size.x, size.y), 0, 0);
        //    texture2D.Apply();
        //    RenderTexture.active = null;

        //    return texture2D;
        //}

        public static Texture2D CloneToTexture2D(this RenderTexture source, TextureFormat textureFormat = TextureFormat.ARGB32)
        {
            //var texture2D = new Texture2D(source.width, source.height, source.graphicsFormat, TextureCreationFlags.None);
            var texture2D = new Texture2D(source.width, source.height, textureFormat, false, false);
            texture2D.filterMode = source.filterMode;

            RenderTexture.active = source;
            var size = new Vector2(source.width, source.height);
            texture2D.ReadPixels(new Rect(0, 0, size.x, size.y), 0, 0);
            texture2D.Apply();
            RenderTexture.active = null;

            return texture2D;
        }

        public static Texture2D DeCompress(this Texture2D source)
        {
            RenderTexture renderTex = RenderTexture.GetTemporary(
                        source.width,
                        source.height,
                        0,
                        RenderTextureFormat.Default,
                        RenderTextureReadWrite.Default);

            Graphics.Blit(source, renderTex);
            RenderTexture previous = RenderTexture.active;
            RenderTexture.active = renderTex;
            Texture2D readableText = new Texture2D(source.width, source.height);
            readableText.ReadPixels(new Rect(0, 0, renderTex.width, renderTex.height), 0, 0);
            readableText.Apply();
            RenderTexture.active = previous;
            RenderTexture.ReleaseTemporary(renderTex);
            return readableText;
        }

        public static Texture2D GetTexture2D(this RawImage rawImage) => rawImage.texture as Texture2D;

        public static UnityEngine.Color GetPixel(this RenderTexture renderTexture, int x, int y)
        {
            //         var vectorBuffer = new ComputeBuffer(1, 16);
            //         var computeShader = ResourceManager.Instance.DiffRegionShader;
            //         var kernelIndex = computeShader.FindKernel("CSReadPixel");
            //         computeShader.SetVector(GlobalValue._PixelIndexCoord, new Vector4(x, y, 0, 0));
            //         computeShader.SetTexture(kernelIndex, GlobalValue._SeedRWTex, ResourceManager.Instance.SeedTarget);
            //         computeShader.SetBuffer(kernelIndex, GlobalValue._ColorBuffer, vectorBuffer);
            //         computeShader.Dispatch(kernelIndex, 1, 1, 1);
            //         var vectorData = new Vector4[1];
            //         vectorBuffer.GetData(vectorData);
            //vectorBuffer.Destroy();
            //         var color = new Color(vectorData[0].x, vectorData[0].y, vectorData[0].z, vectorData[0].w);

            var tex = new Texture2D(1, 1, TextureFormat.ARGB32, false);
            tex.filterMode = FilterMode.Point;

            RenderTexture.active = renderTexture;
            tex.ReadPixels(new Rect(x, y, 1, 1), 0, 0);
            RenderTexture.active = null;

            var color = tex.GetPixel(0, 0);
            GameObject.DestroyImmediate(tex);
            return color;
        }


        //public static T GetPixel<T>(this RenderTexture renderTexture, int x, int y) where T : struct
        //{
        //	var buffer = new ComputeBuffer(1, Marshal.SizeOf<T>());
        //	var computeShader = ResourceManager.Instance.DiffRegionShader;
        //	var kernelIndex = computeShader.FindKernel("CSReadPixel");
        //	computeShader.SetVector(GlobalValue._PixelIndexCoord, new Vector4(x, y, 0, 0));
        //	computeShader.SetTexture(kernelIndex, GlobalValue._SeedRWTex, renderTexture);
        //	computeShader.SetBuffer(kernelIndex, GlobalValue._ColorBuffer, buffer);
        //	computeShader.Dispatch(kernelIndex, 1, 1, 1);
        //	var vectorData = new T[1];
        //	buffer.GetData(vectorData);
        //	buffer.Destroy();
        //	return vectorData[0];
        //}


        public static Rectangle Scale(this Rectangle rectangle, float scale)
        {
            rectangle.X *= 3;
            rectangle.Y *= 3;
            rectangle.Width *= 3;
            rectangle.Height *= 3;
            return rectangle;
        }

        public static Vector2 ToVector2(this Vector3 vector)
        {
            return new Vector2(vector.x, vector.y);
        }

        public static Vector3 ToVector3(this Vector2 vector)
        {
            return new Vector3(vector.x, vector.y, 0);
        }

        public static float Distance(this UnityEngine.Color thisColor, UnityEngine.Color color)
        {
            return math.distance(new float3(thisColor.r, thisColor.g, thisColor.b), new float3(color.r, color.g, color.b));
        }

        public static bool GetData<T>(this JObject jObject, string key, out T data)
        {
            data = default(T);
            if (jObject.TryGetValue(key, out var jToken) == false)
                return false;

            try
            {
                data = jToken.ToObject<T>();
                return true;
            }
            catch
            {
                return false;
            }
        }

        public static EPixelCanvas_Result TryParseJson(this string @this, out JObject jObject)
        {
            jObject = null;

            try
            {
                jObject = JObject.Parse(@this);
            }
            catch (Exception e)
            {
                Debug.LogError($"TryParseJson Failed : {e}");
                return EPixelCanvas_Result.Error_StringToJObject;
            }

            return EPixelCanvas_Result.Success;
        }

        public static byte[] Compress(byte[] data)
        {
            MemoryStream output = new MemoryStream();
            //using (var dstream = new BrotliStream(output, System.IO.Compression.CompressionLevel.Optimal))
            using (var dstream = new DeflateStream(output, System.IO.Compression.CompressionLevel.Optimal))
            {
                dstream.Write(data, 0, data.Length);
            }
            return output.ToArray();
        }

        public static byte[] Decompress(byte[] data)
        {
            MemoryStream input = new MemoryStream(data);
            MemoryStream output = new MemoryStream();
            using (DeflateStream dstream = new DeflateStream(input, CompressionMode.Decompress))
            {
                dstream.CopyTo(output);
            }
            return output.ToArray();
        }

        public static void Save(this Texture2D targetTexture, string path)
        {
            var directory = Path.GetDirectoryName(path);
            if (Directory.Exists(directory) == false)
                Directory.CreateDirectory(directory);

            var bytes = targetTexture.EncodeToPNG();
            File.WriteAllBytes(path, bytes);
        }
    }

    public static class StringExtensions
    {
        /// <summary>
        /// Transforms strings like variable and class names to nice UI-friendly strings, removing
        /// underlines, hiphens, prefixes and the like
        /// </summary>
        /// <param name="str">The string to be nicified</param>
        /// <param name="preserveAccronyms">If accronym letters should be kept together</param>
        /// <returns>A nicified Title Cased version ready for UIs</returns>
        public static string Nicify(this string str, bool preserveAccronyms = true)
        {
            string trimmed = str;

            if (trimmed[1] == '_') trimmed = trimmed.Remove(0, 2);
            if (trimmed[0] == '_') trimmed = trimmed.Remove(0, 1);
            if (trimmed[0].IsLowerCase() && trimmed[1].IsUpperCase()) trimmed = trimmed.Remove(0, 1);

            string[] strs = trimmed.Split('_', '-');
            if (strs.Length == 1)
            {
                string nicified = "";
                for (int i = 0; i < trimmed.Length; i++)
                {
                    if (i == 0) nicified += trimmed[i].ToUpper();
                    else if (trimmed[i].IsUpperCase())
                    {
                        bool shouldAddSpace = !(preserveAccronyms && trimmed[i - 1].IsUpperCase());
                        shouldAddSpace |= i < trimmed.Length - 2 && trimmed[i + 1].IsLowerCase();
                        nicified += (shouldAddSpace ? " " : "") + trimmed[i];
                    }
                    else nicified += trimmed[i];
                }

                return nicified;
            }
            else
            {
                string nicified = "";
                foreach (string s in strs)
                {
                    nicified += " " + s.Nicify();
                }
                return nicified.Remove(0, 1);
            }
        }

        /// <returns>Checks if a character is a lowercase letter</returns>
        public static bool IsLowerCase(this char c)
        {
            return (c >= 'a' && c <= 'z') || (c >= 'à' && c <= 'ý');
        }

        /// <returns>Checks if a character is an UPPERCASE letter</returns>
        public static bool IsUpperCase(this char c)
        {
            return (c >= 'A' && c <= 'Z') || (c >= 'À' && c <= 'Ý');
        }

        /// <returns>Checks if a character is a letter</returns>
        public static bool IsLetter(this char c)
        {
            return c.IsLowerCase() || c.IsUpperCase();
        }

        /// <returns>Transforms a letter to UPPERCASE</returns>
        public static char ToUpper(this char c)
        {
            if (c.IsLowerCase()) return (char)(c - 32);
            else return c;
        }

        /// <returns>Transforms a letter to lowercase</returns>
        public static char ToLower(this char c)
        {
            if (c.IsUpperCase()) return (char)(c + 32);
            else return c;
        }

        public static Rect GetWorldRect(this RectTransform rectTransform, Camera camera)
        {
            var corners = new Vector3[4];
            rectTransform.GetWorldCorners(corners);

            for (int i = 0; i < corners.Length; i++)
            {
                corners[i] = camera.WorldToScreenPoint(corners[i]);
                corners[i] = new Vector3(Mathf.RoundToInt(corners[i].x), Mathf.RoundToInt(corners[i].y), corners[i].z);
            }

            var minX = Mathf.Min(corners[0].x, corners[1].x, corners[2].x, corners[3].x);
            var minY = Mathf.Min(corners[0].y, corners[1].y, corners[2].y, corners[3].y);
            var width = Mathf.Max(corners[0].x, corners[1].x, corners[2].x, corners[3].x) - minX;
            var height = Mathf.Max(corners[0].y, corners[1].y, corners[2].y, corners[3].y) - minY;

            return new Rect(minX, minY, width, height);
        }
    }


#if UNITY_EDITOR

    public static partial class ExtensionMethod
    {
        public static void ReadWriteToggle(this Texture2D source, bool flag)
        {
            var path = AssetDatabase.GetAssetPath(source);
            var importer = TextureImporter.GetAtPath(path) as TextureImporter;
            if (importer != null)
            {
                importer.isReadable = flag;
                EditorUtility.SetDirty(importer);
                importer.SaveAndReimport();
            }
        }

        public static void SaveTextureToBinary(this Texture2D targetTexture, string path)
        {
            var seedTextureByte = targetTexture.EncodeToPNG();

            using (FileStream file = File.Create(path))
            {
                var formatter = new BinaryFormatter();

                var bw = new BinaryWriter(file);
                bw.Write(targetTexture.width);
                bw.Write(targetTexture.height);
                bw.Write(seedTextureByte.Length);
                bw.Write(seedTextureByte);
                file.Close();
            }
        }

        public static Color GetRainbowColor(float value)
        {
            // Clamp value to ensure it's in range [0,1]
            value = Mathf.Clamp01(value);

            if (value == 0)
                return new Color(0, 0, 0, 1);

            // Define hue range (0~1 mapped to 0~300 degrees for rainbow effect)
            float hue = Mathf.Lerp(0.83f, 0.0f, value); // 0.83 corresponds to ~300 degrees (purple)
            float saturation = 1.0f;
            float brightness = 1.0f; // 0 is dark, 1 is bright

            // Convert HSV to RGB
            return Color.HSVToRGB(hue, saturation, brightness);
        }

        //========================================================================================================
        //TestCode================================================================================================
        //========================================================================================================

        //public static void Save(Texture2D targetTexture)
        //{
        //    var directory = "Packages/com.vulcanus.pixelcanvas/Runtime/PixelCanvas/";
        //    var name = GUID.Generate().ToString();
        //    var extension = ".png";
        //    var newTexturePath = $"{directory}\\{name}{extension}";

        //    var bytes = default(byte[]);
        //    switch (extension.ToLower())
        //    {
        //        case ".png":
        //            bytes = targetTexture.EncodeToPNG();
        //            break;
        //        case ".jpg":
        //            bytes = targetTexture.EncodeToJPG();
        //            break;
        //        case ".tga":
        //            bytes = targetTexture.EncodeToTGA();
        //            break;
        //        default:
        //            EditorUtility.DisplayDialog("Failed", "(PNG, JPG, TGA) Only", "OK");
        //            break;
        //    }
        //    System.IO.File.WriteAllBytes(newTexturePath, bytes);
        //    AssetDatabase.Refresh();

        //    //    var pixels = _seedTexture.GetPixels32();
        //    //    var data = new byte[3 * pixels.Length];
        //    //    for (var i = 0; i < pixels.Length; ++i)
        //    //    {
        //    //        var pvt = i * 3;
        //    //        data[pvt] = pixels[i].r;
        //    //        data[pvt + 1] = pixels[i].g;
        //    //        data[pvt + 2] = pixels[i].b;
        //    //    }

        //    //    //data = Compress(data);
        //    //    //System.IO.File.WriteAllBytes($"{directory}\\SeedData_2(Brotli).pxseed", data);
        //    //    //AssetDatabase.Refresh();

        //}

    }

#endif
}
