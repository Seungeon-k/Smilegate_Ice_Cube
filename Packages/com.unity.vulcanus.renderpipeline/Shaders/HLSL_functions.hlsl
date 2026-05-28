
#ifndef HLSL_FUNCTIONS
	#define HLSL_FUNCTIONS

	static float mipmapCorrectMin_	= -0.004;
	static float mipmapCorrectMax_	= 0.004;

	#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

	void Unity_Blend_LinearLight_float4(float4 Base, float4 Blend, float Opacity, out float4 Out)
	{
		Out = Blend < 0.50 ? max(Base + (2 * Blend) - 1, 0) : min(Base + 2 * (Blend - 0.50), 1);
		Out = lerp(Base, Out, Opacity);
	}

	void Unity_NormalFromHeight_Tangent_float(float In, float Strength, float3 Position, float3x3 TangentMatrix, out float3 Out)
	{
		float3 worldDerivativeX = ddx(Position);
		float3 worldDerivativeY = ddy(Position);

		float3 crossX = cross(TangentMatrix[2].xyz, worldDerivativeX);
		float3 crossY = cross(worldDerivativeY, TangentMatrix[2].xyz);
		float d = dot(worldDerivativeX, crossY);
		float sgn = d < 0.0 ? (-1.f) : 1.f;
		float surface = sgn / max(0.00000000000001192093f, abs(d));

		float dHdx = ddx(In);
		float dHdy = ddy(In);
		float3 surfGrad = surface * (dHdx*crossY + dHdy * crossX);
		Out = normalize(TangentMatrix[2].xyz - (Strength * surfGrad));
		Out = TransformWorldToTangent(Out, TangentMatrix);
	}

	float2 unity_gradientNoise_dir(float2 p)
	{
		p = p % 289;
		float x = (34 * p.x + 1) * p.x % 289 + p.y;
		x = (34 * x + 1) * x % 289;
		x = frac(x / 41) * 2 - 1;
		return normalize(float2(x - floor(x + 0.50), abs(x) - 0.50));
	}

	float unity_gradientNoise(float2 p)
	{
		float2 ip = floor(p);
		float2 fp = frac(p);
		float d00 = dot(unity_gradientNoise_dir(ip), fp);
		float d01 = dot(unity_gradientNoise_dir(ip + float2(0, 1)), fp - float2(0, 1));
		float d10 = dot(unity_gradientNoise_dir(ip + float2(1, 0)), fp - float2(1, 0));
		float d11 = dot(unity_gradientNoise_dir(ip + float2(1, 1)), fp - float2(1, 1));
		fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
		return lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x);
	}

	void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
	{
		Out = unity_gradientNoise(UV * Scale) + 0.50;
	}

	void Unity_Remap_float4(float4 In, float2 InMinMax, float2 OutMinMax, out float4 Out)
	{
		Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
	}

	void Unity_Remap_float(float In, float2 InMinMax, float2 OutMinMax, out float Out)
	{
	    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
	}

	inline float2 unity_voronoi_noise_randomVector(float2 UV, float offset)
	{
		float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
		UV = frac(sin(mul(UV, m)) * 46839.32);
		return float2(sin(UV.y*+offset)*0.50 + 0.50, cos(UV.x*offset)*0.50 + 0.50);
	}

	void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
	{
		float2 g = floor(UV * CellDensity);
		float2 f = frac(UV * CellDensity);
		float t = 8.0;
		float3 res = float3(8.0, 0.0, 0.0);

		for (int y = -1; y <= 1; y++)
		{
			for (int x = -1; x <= 1; x++)
			{
				float2 lattice = float2(x, y);
				float2 offset = unity_voronoi_noise_randomVector(lattice + g, AngleOffset);
				float d = distance(lattice + offset, f);
				if (d < res.x)
				{
					res = float3(d, offset.x, offset.y);
					Out = res.x;
					Cells = res.y;
				}
			}
		}
	}

	float r(float n)
	{
		return frac(cos(n*89.42)*343.42);
	}

	float2 r(float2 n)
	{
		return float2(r(n.x*23.62 - 300.0 + n.y*34.35), r(n.x*45.13 + 256.0 + n.y*38.89));
	}

	void Fast_Voronoi(float2 UV, float CellDensity, out float Out)
	{
		float dis = 1.0;
		float2 nfl = floor(UV * CellDensity);
		float2 nfr = frac(UV * CellDensity);

		for (int x = -1.0; x < 2.0; x++)
		{
			for (int y = -1.0; y < 2.0; y++)
			{
				float2 p = nfl + float2(x, y);
				float d = length(r(p) + float2(x, y) - nfr);
				dis = min(dis, d);
			}
		}

		Out = dis;
	}

	// 2D random numbers
	float rnd2d(float2 val)
	{
		float e = (val.x*val.y *31.78694 + val.y) % 1;
		return  (e*e*137.21321) % 1;
	}

	void Fast_Voronoi2(float2 UV, float CellDensity, out float Out)
	{
		float2 p = floor(UV * CellDensity);
		float2 f = (UV * CellDensity) % 1;

		float res = 8.0;
		for (int j = -1; j <= 1; j++)
		{
			for (int i = -1; i <= 1; i++)
			{

				float2 r = float2(i, j) - f + rnd2d(p + float2(i, j));
				float d = dot(r, r);
				res = min(res, d);
			}
		}
		Out =  sqrt(res);
	}

	float4 Cellular_weight_samples(float4 samples)
	{
		samples = samples * 2.0 - 1.0;
		return (1.0 - samples * samples) * sign(samples);	// square
		//return (samples * samples * samples) - sign(samples);	// cubic (even more viance)
	}

	void FAST32_hash_2D(float2 gridcell, out float4 hash_0, out float4 hash_1)
	{
		//    gridcell is assumed to be an integer coordinate
		const float2 OFFSET = float2(26.0, 161.0);
		const float DOMAIN = 71.0;
		const float2 SOMELARGEFLOATS = float2(951.135664, 642.949883);
		float4 P = float4(gridcell.xy, gridcell.xy + 1.0);
		P = P - floor(P * (1.0 / DOMAIN)) * DOMAIN;
		P += OFFSET.xyxy;
		P *= P;
		P = P.xzxz * P.yyww;
		hash_0 = frac(P * (1.0 / SOMELARGEFLOATS.x));
		hash_1 = frac(P * (1.0 / SOMELARGEFLOATS.y));
	}

	void Fast_Voronoi3(float2 UV, float CellDensity, out float Out)
	{
		float2 Pi = floor(UV * CellDensity);
		float2 Pf = UV * CellDensity - Pi;

		float4 hash_x, hash_y;
		FAST32_hash_2D(Pi, hash_x, hash_y);

	//	const float JITTER_WINDOW = 0.25;	// 0.25 will guarentee no artifacts.  0.25 is the intersection on x of graphs f(x)=( (0.50+(0.50-x))^2 + (0.50-x)^2 ) and f(x)=( (0.50+x)^2 + x^2 )
	//	hash_x = Cellular_weight_samples(hash_x) * JITTER_WINDOW + float4(0.0, 1.0, 0.0, 1.0);
	//	hash_y = Cellular_weight_samples(hash_y) * JITTER_WINDOW + float4(0.0, 0.0, 1.0, 1.0);

		const float JITTER_WINDOW = 0.4;
		hash_x = hash_x * JITTER_WINDOW * 2.0 + float4(-JITTER_WINDOW, 1.0 - JITTER_WINDOW, -JITTER_WINDOW, 1.0 - JITTER_WINDOW);
		hash_y = hash_y * JITTER_WINDOW * 2.0 + float4(-JITTER_WINDOW, -JITTER_WINDOW, 1.0 - JITTER_WINDOW, 1.0 - JITTER_WINDOW);

		float4 dx = Pf.xxxx - hash_x;
		float4 dy = Pf.yyyy - hash_y;
		float4 d = dx * dx + dy * dy;
		d.xy = min(d.xy, d.zw);
		Out = min(d.x, d.y) *(1.0 / 1.125);	//	scale return value from 0.0->1.125 to 0.0->1.0  ( 0.75^2 * 2.0  == 1.125 )
	}


	/*
	float Falloff_Xsq_C1(float xsq) { xsq = 1.0 - xsq; return xsq * xsq; }

	float4 FAST32_hash_2D_Cell(float2 gridcell)	//	generates 4 different random numbers for the single given cell point
	{
		//	gridcell is assumed to be an integer coordinate
		const float2 OFFSET = float2(26.0, 161.0);
		const float DOMAIN = 71.0;
		const float4 SOMELARGEFLOATS = float4(951.135664, 642.949883, 803.202459, 986.973274);
		float2 P = gridcell - floor(gridcell * (1.0 / DOMAIN)) * DOMAIN;
		P += OFFSET.xy;
		P *= P;
		return frac((P.x * P.y) * (1.0 / SOMELARGEFLOATS.xyzw));
	}

	void Fast_Voronoi3(float2 UV, float CellDensity, out float Out)
	{
		float2 Pi = floor(UV);
		float2 Pf = UV - Pi;

		//	calculate the hash.
		//	( vious hashing methods listed in order of speed )
		float4 hash = FAST32_hash_2D_Cell(Pi);

		//	user viables
		float VALUE = 1.0 - 1 * hash.z;

		//	calc the noise and return
		Pf *= 1;
		Pf -= (1 - 1.0);
		Pf += hash.xy * (1 - 2.0);
		Out = (hash.w < 1) ? (Falloff_Xsq_C1(min(dot(Pf, Pf), 1.0)) * VALUE) : 0.0;
	}
	*/

	inline float unity_noise_randomValue(float2 uv)
	{
		return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
	}

	inline float unity_noise_interpolate(float a, float b, float t)
	{
		return (1.0 - t)*a + (t*b);
	}

	inline float unity_valueNoise(float2 uv)
	{
		float2 i = floor(uv);
		float2 f = frac(uv);
		f = f * f * (3.0 - 2.0 * f);

		uv = abs(frac(uv) - 0.50);
		float2 c0 = i + float2(0.0, 0.0);
		float2 c1 = i + float2(1.0, 0.0);
		float2 c2 = i + float2(0.0, 1.0);
		float2 c3 = i + float2(1.0, 1.0);
		float r0 = unity_noise_randomValue(c0);
		float r1 = unity_noise_randomValue(c1);
		float r2 = unity_noise_randomValue(c2);
		float r3 = unity_noise_randomValue(c3);

		float bottomOfGrid = unity_noise_interpolate(r0, r1, f.x);
		float topOfGrid = unity_noise_interpolate(r2, r3, f.x);
		float t = unity_noise_interpolate(bottomOfGrid, topOfGrid, f.y);
		return t;
	}

	void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
	{
		float t = 0.0;

		float freq = pow(2.0, float(0));
		float amp = pow(0.50, float(3 - 0));
		t += unity_valueNoise(float2(UV.x*Scale / freq, UV.y*Scale / freq))*amp;

		freq = pow(2.0, float(1));
		amp = pow(0.50, float(3 - 1));
		t += unity_valueNoise(float2(UV.x*Scale / freq, UV.y*Scale / freq))*amp;

		freq = pow(2.0, float(2));
		amp = pow(0.50, float(3 - 2));
		t += unity_valueNoise(float2(UV.x*Scale / freq, UV.y*Scale / freq))*amp;

		Out = t;
	}

	void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
	{
		Out = UV * Tiling + Offset;
	}

	float3 DirectSpecular(float smoothness, float3 direction, float3 worldNormal, float3 worldView)
	{
		float4 White = 1;

		smoothness = exp2(10 * smoothness + 1);
		worldNormal = normalize(worldNormal);
		worldView = SafeNormalize(worldView);
		return LightingSpecular(White.rgb, direction, worldNormal, worldView, White, smoothness);
	}

	void AdditionalLights(float Smoothness, float3 WorldPosition, float3 WorldNormal, float3 WorldView, out float3 Diffuse, out float3 Specular)
	{
		float3 diffuseColor = 0;
		float3 specularColor = 0;
		float4 White = 1;

		Smoothness = exp2(10 * Smoothness + 1);
		WorldNormal = normalize(WorldNormal);
		WorldView = SafeNormalize(WorldView);
		int pixelLightCount = GetAdditionalLightsCount();
		for (int i = 0; i < pixelLightCount; ++i)
		{
			Light light = GetAdditionalLight(i, WorldPosition);
			half3 attenuatedLightColor = light.color * (light.distanceAttenuation * light.shadowAttenuation);
			diffuseColor += LightingLambert(attenuatedLightColor, light.direction, WorldNormal);
			specularColor += LightingSpecular(attenuatedLightColor, light.direction, WorldNormal, WorldView, White, Smoothness);
		}

		Diffuse = diffuseColor;
		Specular = specularColor;
	}

	float2 DecodeUV(float value)
	{
		static const float bit12 = (1 << 12), ibit12 = 1.0 / bit12;
		static const float bit11 = (1 << 11), ibit11 = 1.0 / bit11;

		float2 v;
		v.x = floor(value * ibit12);
		v.y = (value - v.x * bit12);
		v *= ibit11;

		return v;
	}

	inline float3 GetRGB24Color(float packedColor)
	{
		float fR = floor(packedColor * (1.0 / (1<<8)));
		packedColor = packedColor - (fR * (1<<8));

		float fG = floor(packedColor * (1.0 / (1<<4)));
		packedColor = packedColor - (fG * (1<<4));

		float fB = floor(packedColor);
		return float3(fR, fG, fB) * (1.0 / 15);
	}

	inline void GetUnPacked_LightColor(float fInput, out float3 torchColor, out float torchLight, out float blockLight)
	{
		static const float bit12 = (1<<12), ibit12 = 1.0/(1<<12);
		static const float bit06 = (1<<6), ibit06 = 1.0/(1<<6);

		float bitColor = floor(fInput * ibit12);
		torchColor = GetRGB24Color(bitColor);
		
		float Lower12bit = fInput - (bitColor * bit12);

		float bitTorchLight = floor(Lower12bit * ibit06);
		float bitBlockLight = Lower12bit - (bitTorchLight * bit06);
		
		bitBlockLight = floor(bitBlockLight);

		torchLight = bitTorchLight / 63.0;
		blockLight = bitBlockLight / 63.0;
	}

	inline void GetUnPacked_BlockAni(float fInput, out float aniFrame, out float skipFrame, out float textureSize, out float whiffleFactor)
	{
		static const float bit24 = (1<<24), ibit24 = 1.0/(1<<24);
		static const float bit16 = (1<<16), ibit16 = 1.0/(1<<16);
		static const float bit08 = (1<<8), ibit08 = 1.0/(1<<8);

		aniFrame = floor(fInput * ibit24);
		float Lower24bit = fInput - (aniFrame * bit24);

		skipFrame = floor(Lower24bit * ibit16);
		float Lower16bit = floor(Lower24bit - (skipFrame * bit16));

		textureSize = floor(Lower16bit * ibit08);
		whiffleFactor = Lower16bit - (textureSize * bit08);
		
		textureSize *= 16; //Compressing
		textureSize *= (1.0 / 2048);
	}

	float3 GetDiffuseAndShadow(Light mainLight, float3 normal, float ambient, float3 shadowColorDark, float3 shadowColorBright, float dayPower)
	{
		float ndotl = saturate(dot(normalize(_MainLightPosition.xyz), normal));
		float shadowStrength = ndotl * mainLight.shadowAttenuation * mainLight.distanceAttenuation + ambient;
		float3 shadowColor = shadowColorDark - (shadowStrength * dayPower * (shadowColorDark - shadowColorBright));
		
		return shadowColor * _MainLightColor.rgb * 1.8;  // 1.8 => AdditionalLights Value
	}

	float3 GetSpecular(Light mainLight, float3 normal, float3 viewDir, float specTex, float dayPower )
	{
		float3 specColor = DirectSpecular(0.50, mainLight.direction, normal, viewDir);
		specColor = specColor * _MainLightColor.rgb * specTex;

		return lerp(float3(0, 0, 0), specColor, dayPower);
	}

	void Unity_Rotate_Degrees_float(float2 UV, float2 Center, float Rotation, out float2 Out)
	{
		Rotation = Rotation * (3.1415926f/180.0f);
		UV -= Center;
		float s = sin(Rotation);
		float c = cos(Rotation);
		float2x2 rMatrix = float2x2(c, -s, s, c);
		rMatrix *= 0.50;
		rMatrix += 0.50;
		rMatrix = rMatrix * 2 - 1;
		UV.xy = mul(UV.xy, rMatrix);
		UV += Center;
		Out = UV;
	}

	void Unity_Rotate_Radians_float(float2 UV, float2 Center, float Rotation, out float2 Out)
	{
	    UV -= Center;
	    float s = sin(Rotation);
	    float c = cos(Rotation);
	    float2x2 rMatrix = float2x2(c, -s, s, c);
	    rMatrix *= 0.50;
	    rMatrix += 0.50;
	    rMatrix = rMatrix * 2 - 1;
	    UV.xy = mul(UV.xy, rMatrix);
	    UV += Center;
	    Out = UV;
	}

	void Unity_Saturation_float(float3 In, float Saturation, out float3 Out)
	{
	    float luma = dot(In, float3(0.2126729, 0.7151522, 0.0721750));
	    Out =  luma.xxx + Saturation.xxx * (In - luma.xxx);
	}

	//void Unity_BakedGI_float(float3 Position, float3 Normal, float2 StaticUV, float2 DynamicUV, out float Out)
	//{
	//    Out = SHADERGRAPH_BAKED_GI(Position, Normal, StaticUV, DynamicUV, false);
	//}

	void Unity_ReflectionProbe_float(float3 ViewDir, float3 Normal, float LOD, out float3 Out)
	{
	    Out = SHADERGRAPH_REFLECTION_PROBE(ViewDir, Normal, LOD);
	}

	void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
	{
	    Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
	}

	#define UP_VECTOR float3(0,1,0)
	float GetSlope(float3 normalWS, float threshold)
	{
		return 1-smoothstep(1.0 - threshold, 1.0, saturate(dot(UP_VECTOR, normalWS)));
	}

	void Unity_NormalStrength_float(float3 In, float Strength, out float3 Out)
	{
	    Out = float3(In.rg * Strength, lerp(1, In.b, saturate(Strength)));
	}

	void Unity_NormalBlend_float(float3 A, float3 B, out float3 Out)
	{
	    Out = normalize(float3(A.rg + B.rg, A.b * B.b));
	}

	float3 mod289(float3 x) {
		return x - floor(x * (1.0 / 289.0)) * 289.0;
	}

	float4 mod289(float4 x) {
		return x - floor(x * (1.0 / 289.0)) * 289.0;
	}

	float4 permute(float4 x) {
		return mod289(((x*34.0)+1.0)*x);
	}

	float4 taylorInvSqrt(float4 r)
	{
		return 1.79284291400159 - 0.85373472095314 * r;
	}

	float snoise(float3 v)
	{ 
		const float2  C = float2(1.0/6.0, 1.0/3.0) ;
		const float4  D = float4(0.0, 0.50, 1.0, 2.0);

		// First corner
		float3 i  = floor(v + dot(v, C.yyy) );
		float3 x0 =   v - i + dot(i, C.xxx) ;

		// Other corners
		float3 g = step(x0.yzx, x0.xyz);
		float3 l = 1.0 - g;
		float3 i1 = min( g.xyz, l.zxy );
		float3 i2 = max( g.xyz, l.zxy );

		//   x0 = x0 - 0.0 + 0.0 * C.xxx;
		//   x1 = x0 - i1  + 1.0 * C.xxx;
		//   x2 = x0 - i2  + 2.0 * C.xxx;
		//   x3 = x0 - 1.0 + 3.0 * C.xxx;
		float3 x1 = x0 - i1 + C.xxx;
		float3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
		float3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.50 = -D.y

		// Permutations
		i = mod289(i); 
		float4 p = permute( permute( permute( 
					i.z + float4(0.0, i1.z, i2.z, 1.0 ))
				+ i.y + float4(0.0, i1.y, i2.y, 1.0 )) 
				+ i.x + float4(0.0, i1.x, i2.x, 1.0 ));

		// Gradients: 7x7 points over a square, mapped onto an octahedron.
		// The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
		float n_ = 0.142857142857; // 1.0/7.0
		float3  ns = n_ * D.wyz - D.xzx;

		float4 j = p - 49.0 * floor(p * ns.z * ns.z);  //  mod(p,7*7)

		float4 x_ = floor(j * ns.z);
		float4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

		float4 x = x_ *ns.x + ns.yyyy;
		float4 y = y_ *ns.x + ns.yyyy;
		float4 h = 1.0 - abs(x) - abs(y);

		float4 b0 = float4( x.xy, y.xy );
		float4 b1 = float4( x.zw, y.zw );

		//float4 s0 = float4(lessThan(b0,0.0))*2.0 - 1.0;
		//float4 s1 = float4(lessThan(b1,0.0))*2.0 - 1.0;
		float4 s0 = floor(b0)*2.0 + 1.0;
		float4 s1 = floor(b1)*2.0 + 1.0;
		float4 sh = -step(h, float4(0,0,0,0));

		float4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
		float4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

		float3 p0 = float3(a0.xy,h.x);
		float3 p1 = float3(a0.zw,h.y);
		float3 p2 = float3(a1.xy,h.z);
		float3 p3 = float3(a1.zw,h.w);

		//Normalise gradients
		float4 norm = taylorInvSqrt(float4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
		p0 *= norm.x;
		p1 *= norm.y;
		p2 *= norm.z;
		p3 *= norm.w;

		// Mix final noise value
		float4 m = max(0.6 - float4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
		m = m * m;
		return 42.0 * dot( m*m, float4( dot(p0,x0), dot(p1,x1), dot(p2,x2), dot(p3,x3) ) );
	}
#endif