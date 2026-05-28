using System.Collections;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using UnityEngine;
using UnityEngine.UI;
using Graphics = UnityEngine.Graphics;
using Unity.Mathematics;
using System;

namespace PixelCanvas
{
	public static class PixelUpscaler
    {

        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]
        private static void OnBeforeSceneLoad()
        {
        }

		public static EPixelCanvas_Result UpscaleSeedData(SeedData seedData, out Texture upscaledSeedTexture, out Texture upscaledUberTexture, bool useMipmap = true)
        {
            upscaledSeedTexture = default;
            upscaledUberTexture = default;

            if (seedData._seedTextureByte != null && 0 < seedData._seedTextureByte.Length)
            {
                var seedSize = new int2(seedData._textureWidth, seedData._textureHeight);
                var tempTexture2D = ResourceManager.Instance.GetTemporaryTexture2D(seedSize);
                if (tempTexture2D.LoadImage(seedData._seedTextureByte) == false)
                    return EPixelCanvas_Result.Error_LoadImageSeed;

                var scaledSize = seedData.ScaledTextureSize;
                var scaledTarget = new RenderTexture(scaledSize.x, scaledSize.y, 0, RenderTextureFormat.ARGB32);
                scaledTarget.useMipMap = true;
                scaledTarget.autoGenerateMips = true;

                switch (seedData._filterMode)
                {
                    case EFilterMode.Point:
                        scaledTarget.filterMode = FilterMode.Point;
                        break;
                    case EFilterMode.Bilinear:
                        scaledTarget.filterMode = FilterMode.Bilinear;
                        break;
                }

                switch (seedData._upscaleType)
                {
                    case EUpscaleType.Xbrz:
                        Shader.SetGlobalTexture(GlobalValue._SeedTex, tempTexture2D);
                        Shader.SetGlobalVector(GlobalValue._Parameters1, new float4(seedSize.x, seedSize.y, scaledSize.x, scaledSize.y));
                        Graphics.Blit(tempTexture2D, scaledTarget, ResourceManager.Instance.UpscaleMaterial, 0, 0);
                        break;
                    default:
                        Graphics.Blit(tempTexture2D, scaledTarget);
                        break;
                }
                upscaledSeedTexture = scaledTarget;
            }

            if (seedData._uberTextureByte != null && 0 < seedData._uberTextureByte.Length)
            {
                var seedSize = new int2(seedData._uberTextureWidth, seedData._uberTextureHeight);
                var tempTexture2D = ResourceManager.Instance.GetTemporaryTexture2D(seedSize);
                if (tempTexture2D.LoadImage(seedData._uberTextureByte) == false)
                    return EPixelCanvas_Result.Error_LoadImageUber;

                upscaledUberTexture = tempTexture2D;
            }

            return EPixelCanvas_Result.Success;
        }

        //public static Texture2D ApplyScale(Texture2D upscaledSeedTexture, Texture2D scaledTexture, XbrScalerType type, Rectangle region)
        //{
        //    //PixelScalerType;
        //    //XbrzScalerType;
        //    //XbrScalerType;
        //    //NqScalerType;
        //    //KernelType;
        //    //WindowType;

        //    //targetTexture.ReadWriteToggle(true);
        //    //var clonedTexture = _originTexture.Clone();
        //    upscaledSeedTexture.filterMode = FilterMode.Point;
        //    var image = cImage.GenerateCImage(upscaledSeedTexture, region);


        //    //targetTexture.ReadWriteToggle(false);
        //    var scaledImage = image.ApplyScaler(type, false);
        //    //var scaledImage = image.ApplyScaler(NqScalerType.Lq3, NqMode.Smart);

        //    scaledTexture.OverlapRegion(scaledImage, region.Scale(3));
        //    return scaledTexture;
        //    //var clonedTexture = cImage.GenerateTexture2D(image);
        //    //return clonedTexture;
        //}

        //public static Texture2D ApplyScale(Texture2D upscaledSeedTexture, Texture2D scaledTexture, XbrScalerType type, Rectangle region)
        //{
        //    upscaledSeedTexture.filterMode = FilterMode.Point;
        //    var image = cImage.GenerateCImage(upscaledSeedTexture, region);


        //    //targetTexture.ReadWriteToggle(false);
        //    var scaledImage = image.ApplyScaler(type, false);
        //    //var scaledImage = image.ApplyScaler(NqScalerType.Lq3, NqMode.Smart);

        //    var scaledRegion = region.Scale(3);
        //    scaledTexture.OverlapRegion(scaledImage, scaledRegion);
        //    return scaledTexture;
        //    //var clonedTexture = cImage.GenerateTexture2D(image);
        //    //return clonedTexture;
        //}
    }


}