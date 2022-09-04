// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "MyShaders/dissolve_view"
{
	Properties
	{
        _Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
        _Distance("distance", Float) = 1.0 // 距离

        _Volume("Volume", Range(0,1)) = 0
        _SkinWidth ("SkinWidth", Range(0, 1)) = 0.1 // 燃烧边缘
        _OutColor ("OutColor", Color) = (1,0,0,1)  // 燃烧外缘颜色
        _InColor ("InColor", Color) = (0,1,0,1)    // 燃烧内缘颜色

		_Octaves("Octaves", Float) = 1
		_Frequency("Frequency", Float) = 2.0
		_Amplitude("Amplitude", Float) = 1.0
		_Lacunarity("Lacunarity", Float) = 1
		_Persistence("Persistence", Float) = 0.8
		_Offset("Offset", Vector) = (0.0, 0.0, 0.0, 0.0)
		_Size("Radius", Range(0,3)) = 2.04
		_Intensity("Intensity", Range(0,1)) = 1.0
	}

    CGINCLUDE
			//
			//	FAST32_hash
			//	A very fast hashing function.  Requires 32bit support.

			//	The hash formula takes the form....
			//	hash = mod( coord.x * coord.x * coord.y * coord.y, SOMELARGEFLOAT ) / SOMELARGEFLOAT
			//	We truncate and offset the domain to the most interesting part of the noise.
			//	SOMELARGEFLOAT should be in the range of 400.0->1000.0 and needs to be hand picked.  Only some give good results.
			//	3D Noise is achieved by offsetting the SOMELARGEFLOAT value by the Z coordinate
			//
			void FAST32_hash_3D(float3 gridcell,
				out float4 lowz_hash_0,
				out float4 lowz_hash_1,
				out float4 lowz_hash_2,
				out float4 highz_hash_0,
				out float4 highz_hash_1,
				out float4 highz_hash_2)		//	generates 3 random numbers for each of the 8 cell corners
		{
			//    gridcell is assumed to be an integer coordinate

			//	TODO: 	these constants need tweaked to find the best possible noise.
			//			probably requires some kind of brute force computational searching or something....
			const float2 OFFSET = float2(50.0, 161.0);
			const float DOMAIN = 69.0;
			const float3 SOMELARGEFLOATS = float3(635.298681, 682.357502, 668.926525);
			const float3 ZINC = float3(48.500388, 65.294118, 63.934599);

			//	truncate the domain
			gridcell.xyz = gridcell.xyz - floor(gridcell.xyz * (1.0 / DOMAIN)) * DOMAIN;
			float3 gridcell_inc1 = step(gridcell, float3(DOMAIN - 1.5, DOMAIN - 1.5, DOMAIN - 1.5)) * (gridcell + 1.0);

			//	calculate the noise
			float4 P = float4(gridcell.xy, gridcell_inc1.xy) + OFFSET.xyxy;
			P *= P;
			P = P.xzxz * P.yyww;
			float3 lowz_mod = float3(1.0 / (SOMELARGEFLOATS.xyz + gridcell.zzz * ZINC.xyz));
			float3 highz_mod = float3(1.0 / (SOMELARGEFLOATS.xyz + gridcell_inc1.zzz * ZINC.xyz));
			lowz_hash_0 = frac(P * lowz_mod.xxxx);
			highz_hash_0 = frac(P * highz_mod.xxxx);
			lowz_hash_1 = frac(P * lowz_mod.yyyy);
			highz_hash_1 = frac(P * highz_mod.yyyy);
			lowz_hash_2 = frac(P * lowz_mod.zzzz);
			highz_hash_2 = frac(P * highz_mod.zzzz);
		}
		//
		//	Interpolation functions
		//	( smoothly increase from 0.0 to 1.0 as x increases linearly from 0.0 to 1.0 )

		float3 Interpolation_C2(float3 x) { return x * x * x * (x * (x * 6.0 - 15.0) + 10.0); }
		//
		//	Perlin Noise 3D  ( gradient noise )
		//	Return value range of -1.0->1.0

		float Perlin3D(float3 P)
		{
			//	establish our grid cell and unit position
			float3 Pi = floor(P);
			float3 Pf = P - Pi;
			float3 Pf_min1 = Pf - 1.0;

			//
			//	classic noise.
			//	requires 3 random values per point.  with an efficent hash function will run faster than improved noise
			//

			//	calculate the hash.
			//	( various hashing methods listed in order of speed )
			float4 hashx0, hashy0, hashz0, hashx1, hashy1, hashz1;
			FAST32_hash_3D(Pi, hashx0, hashy0, hashz0, hashx1, hashy1, hashz1);

			//	calculate the gradients
			float4 grad_x0 = hashx0 - 0.49999;
			float4 grad_y0 = hashy0 - 0.49999;
			float4 grad_z0 = hashz0 - 0.49999;
			float4 grad_x1 = hashx1 - 0.49999;
			float4 grad_y1 = hashy1 - 0.49999;
			float4 grad_z1 = hashz1 - 0.49999;
			float4 grad_results_0 = rsqrt(grad_x0 * grad_x0 + grad_y0 * grad_y0 + grad_z0 * grad_z0) * (float2(Pf.x, Pf_min1.x).xyxy * grad_x0 + float2(Pf.y, Pf_min1.y).xxyy * grad_y0 + Pf.zzzz * grad_z0);
			float4 grad_results_1 = rsqrt(grad_x1 * grad_x1 + grad_y1 * grad_y1 + grad_z1 * grad_z1) * (float2(Pf.x, Pf_min1.x).xyxy * grad_x1 + float2(Pf.y, Pf_min1.y).xxyy * grad_y1 + Pf_min1.zzzz * grad_z1);

			//	Classic Perlin Interpolation
			float3 blend = Interpolation_C2(Pf);
			float4 res0 = lerp(grad_results_0, grad_results_1, blend.z);
			float2 res1 = lerp(res0.xy, res0.zw, blend.y);
			float final = lerp(res1.x, res1.y, blend.x);
			final *= 1.1547005383792515290182975610039;		//	(optionally) scale things to a strict -1.0->1.0 range    *= 1.0/sqrt(0.75)
			return final;
		}
		float PerlinNormal(float3 p, int octaves, float3 offset, float frequency, float amplitude, float lacunarity, float persistence)
		{
			float sum = 0;
			for (int i = 0; i < octaves; i++)
			{
				float h = 0;
				h = Perlin3D((p + offset) * frequency);
				sum += h*amplitude;
				frequency *= lacunarity;
				amplitude *= persistence;
			}
			return sum;
		}

		ENDCG

	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="AlphaTest" }
		LOD 100

		Pass
		{
            Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
                
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float4 clipPos : TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

            float _Distance;

            half _Volume;
            fixed4 _Color;
            fixed _SkinWidth;
            fixed3 _OutColor;
            fixed3 _InColor;

            fixed _Octaves;
		    float _Frequency;
		    float _Amplitude;   
		    float3 _Offset;
		    float _Lacunarity;
		    float _Persistence;
            
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.clipPos = o.vertex;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //float c = PerlinNormal(o.vertex.xyz, _Octaves, _Offset, _Frequency, _Amplitude, _Lacunarity, _Persistence);
				//o.noiseColor = fixed4(c,c,c,1);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
                float c = PerlinNormal(i.worldPos, _Octaves, _Offset, _Frequency, _Amplitude, _Lacunarity, _Persistence);
                float volume = _Volume;
                
                // 距离
                float4 worldPos;
                worldPos.xyz = i.worldPos;
                worldPos.w = 1;
                float4 viewPos = mul(UNITY_MATRIX_V, worldPos);
                float view_distance = 1 - pow(length(viewPos.z) / _Distance, 3); // a <= b 1 : 0
                volume *= view_distance;

                // 视图
                //float4 clipPos = mul(UNITY_MATRIX_VP, worldPos);
                float screen_value = 1 - saturate(length(i.clipPos.xy) / i.clipPos.w);
                //float screen_value = 1 - saturate(length(clipPos.xy) / clipPos.w);
                volume *= pow(screen_value, 0.5);
                
                // 随机计算
                float v = volume * 3 -  1.5; // 设定值在[-1.5,1.5] 区间内
                float diffValue = c - v;
                clip(c - v);
                                

                // 溶解效果
                fixed color_a = saturate(c - v);
                color_a = pow(saturate(color_a / _SkinWidth), 2); //百分比
                fixed3 targetColor = lerp(_OutColor, _InColor, color_a);

                // 计算最终突破
                fixed4 col = tex2D(_MainTex,  i.uv); // 贴图
                col *= _Color;
                col.rgb = col.rgb * color_a + targetColor * (1 - color_a);

                return col;
			}
			ENDCG
		}
	}
}
