using UnityEditor;

using UnityEngine;
using UnityEngine.Rendering;

public static class Vulcanus_ShaderValidator
{
    public static readonly int _SrcBlendID = Shader.PropertyToID("_SrcBlend");
    public static readonly int _DstBlendID = Shader.PropertyToID("_DstBlend");
    public static readonly int _ZWriteID = Shader.PropertyToID("_ZWrite");
    public static readonly int _CullID = Shader.PropertyToID("_Cull");
    public static readonly int _SurfaceID = Shader.PropertyToID("_Surface");
    
    public static readonly int _StencilRefID = Shader.PropertyToID("_StencilRef");
    public static readonly int _StencilCompID = Shader.PropertyToID("_StencilComp");
    public static readonly int _PassOperationID = Shader.PropertyToID("_PassOperation");
    public static readonly int _FailOperationID = Shader.PropertyToID("_FailOperation");
    public static readonly int _ZFailOperationID = Shader.PropertyToID("_ZFailOperation");
    
    public static readonly int _ReceiveSilhouetteID = Shader.PropertyToID("_ReceiveSilhouette");
    public static readonly int _ReceiveDecalID = Shader.PropertyToID("_ReceiveDecal");

    public static void Validate(Material material)
    {
        //Validate Stencil State
        {
            var bifFlag = 0;
            var receiveSilhouette = (material.GetFloat(_ReceiveSilhouetteID) == 1) ? true : false;
            bifFlag |= receiveSilhouette ? 0 : 1 << 0;

            var receiveDecal = (material.GetFloat(_ReceiveDecalID) == 1) ? true : false;
            bifFlag |= receiveDecal ? 0 : 1 << 1;

            material.SetFloat(_StencilRefID, bifFlag);
            material.SetFloat(_StencilCompID, (float)CompareFunction.Always);
            material.SetFloat(_PassOperationID, (float)StencilOp.Replace);
            material.SetFloat(_FailOperationID, (float)StencilOp.Keep);
            material.SetFloat(_ZFailOperationID, (float)StencilOp.Keep);
        }

        EditorUtility.SetDirty(material);
    }
}
