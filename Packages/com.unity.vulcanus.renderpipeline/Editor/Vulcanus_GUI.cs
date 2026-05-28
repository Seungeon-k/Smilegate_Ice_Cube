using UnityEngine;
using UnityEngine.Rendering;
using UnityEditor;
using System;

namespace UnityEditor.Rendering.Universal.ShaderGUI
{
    public static class Vulcanus_GUI
    {
        public enum WorkflowMode
        {
            Specular = 0,
            Metallic
        }

        public struct Properties
        {
            public MaterialProperty _workflowModeProp;

            //public static GUIContent _albedoChannelModeText = new GUIContent("Albedo A Channel Mode");
            //public static GUIContent _maskColorText = new GUIContent("└─[A] Mask Color", "Activates on Global Shader Keyword Enabled");
            //public MaterialProperty _albedoChannelModeProp;
            //public MaterialProperty _maskColorProp;

            //Vulcanus Uber Property
            public static GUIContent _simpleLitUberMapText = new GUIContent("Uber Map", "(1, 1, 1, 1) On Empty\n[R]: Specular\n[G]: Smoothness\n[B]: Emission\n[A]: Empty");
            public static GUIContent _litUberMapText = new GUIContent("Uber Map", "(1, 1, 1, 1) On Empty\n[R]: Metallic Or Specular\n[G]: Smoothness\n[B]: Emission\n[A]: Empty");
            public static GUIContent _specularColorText_A = new GUIContent("└─[R] × Specular Color");
            public static GUIContent _specularColorText_B = new GUIContent("Specular Color");
            public static GUIContent _smoothnessText_A = new GUIContent("└─[G] × Smoothness");
            public static GUIContent _smoothnessText_B = new GUIContent("Smoothness");
            public static GUIContent _emissionPowerText_A = new GUIContent("└─[B] × Emission Power");
            public static GUIContent _emissionPowerText_B = new GUIContent("Emission Power");
            public static GUIContent _emptyText = new GUIContent("└─[A] Empty");
            public static GUIContent _matallicText_A = new GUIContent("└─[R] × Metallic");
            public static GUIContent _matallicText_B = new GUIContent("Metallic");
            public MaterialProperty _uberMapProp;
            public MaterialProperty _matallicProp;
            public MaterialProperty _smoothnessProp;
            public MaterialProperty _specColorProp;
            public MaterialProperty _emissionPowerProp;

            //Vulcanus Dyeing Property
            public static GUIContent _dyeingMaskText = new GUIContent("Dyeing Mask");
            public static GUIContent _Dyeing_Color_RText = new GUIContent("└─R Channel Color");
            public static GUIContent _Dyeing_Color_GText = new GUIContent("└─G Channel Color");
            public static GUIContent _Dyeing_Color_BText = new GUIContent("└─B Channel Color");
            public static GUIContent _Dyeing_Color_AText = new GUIContent("└─A Channel Color");
            public MaterialProperty _dyeingMaskProp;
            public MaterialProperty _dyeing_Color_RProp;
            public MaterialProperty _dyeing_Color_GProp;
            public MaterialProperty _dyeing_Color_BProp;
            public MaterialProperty _dyeing_Color_AProp;

            //Vulcanus Common Property
            public static GUIContent _receiveSilhouetteText = new GUIContent("Receive Silhouette", "When Enabled, Silhouette can affect on to this GameOject");
            public static GUIContent _receiveDecalText = new GUIContent("Receive Decal", "When Enabled, Decal can affect on to this GameOject");
            public MaterialProperty _receiveSilhouetteProp;
            public MaterialProperty _receiveDecalProp;

            public static GUIContent _bdrfFersnelRatioText = new GUIContent("Bdrf Fersnel Ratio");
            public static GUIContent _rimLightLabelText = new GUIContent("Rim Light", "");
            public static GUIContent _rimLightColorText = new GUIContent("└─Color");
            public static GUIContent _rimLightPowerText = new GUIContent("└─Power");
            public MaterialProperty _bdrfFersnelRatioProp;
            public MaterialProperty _rimLightColorProp;
            public MaterialProperty _rimLightPowerProp;

            public static GUIContent _subRimLightLabelText = new GUIContent("Sub Rim Light", "Used On Programming Level");
            public static GUIContent _subRimLightColorText = new GUIContent("└─Color");
            public static GUIContent _subRimLightPowerText = new GUIContent("└─Power");
            public MaterialProperty _subRimLightColorProp;
            public MaterialProperty _subRimLightPowerProp;

            public static GUIContent _utilityMapText        = new GUIContent("Utility Map");
            public static GUIContent _dissolveColorThicknessText = new GUIContent("└─Dissolve Color & Thickness");
            public static GUIContent _dissolveText          = new GUIContent("└─Dissolve");
            public static GUIContent _ditherAlphaText       = new GUIContent("└─Dithher Alpha");
            public static GUIContent _AreaClippingText      = new GUIContent("└─Clipping Area");
            public static GUIContent _sSClipVariablesText   = new GUIContent("└─SS Clip Variable");

            public static GUIContent _SwapObjectRatioText   = new GUIContent("    └─Swap Object Ratio");
            public static GUIContent _SwapObjectSignText    = new GUIContent("    └─Swap Object Sign");
            public static GUIContent _meshXBoundsText       = new GUIContent("    └─Mesh X Bounds");
            public MaterialProperty _utilityMapProp;
            public MaterialProperty _dissolveColorThicknessProp;
            public MaterialProperty _dissolveProp;
            public MaterialProperty _ditherAlphaProp;
            public MaterialProperty _sSClipVariablesProp;
            public MaterialProperty _ClippingAreaProp;
            public MaterialProperty _SwapObjectRatioProp;
            public MaterialProperty _SwapObjectSignProp;
            public MaterialProperty _meshXBoundsProp;

            //public static GUIContent _disableFogText = new GUIContent("Disable Fog");
            //public MaterialProperty _disableFogProp;

            //Stencil Property
            public static GUIContent _StencilStateText      = new GUIContent("Stencil State");
            public static GUIContent _StencilReadMaskText = new GUIContent("└─StencilReadMask");
            public static GUIContent _StencilRefText        = new GUIContent("└─StencilRef");
            public static GUIContent _StencilCompText       = new GUIContent("└─StencilComp");
            public static GUIContent _PassOperationText     = new GUIContent("└─PassOperation");
            public static GUIContent _FailOperationText     = new GUIContent("└─FailOperation");
            public static GUIContent _ZFailOperationText    = new GUIContent("└─ZFailOperation");
            public MaterialProperty _StencilReadMaskProp;
            public MaterialProperty _StencilRefProp;
            public MaterialProperty _StencilCompProp;
            public MaterialProperty _PassOperationProp;
            public MaterialProperty _FailOperationProp;
            public MaterialProperty _ZFailOperationProp;

            public Properties(MaterialProperty[] properties)
            {
                _workflowModeProp = BaseShaderGUI.FindProperty("_WorkflowMode", properties, false);

                //_albedoChannelModeProp = BaseShaderGUI.FindProperty("_AbedoChannelMode", properties, false);
                //_maskColorProp = BaseShaderGUI.FindProperty("_MaskColor", properties, false);

                //Vulcanus Uber
                _uberMapProp = BaseShaderGUI.FindProperty("_UberMap", properties, false);
                _matallicProp = BaseShaderGUI.FindProperty("_Metallic", properties, false);
                _specColorProp = BaseShaderGUI.FindProperty("_SpecColor", properties, false);
                _smoothnessProp = BaseShaderGUI.FindProperty("_Smoothness", properties, false);
                _emissionPowerProp = BaseShaderGUI.FindProperty("_EmissionPower", properties, false);

                //Vulcanus Dyeing Property
                _dyeingMaskProp = BaseShaderGUI.FindProperty("_DyeingMaskMap", properties, false);
                _dyeing_Color_RProp = BaseShaderGUI.FindProperty("_Dyeing_Color_R", properties, false);
                _dyeing_Color_GProp = BaseShaderGUI.FindProperty("_Dyeing_Color_G", properties, false);
                _dyeing_Color_BProp = BaseShaderGUI.FindProperty("_Dyeing_Color_B", properties, false);
                _dyeing_Color_AProp = BaseShaderGUI.FindProperty("_Dyeing_Color_A", properties, false);

                //Vulcanus Common Property
                _receiveSilhouetteProp = BaseShaderGUI.FindProperty("_ReceiveSilhouette", properties, false);
                _receiveDecalProp = BaseShaderGUI.FindProperty("_ReceiveDecal", properties, false);
                _bdrfFersnelRatioProp = BaseShaderGUI.FindProperty("_BdrfFersnelRatio", properties, false);
                _rimLightColorProp = BaseShaderGUI.FindProperty("_RimColor", properties, false);
                _rimLightPowerProp = BaseShaderGUI.FindProperty("_RimPower", properties, false);
                _subRimLightColorProp = BaseShaderGUI.FindProperty("_SubRimColor", properties, false);
                _subRimLightPowerProp = BaseShaderGUI.FindProperty("_SubRimPower", properties, false);
                _utilityMapProp = BaseShaderGUI.FindProperty("_UtilityMap", properties, false);
                _dissolveColorThicknessProp = BaseShaderGUI.FindProperty("_DissolveColorThickness", properties, false);
                _dissolveProp = BaseShaderGUI.FindProperty("_Dissolve", properties, false);
                _ditherAlphaProp = BaseShaderGUI.FindProperty("_DitherAlpha", properties, false);
                _sSClipVariablesProp = BaseShaderGUI.FindProperty("_SSClipVariables", properties, false);

                _ClippingAreaProp = BaseShaderGUI.FindProperty("_ClippingArea", properties, false);
                _ClippingAreaProp =  BaseShaderGUI.FindProperty("_ClippingArea", properties, false);

                _SwapObjectRatioProp = BaseShaderGUI.FindProperty("_SwapObjectRatio", properties, false);
                _SwapObjectSignProp = BaseShaderGUI.FindProperty("_SwapObjectSign", properties, false);
                _meshXBoundsProp = BaseShaderGUI.FindProperty("_MeshXBounds", properties, false);
                //_disableFogProp = BaseShaderGUI.FindProperty("_Fog", properties, false);

                //Stencil Property
                _StencilReadMaskProp = BaseShaderGUI.FindProperty("_StencilReadMask", properties, true);
                _StencilRefProp = BaseShaderGUI.FindProperty("_StencilRef", properties, true);
                _StencilCompProp = BaseShaderGUI.FindProperty("_StencilComp", properties, true);
                _PassOperationProp = BaseShaderGUI.FindProperty("_PassOperation", properties, true);
                _FailOperationProp = BaseShaderGUI.FindProperty("_FailOperation", properties, true);
                _ZFailOperationProp = BaseShaderGUI.FindProperty("_ZFailOperation", properties, true);
            }

            //public void DrawAlbedoAChannelMode(Material material, MaterialEditor materialEditor)
            //{
            //    _albedoChannelModeProp.floatValue = (int)(EAlphaChannelMode)EditorGUILayout.EnumPopup(_albedoChannelModeText, (EAlphaChannelMode)_albedoChannelModeProp.floatValue);

            //    //DoPopup(_albedoChannelModeText, _albedoChannelModeProp, Enum.GetNames(typeof(EAlphaChannelMode)));

            //    //if ((EAlphaChannelMode)_albedoChannelModeProp.floatValue == EAlphaChannelMode.Transparency)
            //    //{
            //    //    EditorGUI.showMixedValue = false;
            //    //    EditorGUI.BeginChangeCheck();
            //    //    EditorGUI.showMixedValue = alphaClipProp.hasMixedValue;
            //    //    var alphaClipEnabled = EditorGUILayout.Toggle(Styles.alphaClipText, alphaClipProp.floatValue == 1);
            //    //    if (EditorGUI.EndChangeCheck())
            //    //        alphaClipProp.floatValue = alphaClipEnabled ? 1 : 0;
            //    //    EditorGUI.showMixedValue = false;

            //    //    if (alphaClipProp.floatValue == 1)
            //    //        materialEditor.ShaderProperty(alphaC
            //    //}
            //}

            //public void DrawColorMask(Material material, MaterialEditor materialEditor)
            //{
            //    if ((EAlphaChannelMode)_albedoChannelModeProp.floatValue == EAlphaChannelMode.ColorMask)
            //        materialEditor.ShaderProperty(_maskColorProp, _maskColorText);
            //}

            public void DrawUberMap_SimpleLit(Material material, MaterialEditor materialEditor)
            {
                var hasValidUberMap = false;
                if (material.HasProperty("_UberMap"))
                    hasValidUberMap = material.GetTexture("_UberMap") != null;
                materialEditor.TexturePropertySingleLine(_simpleLitUberMapText, _uberMapProp);
                materialEditor.ShaderProperty(_specColorProp, (hasValidUberMap) ? _specularColorText_A : _specularColorText_B);
                materialEditor.ShaderProperty(_smoothnessProp, (hasValidUberMap) ? _smoothnessText_A : _smoothnessText_B);
                materialEditor.ShaderProperty(_emissionPowerProp, (hasValidUberMap) ? _emissionPowerText_A : _emissionPowerText_B);
                if (hasValidUberMap == true)
                    EditorGUILayout.LabelField(_emptyText);
            }

            public void DrawUberMap_Lit(Material material, MaterialEditor materialEditor)
            {
                var hasValidUberMap = _uberMapProp.textureValue != null;
                
                materialEditor.TexturePropertySingleLine(_litUberMapText, _uberMapProp);
                switch((WorkflowMode)_workflowModeProp.floatValue)
                {
                    case WorkflowMode.Metallic:
                        materialEditor.ShaderProperty(_matallicProp, (hasValidUberMap) ? _matallicText_A : _matallicText_B);
                        break;
                    case WorkflowMode.Specular:
                        materialEditor.ShaderProperty(_specColorProp, (hasValidUberMap) ? _specularColorText_A : _specularColorText_B);
                        break;
                }

                materialEditor.ShaderProperty(_smoothnessProp, (hasValidUberMap) ? _smoothnessText_A : _smoothnessText_B);
                materialEditor.ShaderProperty(_emissionPowerProp, (hasValidUberMap) ? _emissionPowerText_A : _emissionPowerText_B);
                if (hasValidUberMap == true)
                    EditorGUILayout.LabelField(_emptyText);
            }

            public void DrawDyeingMask(Material material, MaterialEditor materialEditor)
            {
                if (material.HasProperty("_DyeingMaskMap"))
                {
                    materialEditor.TexturePropertySingleLine(_dyeingMaskText, _dyeingMaskProp);
                    var hasDyeingMaskMap = material.GetTexture("_DyeingMaskMap") != null;
                    if (hasDyeingMaskMap == true)
                    {
                        materialEditor.ShaderProperty(_dyeing_Color_RProp, _Dyeing_Color_RText);
                        materialEditor.ShaderProperty(_dyeing_Color_GProp, _Dyeing_Color_GText);
                        materialEditor.ShaderProperty(_dyeing_Color_BProp, _Dyeing_Color_BText);
                        materialEditor.ShaderProperty(_dyeing_Color_AProp, _Dyeing_Color_AText);
                    }
                }
            }

            public void Draw(Material material, MaterialEditor materialEditor)
            {   
                var backgroundColorBackup = GUI.backgroundColor;
                GUI.backgroundColor = Color.grey;
                //EditorGUI.BeginDisabledGroup(true);
                {
                    EditorGUILayout.BeginVertical("HelpBox");
                    {
                        EditorGUILayout.LabelField(_StencilStateText);
                        materialEditor.ShaderProperty(_StencilReadMaskProp, _StencilReadMaskText); 
                        materialEditor.ShaderProperty(_StencilRefProp, _StencilRefText);
                        materialEditor.ShaderProperty(_StencilCompProp, _StencilCompText);
                        materialEditor.ShaderProperty(_PassOperationProp, _PassOperationText);
                        materialEditor.ShaderProperty(_FailOperationProp, _FailOperationText);
                        materialEditor.ShaderProperty(_ZFailOperationProp, _ZFailOperationText);
                    }
                    EditorGUILayout.EndVertical();
                }
                //EditorGUI.EndDisabledGroup();
                GUI.backgroundColor = backgroundColorBackup;

                backgroundColorBackup = GUI.backgroundColor;
                GUI.backgroundColor = Color.green;
                EditorGUILayout.BeginVertical("HelpBox");
                {
                    EditorGUILayout.LabelField("Vulcanus");

                    EditorGUI.BeginChangeCheck();
                    {
                        EditorGUI.showMixedValue = _receiveSilhouetteProp.hasMixedValue;
                        _receiveSilhouetteProp.floatValue = EditorGUILayout.Toggle(_receiveSilhouetteText, _receiveSilhouetteProp.floatValue == 1.0f) ? 1 : 0;
                        EditorGUI.showMixedValue = false;

                        EditorGUI.showMixedValue = _receiveSilhouetteProp.hasMixedValue;
                        _receiveDecalProp.floatValue = EditorGUILayout.Toggle(_receiveDecalText, _receiveDecalProp.floatValue == 1.0f) ? 1 : 0;
                        EditorGUI.showMixedValue = false;

                        EditorGUILayout.Space(10);

                        materialEditor.ShaderProperty(_bdrfFersnelRatioProp, _bdrfFersnelRatioText);

                        EditorGUILayout.LabelField(_rimLightLabelText);
                        materialEditor.ShaderProperty(_rimLightColorProp, _rimLightColorText);
                        materialEditor.ShaderProperty(_rimLightPowerProp, _rimLightPowerText);

                        EditorGUI.BeginDisabledGroup(true);
                        {
                            EditorGUILayout.LabelField(_subRimLightLabelText);
                            materialEditor.ShaderProperty(_subRimLightColorProp, _subRimLightColorText);
                            materialEditor.ShaderProperty(_subRimLightPowerProp, _subRimLightPowerText);
                        }
                        EditorGUI.EndDisabledGroup();
                        EditorGUILayout.Space(10);

                        EditorGUILayout.LabelField("Dissolve");
                        EditorGUILayout.Space(10);

                        EditorGUILayout.LabelField("Utility");
                        materialEditor.TexturePropertySingleLine(_utilityMapText, _utilityMapProp);
                        //materialEditor.TextureScaleOffsetProperty(_utilityMapProp);
                        materialEditor.ShaderProperty(_dissolveColorThicknessProp, _dissolveColorThicknessText);
                        materialEditor.ShaderProperty(_dissolveProp, _dissolveText);

                        materialEditor.ShaderProperty(_ditherAlphaProp, _ditherAlphaText);
                        materialEditor.ShaderProperty(_ClippingAreaProp, _AreaClippingText);

                        using (new GUIActiveScope(false))
                            materialEditor.ShaderProperty(_sSClipVariablesProp, _sSClipVariablesText);

                        EditorGUILayout.LabelField("└─Object Swap");
                        materialEditor.ShaderProperty(_SwapObjectRatioProp, _SwapObjectRatioText);
                        materialEditor.ShaderProperty(_SwapObjectSignProp, _SwapObjectSignText);
                        materialEditor.ShaderProperty(_meshXBoundsProp, _meshXBoundsText);
                        EditorGUILayout.Space(10);
                        //materialEditor.ShaderProperty(_disableFogProp, _disableFogText);
                    }
                    if (EditorGUI.EndChangeCheck() == true)
                    {
                        Vulcanus_ShaderValidator.Validate(material);
                    }
                }
                EditorGUILayout.EndVertical();
                GUI.backgroundColor = backgroundColorBackup;
            }
        }
    }

    public struct GUIActiveScope : IDisposable
    {
        private bool _cachedOrigin;
        public GUIActiveScope(bool active)
        {
            _cachedOrigin = GUI.enabled;
            GUI.enabled = active;
        }

        public void Dispose()
        {
            GUI.enabled = _cachedOrigin;
        }
    }
}
