#ifndef PIXEL_CANVAS_GLOBAL
#define UNIVERSAL_PIPELINE_PIXEL_CANVAS_GLOBAL

float4 _BrushColor;
float4 _Parameters0;        // x : prv x | y : prv y | cur x | y : cur y  
float4 _Parameters1;        // x : Seed Texture Width | y: Seed Texture Height | z : Upscaled Width | w : Upsccaled Height
float4 _BrushStyle;
float4 _PrvPartition;       //x : minX | y : minY | z : maxX | w : MaxY
float4 _Partition;          //x : minX | y : minY | z : maxX | w : MaxY
float  _PartitionLock;
float  _PartitionChangedTime;
float4 _RaycastPositionWS;  
float4 _PrvRaycastPositionWS;  

#define _PrvPosition            _Parameters0.xy
#define _CurPosition            _Parameters0.zw
#define _SeedTextureSize        _Parameters1.xy
#define _UpscaledTextureSize    _Parameters1.zw
#define _BrushThickness         _BrushStyle.x
#define _BrushSoftness          _BrushStyle.y
#define _BrushFlow              _BrushStyle.z
#define _BrushIndicatorVisible  _BrushStyle.w
#define _PrvPartitionMin        _PrvPartition.xy
#define _PrvPartitionMax        _PrvPartition.zw
#define _PartitionMin           _Partition.xy
#define _PartitionMax           _Partition.zw

#define _ToInteger  10000000

Texture2D _SeedTex;
SamplerState sampler_SeedTex;

Texture2D _UVOutlineTex;
SamplerState sampler_UVOutlineTex;

Texture2D _BrushProjectorDepthTex;
SamplerState sampler_BrushProjectorDepthTex;

uniform RWStructuredBuffer<uint> _RWClosestUVDistance   : register(u1); 
uniform RWTexture2D<float4> _RWDrawingLayer             : register(u2);

static const int2 BRUSH_INDICATOR_OFFSET[] = { int2(-1, 0), int2(0, 0), int2(1, 0), int2(0, -1), int2(0, 1)};

void ClipPartition(float2 uv)
{
    clip(uv.x - _PartitionMin.x);
    clip(uv.y - _PartitionMin.y);
    clip(_PartitionMax.x - uv.x);
    clip(_PartitionMax.y - uv.y);
}


#endif //PIXEL_CANVAS_GLOBAL
