using System;

using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;


namespace VirtualCamera
{
    [Serializable]
    public class PostProcess
    {
        const int k_MaxPyramidSize = 16;

        [SerializeField] private VolumeProfile _profile;
        [SerializeField] private Material _uberMaterial;
        [SerializeField] private Material _bloomMaterial;

        private static int[] _BloomMipUp;
        private static int[] _BloomMipDown;
        private static bool _useRGBM;
        private static GraphicsFormat _defaultHDRFormat;

        private void InitializePostprocess()
        {
            if (_BloomMipUp != null)
                return;

            _BloomMipUp = new int[k_MaxPyramidSize];
            _BloomMipDown = new int[k_MaxPyramidSize];

            for (int i = 0; i < k_MaxPyramidSize; i++)
            {
                _BloomMipUp[i] = Shader.PropertyToID("_BloomMipUp" + i);
                _BloomMipDown[i] = Shader.PropertyToID("_BloomMipDown" + i);
            }

            // Texture format pre-lookup
            if (SystemInfo.IsFormatSupported(GraphicsFormat.B10G11R11_UFloatPack32, FormatUsage.Linear | FormatUsage.Render))
            {
                //_defaultHDRFormat = GraphicsFormat.B10G11R11_UFloatPack32;
                //_useRGBM = false;
                //_defaultHDRFormat = GraphicsFormat.R8G8B8A8_SRGB;
                _defaultHDRFormat = GraphicsFormat.R16G16B16A16_SFloat;
                _useRGBM = false;
            }
            else
            {
                _defaultHDRFormat = QualitySettings.activeColorSpace == ColorSpace.Linear
                    ? GraphicsFormat.R8G8B8A8_SRGB
                    : GraphicsFormat.R8G8B8A8_UNorm;
                _useRGBM = true;
            }
        }

        private void SetupBloom(CommandBuffer cmd, RenderTexture renderTexture, Bloom bloom)
        {
            var source = new RenderTargetIdentifier(renderTexture);
            var descriptor = renderTexture.descriptor;

            // Start at half-res
            int tw = descriptor.width >> 1;
            int th = descriptor.height >> 1;

            // Determine the iteration count
            int maxSize = Mathf.Max(tw, th);
            int iterations = Mathf.FloorToInt(Mathf.Log(maxSize, 2f) - 1);
            iterations -= bloom.skipIterations.value;
            int mipCount = Mathf.Clamp(iterations, 1, k_MaxPyramidSize);

            // Pre-filtering parameters
            float clamp = bloom.clamp.value;
            float threshold = Mathf.GammaToLinearSpace(bloom.threshold.value);
            float thresholdKnee = threshold * 0.5f; // Hardcoded soft knee

            // Material setup
            float scatter = Mathf.Lerp(0.05f, 0.95f, bloom.scatter.value);
            _bloomMaterial.SetVector(GlobalValue._Params, new Vector4(scatter, clamp, threshold, thresholdKnee));
            CoreUtils.SetKeyword(_bloomMaterial, GlobalValue.BloomHQ, bloom.highQualityFiltering.value);
            CoreUtils.SetKeyword(_bloomMaterial, GlobalValue.UseRGBM, _useRGBM);

            // Prefilter
            var desc = GetCompatibleDescriptor(descriptor, _defaultHDRFormat);

            cmd.GetTemporaryRT(_BloomMipDown[0], desc, FilterMode.Bilinear);
            cmd.GetTemporaryRT(_BloomMipUp[0], desc, FilterMode.Bilinear);
            Blit(cmd, source, _BloomMipDown[0], _bloomMaterial, 0);

            // Downsample - gaussian pyramid
            int lastDown = _BloomMipDown[0];
            for (int i = 1; i < mipCount; i++)
            {
                tw = Mathf.Max(1, tw >> 1);
                th = Mathf.Max(1, th >> 1);
                int mipDown = _BloomMipDown[i];
                int mipUp = _BloomMipUp[i];

                desc.width = tw;
                desc.height = th;

                cmd.GetTemporaryRT(mipDown, desc, FilterMode.Bilinear);
                cmd.GetTemporaryRT(mipUp, desc, FilterMode.Bilinear);

                // Classic two pass gaussian blur - use mipUp as a temporary target
                //   First pass does 2x downsampling + 9-tap gaussian
                //   Second pass does 9-tap gaussian using a 5-tap filter + bilinear filtering
                Blit(cmd, lastDown, mipUp, _bloomMaterial, 1);
                Blit(cmd, mipUp, mipDown, _bloomMaterial, 2);

                lastDown = mipDown;
            }

            // Upsample (bilinear by default, HQ filtering does bicubic instead
            for (int i = mipCount - 2; i >= 0; i--)
            {
                int lowMip = (i == mipCount - 2) ? _BloomMipDown[i + 1] : _BloomMipUp[i + 1];
                int highMip = _BloomMipDown[i];
                int dst = _BloomMipUp[i];

                cmd.SetGlobalTexture(GlobalValue._SourceTexLowMip, lowMip);
                Blit(cmd, highMip, BlitDstDiscardContent(cmd, dst), _bloomMaterial, 3);
            }

            // Cleanup
            for (int i = 0; i < mipCount; i++)
            {
                cmd.ReleaseTemporaryRT(_BloomMipDown[i]);
                if (i > 0)
                    cmd.ReleaseTemporaryRT(_BloomMipUp[i]);
            }

            // Setup bloom on uber
            var tint = bloom.tint.value.linear;
            var luma = ColorUtils.Luminance(tint);
            tint = luma > 0f ? tint * (1f / luma) : Color.white;

            var bloomParams = new Vector4(bloom.intensity.value, tint.r, tint.g, tint.b);
            _uberMaterial.SetVector(GlobalValue._Bloom_Params, bloomParams);
            _uberMaterial.SetFloat(GlobalValue._Bloom_RGBM, _useRGBM ? 1f : 0f);

            cmd.SetGlobalTexture(GlobalValue._Bloom_Texture, _BloomMipUp[0]);

            // Setup lens dirtiness on uber
            // Keep the aspect ratio correct & center the dirt texture, we don't want it to be
            // stretched or squashed
            var dirtTexture = bloom.dirtTexture.value == null ? Texture2D.blackTexture : bloom.dirtTexture.value;
            float dirtRatio = dirtTexture.width / (float)dirtTexture.height;
            float screenRatio = descriptor.width / (float)descriptor.height;
            var dirtScaleOffset = new Vector4(1f, 1f, 0f, 0f);
            float dirtIntensity = bloom.dirtIntensity.value;

            if (dirtRatio > screenRatio)
            {
                dirtScaleOffset.x = screenRatio / dirtRatio;
                dirtScaleOffset.z = (1f - dirtScaleOffset.x) * 0.5f;
            }
            else if (screenRatio > dirtRatio)
            {
                dirtScaleOffset.y = dirtRatio / screenRatio;
                dirtScaleOffset.w = (1f - dirtScaleOffset.y) * 0.5f;
            }

            _uberMaterial.SetVector(GlobalValue._LensDirt_Params, dirtScaleOffset);
            _uberMaterial.SetFloat(GlobalValue._LensDirt_Intensity, dirtIntensity);
            _uberMaterial.SetTexture(GlobalValue._LensDirt_Texture, dirtTexture);

            // Keyword setup - a bit convoluted as we're trying to save some variants in Uber...
            if (bloom.highQualityFiltering.value)
                _uberMaterial.EnableKeyword(dirtIntensity > 0f ? ShaderKeywordStrings.BloomHQDirt : ShaderKeywordStrings.BloomHQ);
            else
                _uberMaterial.EnableKeyword(dirtIntensity > 0f ? ShaderKeywordStrings.BloomLQDirt : ShaderKeywordStrings.BloomLQ);
        }

        //void SetupColorGrading(CommandBuffer cmd, ref RenderingData renderingData, Material material)
        //private void SetupColorGrading(CommandBuffer cmd, RenderTexture renderTexture, Tonemapping colorAdjustments)
        //{
        //    //ref var postProcessingData = ref renderingData.postProcessingData;
        //    //bool hdr = postProcessingData.gradingMode == ColorGradingMode.HighDynamicRange;
        //    //int lutHeight = postProcessingData.lutSize;
        //    //int lutWidth = lutHeight * lutHeight;

        //    //// Source material setup
        //    //float postExposureLinear = Mathf.Pow(2f, colorAdjustments.postExposure.value);
        //    ////cmd.SetGlobalTexture(GlobalValue._InternalLut, m_InternalLut.Identifier());
        //    //_uberMaterial.SetVector(GlobalValue._Lut_Params, new Vector4(1f / lutWidth, 1f / lutHeight, lutHeight - 1f, postExposureLinear));
        //    ////_uberMaterial.SetTexture(GlobalValue._UserLut, m_ColorLookup.texture.value);
        //    //_uberMaterial.SetVector(GlobalValue._UserLut_Params, !m_ColorLookup.IsActive()
        //    //    ? Vector4.zero
        //    //    : new Vector4(1f / m_ColorLookup.texture.value.width,
        //    //        1f / m_ColorLookup.texture.value.height,
        //    //        m_ColorLookup.texture.value.height - 1f,
        //    //        m_ColorLookup.contribution.value)
        //    //);

        //    //if (hdr)
        //    //{
        //    //    _uberMaterial.EnableKeyword(ShaderKeywordStrings.HDRGrading);
        //    //}
        //    //else
        //    //{
        //    //    switch (m_Tonemapping.mode.value)
        //    //    {
        //    //        case TonemappingMode.Neutral: material.EnableKeyword(ShaderKeywordStrings.TonemapNeutral); break;
        //    //        case TonemappingMode.ACES: material.EnableKeyword(ShaderKeywordStrings.TonemapACES); break;
        //    //        default: break; // None
        //    //    }
        //    //}
        //}


        public void Execute(CommandBuffer cmd, RenderTexture renderTexture)
        {
            if (_profile.components.Count == 0)
                return;

            InitializePostprocess();

            if (_profile.TryGet<Bloom>(out var bloom) == true)
            {
                using (new ProfilingScope(cmd, new ProfilingSampler("Bloom")))
                    SetupBloom(cmd, renderTexture, bloom);
            }

            //if (_profile.TryGet<ColorAdjustments>(out var colorAdjustments) == true)
            //{
            //    using (new ProfilingScope(cmd, new ProfilingSampler("ColorAdjustments")))
            //        SetupBloom(cmd, renderTexture, bloom);
            //}

            //Copy Target to Source
            var source = Shader.PropertyToID("Source");
            cmd.GetTemporaryRT(source, renderTexture.descriptor, FilterMode.Bilinear);
            cmd.Blit(renderTexture, source);

            //Execute Postprocessing
            cmd.Blit(source, renderTexture, _uberMaterial);

            //Release Source
            cmd.ReleaseTemporaryRT(source);
        }

        RenderTextureDescriptor GetCompatibleDescriptor(RenderTextureDescriptor descriptor, GraphicsFormat format, int depthBufferBits = 0)
        {
            var desc = descriptor;
            desc.depthBufferBits = depthBufferBits;
            desc.msaaSamples = 1;
            desc.width = descriptor.width;
            desc.height = descriptor.height;
            desc.graphicsFormat = format;
            return desc;
        }

        private BuiltinRenderTextureType BlitDstDiscardContent(CommandBuffer cmd, RenderTargetIdentifier rt)
        {
            // We set depth to DontCare because rt might be the source of PostProcessing used as a temporary target
            // Source typically comes with a depth buffer and right now we don't have a way to only bind the color attachment of a RenderTargetIdentifier
            cmd.SetRenderTarget(new RenderTargetIdentifier(rt, 0, CubemapFace.Unknown, -1),
                RenderBufferLoadAction.DontCare, RenderBufferStoreAction.Store,
                RenderBufferLoadAction.DontCare, RenderBufferStoreAction.DontCare);
            return BuiltinRenderTextureType.CurrentActive;
        }

        private void Blit(CommandBuffer cmd, RenderTargetIdentifier source, RenderTargetIdentifier destination, Material material, int passIndex = 0)
        {
            cmd.SetGlobalTexture(GlobalValue.sourceTex, source);
            //if (m_UseDrawProcedural)
            //{
            //    Vector4 scaleBias = new Vector4(1, 1, 0, 0);
            //    cmd.SetGlobalVector(ShaderPropertyId.scaleBias, scaleBias);

            //    cmd.SetRenderTarget(new RenderTargetIdentifier(destination, 0, CubemapFace.Unknown, -1),
            //        RenderBufferLoadAction.Load, RenderBufferStoreAction.Store, RenderBufferLoadAction.Load, RenderBufferStoreAction.Store);
            //    cmd.DrawProcedural(Matrix4x4.identity, material, passIndex, MeshTopology.Quads, 4, 1, null);
            //}
            //else
            {
                cmd.Blit(source, destination, material, passIndex);
            }
        }
    }
}
