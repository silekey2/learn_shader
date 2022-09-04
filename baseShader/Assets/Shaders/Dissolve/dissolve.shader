// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "MyShaders/dissolve"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}  // 贴图
        _NoiseTex ("Texture", 2D) = "white" {} // 噪声
        _Volume ("Volume", Range(0, 1)) = 0.1// 程度 
        
        _SkinWidth ("SkinWidth", Range(0, 1)) = 0.1 // 燃烧边缘
        _OutColor ("OutColor", Color) = (1,0,0,1)  // 燃烧外缘颜色
        _InColor ("InColor", Color) = (0,1,0,1)    // 燃烧内缘颜色
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="AlphaTest"}
		LOD 100

		Pass
		{
            //Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
                float3 normal : NORMAL;      // 法线  
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
                //float3 worldPos : TEXCOORD1;
                float2 uvWorld : TEXCOORD1;
				float4 vertex : SV_POSITION;
                
			};

			sampler2D _MainTex;
            sampler2D _NoiseTex;
			float4 _MainTex_ST;
            half _Volume;
            fixed _SkinWidth;
            fixed3 _OutColor;
            fixed3 _InColor;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
                float3 wPos = mul(unity_ObjectToWorld, v.vertex).xyz; 

                // 获取切线up空间在世界中的坐标
                float3x3 matRot = unity_ObjectToWorld;
                float3 n = normalize(mul(matRot, v.normal));

                // Get the closest vector in the polygon's plane to world up.
                // We'll use this as the "v" direction of our texture.
                float3 vDirection = normalize(float3(0,1,0) - n.y * n);

                // Get the perpendicular in-plane vector to use as our "u" direction.
                float3 uDirection = normalize(cross(n, vDirection));

                // 防止法线与x轴垂直 
                if (abs(n.y) > 0.999)
                {
                    vDirection = float3(0,0,-1);
                    uDirection = float3(1,0,0);
                }

                // 根据法线方向调整的UV纹理
                o.uvWorld.x = dot(wPos, uDirection);
                o.uvWorld.y = dot(wPos, vDirection);
                
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			 
			fixed4 frag (v2f i) : SV_Target
			{
				// clip
                fixed3 noiseColor   = tex2D(_NoiseTex, i.uvWorld).rgb;
                float v = noiseColor.r * 3 - 1.5;
                float vv = _Volume * 3 - 1.5;
                clip(v - vv);

                // 目标颜色
                fixed color_a = saturate(v - vv);
                color_a = pow(saturate(color_a / _SkinWidth), 2); //百分比
                fixed3 targetColor = lerp(_OutColor, _InColor, color_a);
                fixed4 col          = tex2D(_MainTex,  i.uvWorld);

                col.rgb = col.rgb * color_a + targetColor * (1 - color_a);
				return col;
			}
			ENDCG
		}
	}
}
