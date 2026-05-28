using System;
using UnityEngine;
using UnityEngine.Rendering;
using static UnityEditor.Rendering.Universal.ShaderGUI.Vulcanus_LitGUI_GF;

namespace UnityEditor.Rendering.Universal.ShaderGUI
{
    public enum EAlphaChannelMode
    {
        Transparency,
        ColorMask
    }

    internal class Vulcanus_LitShader_GF : BaseShaderGUI
    {
        private Vulcanus_LitGUI_GF.LitProperties litProperties;
        private Vulcanus_GUI_GF.Properties vulcanusProperties;

        public static GUIContent _albedoChannelModeText = new GUIContent("Albedo A Channel Mode");
        public static MaterialProperty _albedoChannelModeProp;
        public static GUIContent _maskColorText = new GUIContent("└─[A] Mask Color", "Activates on Global Shader Keyword Enabled");
        public MaterialProperty _maskColorProp;

        private static Texture _utilityMapCache;
        
        public override void OnOpenGUI(Material material, MaterialEditor materialEditor)
        {
            base.OnOpenGUI(material, materialEditor);

           //if (material.GetTexture("_UtilityMap") == null)
           //{
           //    if (_utilityMapCache == null)
           //        _utilityMapCache = AssetDatabase.LoadAssetAtPath<Texture>("Packages/com.vulcanus.render-pipelines.vulcanus/Textures/MaskPack_00.png");
           //    material.SetTexture("_UtilityMap", _utilityMapCache);
           //}
        }

        //public override void DrawAdditionalFoldouts(Material material) {}

        public override void FindProperties(MaterialProperty[] properties)
        {
            base.FindProperties(properties);
            litProperties = new Vulcanus_LitGUI_GF.LitProperties(properties);
            vulcanusProperties = new Vulcanus_GUI_GF.Properties(properties);

            _albedoChannelModeProp = BaseShaderGUI.FindProperty("_AbedoChannelMode", properties);
            _maskColorProp = BaseShaderGUI.FindProperty("_MaskColor", properties, false);
        }

        public override void ValidateMaterial(Material material)
        {
            if (material == null)
                throw new ArgumentNullException("material");

            base.ValidateMaterial(material);

            SetMaterialKeywords(material);
        }


        public override void DrawSurfaceOptions(Material material)
        {
            if (material == null)
                throw new ArgumentNullException("material");

            // Use default labelWidth
            EditorGUIUtility.labelWidth = 0f;

            if (litProperties.workflowMode != null)
                DoPopup(Vulcanus_LitGUI_GF.Styles.workflowModeText, litProperties.workflowMode, Enum.GetNames(typeof(Vulcanus_LitGUI_GF.WorkflowMode)));

            DoPopup(Styles.surfaceType, surfaceTypeProp, Enum.GetNames(typeof(SurfaceType)));
            if ((SurfaceType)material.GetFloat("_Surface") == SurfaceType.Transparent)
                DoPopup(Styles.blendingMode, blendModeProp, Enum.GetNames(typeof(BlendMode)));

            EditorGUI.BeginChangeCheck();
            EditorGUI.showMixedValue = cullingProp.hasMixedValue;
            var culling = (RenderFace)cullingProp.floatValue;
            culling = (RenderFace)EditorGUILayout.EnumPopup(Styles.cullingText, culling);
            if (EditorGUI.EndChangeCheck())
            {
                materialEditor.RegisterPropertyChangeUndo(Styles.cullingText.text);
                cullingProp.floatValue = (float)culling;
                material.doubleSidedGI = (RenderFace)cullingProp.floatValue != RenderFace.Front;
            }
            EditorGUI.showMixedValue = false;

            DoPopup(_albedoChannelModeText, _albedoChannelModeProp, Enum.GetNames(typeof(EAlphaChannelMode)));
            if ((EAlphaChannelMode)_albedoChannelModeProp.floatValue == EAlphaChannelMode.Transparency)
            {
                EditorGUI.BeginChangeCheck();
                EditorGUI.showMixedValue = alphaClipProp.hasMixedValue;
                var alphaClipEnabled = EditorGUILayout.Toggle(Styles.alphaClipText, alphaClipProp.floatValue == 1);
                if (EditorGUI.EndChangeCheck())
                    alphaClipProp.floatValue = alphaClipEnabled ? 1 : 0;
                EditorGUI.showMixedValue = false;

                if (alphaClipProp.floatValue == 1)
                    materialEditor.ShaderProperty(alphaCutoffProp, Styles.alphaClipThresholdText, 1);
            }

            //if (receiveShadowsProp != null)
            //{
            //    EditorGUI.BeginChangeCheck();
            //    EditorGUI.showMixedValue = receiveShadowsProp.hasMixedValue;
            //    var receiveShadows =
            //        EditorGUILayout.Toggle(Styles.receiveShadowText, receiveShadowsProp.floatValue == 1.0f);
            //    if (EditorGUI.EndChangeCheck())
            //        receiveShadowsProp.floatValue = receiveShadows ? 1.0f : 0.0f;
            //    EditorGUI.showMixedValue = false;
            //}
        }

        public override void DrawBaseProperties(Material material)
        {
            if (baseMapProp != null && baseColorProp != null) // Draw the baseMap, most shader will have at least a baseMap
            {
                materialEditor.TexturePropertySingleLine(Styles.baseMap, baseMapProp, baseColorProp);
                // TODO Temporary fix for lightmapping, to be replaced with attribute tag.
                if (material.HasProperty("_MainTex"))
                {
                    material.SetTexture("_MainTex", baseMapProp.textureValue);
                    var baseMapTiling = baseMapProp.textureScaleAndOffset;
                    material.SetTextureScale("_MainTex", new Vector2(baseMapTiling.x, baseMapTiling.y));
                    material.SetTextureOffset("_MainTex", new Vector2(baseMapTiling.z, baseMapTiling.w));
                }

                if ((EAlphaChannelMode)_albedoChannelModeProp.floatValue == EAlphaChannelMode.ColorMask)
                    materialEditor.ShaderProperty(_maskColorProp, _maskColorText);
            }
        }

        public void Inputs(LitProperties properties, MaterialEditor materialEditor, Material material)
        {
            vulcanusProperties.DrawUberMap_Lit(material, materialEditor);
            vulcanusProperties.DrawDyeingMask(material, materialEditor);
            BaseShaderGUI.DrawNormalArea(materialEditor, properties.bumpMapProp, properties.bumpScaleProp);
        }

        // material main surface inputs
        public override void DrawSurfaceInputs(Material material)
        {
            base.DrawSurfaceInputs(material);
            Inputs(litProperties, materialEditor, material);
            DrawTileOffset(materialEditor, baseMapProp);
            EditorGUILayout.Space(10);

            vulcanusProperties.Draw(material, materialEditor);
        }

        // material main advanced options
        public override void DrawAdvancedOptions(Material material)
        {
            if (litProperties.reflections != null && litProperties.highlights != null)
            {
                EditorGUI.BeginChangeCheck();
                materialEditor.ShaderProperty(litProperties.highlights, Vulcanus_LitGUI_GF.Styles.highlightsText);
                materialEditor.ShaderProperty(litProperties.reflections, Vulcanus_LitGUI_GF.Styles.reflectionsText);
                if (EditorGUI.EndChangeCheck())
                {
                    MaterialChanged(material);
                }
            }
            //base.DrawAdvancedOptions(material);
            materialEditor.EnableInstancingField();
            materialEditor.RenderQueueField();
        }

        public override void AssignNewShaderToMaterial(Material material, Shader oldShader, Shader newShader)
        {
            if (material == null)
                throw new ArgumentNullException("material");

            // _Emission property is lost after assigning Standard shader to the material
            // thus transfer it before assigning the new shader
            if (material.HasProperty("_Emission"))
            {
                material.SetColor("_EmissionColor", material.GetColor("_Emission"));
            }

            base.AssignNewShaderToMaterial(material, oldShader, newShader);

            if (oldShader == null || !oldShader.name.Contains("Legacy Shaders/"))
            {
                SetupMaterialBlendMode(material);
                return;
            }

            SurfaceType surfaceType = SurfaceType.Opaque;
            BlendMode blendMode = BlendMode.Alpha;
            if (oldShader.name.Contains("/Transparent/Cutout/"))
            {
                surfaceType = SurfaceType.Opaque;
                material.SetFloat("_AlphaClip", 1);
            }
            else if (oldShader.name.Contains("/Transparent/"))
            {
                // NOTE: legacy shaders did not provide physically based transparency
                // therefore Fade mode
                surfaceType = SurfaceType.Transparent;
                blendMode = BlendMode.Alpha;
            }
            material.SetFloat("_Surface", (float)surfaceType);
            material.SetFloat("_Blend", (float)blendMode);

            if (oldShader.name.Equals("Standard (Specular setup)"))
            {
                material.SetFloat("_WorkflowMode", (float)Vulcanus_LitGUI_GF.WorkflowMode.Specular);
                Texture texture = material.GetTexture("_SpecGlossMap");
                if (texture != null)
                    material.SetTexture("_MetallicSpecGlossMap", texture);
            }
            else
            {
                material.SetFloat("_WorkflowMode", (float)Vulcanus_LitGUI_GF.WorkflowMode.Metallic);
                Texture texture = material.GetTexture("_MetallicGlossMap");
                if (texture != null)
                    material.SetTexture("_MetallicSpecGlossMap", texture);
            }

            MaterialChanged(material);
        }

        public new static void SetMaterialKeywords(Material material, Action<Material> shadingModelFunc = null, Action<Material> shaderFunc = null)
        {
            // Setup blending - consistent across all Universal RP shaders
            SetupMaterialBlendMode(material);

            //// Receive Shadows
            //if (material.HasProperty("_ReceiveShadows"))
            //    CoreUtils.SetKeyword(material, "_RECEIVE_SHADOWS_OFF", material.GetFloat("_ReceiveShadows") == 0.0f);

            // Normal Map
            if (material.HasProperty("_BumpMap"))
                CoreUtils.SetKeyword(material, "_NORMALMAP", material.GetTexture("_BumpMap"));

            var isSpecularWorkFlow = false;
            if (material.HasProperty("_WorkflowMode"))
                isSpecularWorkFlow = (WorkflowMode)material.GetFloat("_WorkflowMode") == WorkflowMode.Specular;

            CoreUtils.SetKeyword(material, "_SPECULAR_SETUP", isSpecularWorkFlow);

            if (material.HasProperty("_SpecularHighlights"))
                CoreUtils.SetKeyword(material, "_SPECULARHIGHLIGHTS_OFF",
                    material.GetFloat("_SpecularHighlights") == 0.0f);
            if (material.HasProperty("_EnvironmentReflections"))
                CoreUtils.SetKeyword(material, "_ENVIRONMENTREFLECTIONS_OFF",
                    material.GetFloat("_EnvironmentReflections") == 0.0f);

            if (material.HasProperty("_AbedoChannelMode"))
            {
                var channelMode = (EAlphaChannelMode)material.GetFloat("_AbedoChannelMode");
                switch (channelMode)
                {
                    case EAlphaChannelMode.Transparency:
                        material.DisableKeyword("_ALBEDO_ALPHA_MASKCOLOR");
                        break;
                    case EAlphaChannelMode.ColorMask:
                        material.EnableKeyword("_ALBEDO_ALPHA_MASKCOLOR");
                        break;
                }
            }

            if (material.HasProperty("_UberMap"))
            {
                var hasValidUberMap = material.GetTexture("_UberMap") != null;
                CoreUtils.SetKeyword(material, "_UBERMAP", hasValidUberMap);
            }

            if (material.HasProperty("_DyeingMaskMap"))
            {
                var hasValidUberMap = material.GetTexture("_DyeingMaskMap") != null;
                CoreUtils.SetKeyword(material, "_DYEINGMASK", hasValidUberMap);
            }

            //Enable Fog
            if (material.HasProperty("_Fog"))
                CoreUtils.SetKeyword(material, "_FOG_OFF", material.GetFloat("_Fog") == 1);

            // Shader specific keyword functions
            shadingModelFunc?.Invoke(material);
            shaderFunc?.Invoke(material);
        }

        public new static void SetupMaterialBlendMode(Material material)
        {
            if (material == null)
                throw new ArgumentNullException("material");

            bool alphaClip = false;

            if (material.HasProperty("_AbedoChannelMode") == true)
            {
                if ((EAlphaChannelMode)material.GetFloat("_AbedoChannelMode") == EAlphaChannelMode.Transparency)
                {
                    if (material.HasProperty("_AlphaClip"))
                        alphaClip = material.GetFloat("_AlphaClip") >= 0.5;

                    CoreUtils.SetKeyword(material, "_ALPHATEST_ON", alphaClip);
                }
            }

            if (material.HasProperty("_Surface"))
            {
                SurfaceType surfaceType = (SurfaceType)material.GetFloat("_Surface");
                if (surfaceType == SurfaceType.Opaque)
                {
                    if (alphaClip)
                    {
                        if ((int)RenderQueue.Transparent <= material.renderQueue)
                            material.renderQueue = (int)RenderQueue.AlphaTest;
                        material.SetOverrideTag("RenderType", "TransparentCutout");
                    }
                    else
                    {
                        if ((int)RenderQueue.Transparent <= material.renderQueue)
                            material.renderQueue = (int)RenderQueue.Geometry;
                        material.SetOverrideTag("RenderType", "Opaque");
                    }
                    
                    material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                    material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                    material.SetInt("_ZWrite", 1);
                    material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                    material.SetShaderPassEnabled("ShadowCaster", true);
                }
                else
                {
                    BlendMode blendMode = (BlendMode)material.GetFloat("_Blend");

                    // Specific Transparent Mode Settings
                    switch (blendMode)
                    {
                        case BlendMode.Alpha:
                            material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                            material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                            material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                            break;
                        case BlendMode.Premultiply:
                            material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                            material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                            material.EnableKeyword("_ALPHAPREMULTIPLY_ON");
                            break;
                        case BlendMode.Additive:
                            material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                            material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.One);
                            material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                            break;
                        case BlendMode.Multiply:
                            material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.DstColor);
                            material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                            material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                            material.EnableKeyword("_ALPHAMODULATE_ON");
                            break;
                    }

                    // General Transparent Material Settings

                    material.SetOverrideTag("RenderType", "Transparent");
                    if (material.renderQueue < (int)RenderQueue.Transparent - 100)
                        material.renderQueue = (int)RenderQueue.Transparent;

                    material.SetInt("_ZWrite", 0);
                    material.SetShaderPassEnabled("ShadowCaster", false);

                    material.SetFloat("_ReceiveGlitter", 0);
                    material.SetFloat("_ReceiveSilhouette", 0);

                }
            }
        }
    }
}
