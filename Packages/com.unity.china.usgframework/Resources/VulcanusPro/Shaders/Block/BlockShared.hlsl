#ifndef BLOCK_SHARED_INCLUDED
#define BLOCK_SHARED_INCLUDED

#define COMPUTE_EYEDEPTH(o) o = -mul( UNITY_MATRIX_MV, v.vertex ).z
#define UNITY_PROJ_COORD(a) a
#define SAMPLE_DEPTH_TEXTURE_PROJ(sampler, uv) (tex2Dproj(sampler, uv).r)

half4 SampleSpecularSmoothness(half alpha, half4 specColor)
{
	half4 specularSmoothness = half4(0.0h, 0.0h, 0.0h, 1.0h);
	specularSmoothness = specColor;
	specularSmoothness.a = exp2(10 * 0 + 1);

	return specularSmoothness;
}

float4 ComputeGrabScreenPos(float4 pos)
{
#if UNITY_UV_STARTS_AT_TOP
	float scale = -1.0;
#else
	float scale = 1.0;
#endif
	float4 o = pos * 0.5f;
	o.xy = float2(o.x, o.y * scale) + o.w;
#ifdef UNITY_SINGLE_PASS_STEREO
	o.xy = TransformStereoScreenSpaceTex(o.xy, pos.w);
#endif
	o.zw = pos.zw;
	return o;
}

inline half3 WorldNormal(half3 t0, half3 t1, half3 t2, half3 bump)
{
	return normalize(half3(dot(t0, bump), dot(t1, bump), dot(t2, bump)));
}

inline float4 OffsetDepth(float4 uv, float2 offset)
{
	uv.xy = offset * uv.z + uv.xy;
	return uv;
}

#endif