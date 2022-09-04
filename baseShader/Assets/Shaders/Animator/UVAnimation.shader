﻿Shader "MyShaders/Animator/UVAnimation"
{
	Properties
	{
        _BgTex ("Bg Tex", 2D) = "white" {}
        _BgSpeed ("BgSpeed", Float) = 1
	}

	SubShader
	{
		Tags { "Queue"="Transparent" "RenderType"="Transparent" "IgnoreProjector" = "True" }
		LOD 100

		Pass
		{
            Tags {" LightMode" = "ForwardBase" }
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _BgTex;
			float4 _BgTex_ST;
            float _BgSpeed;      // 背景图片速度
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
                // 移动uv坐标达到移动图片的目的
				o.uv = TRANSFORM_TEX(v.uv, _BgTex) + float2(frac(_BgSpeed * _Time.y), 0);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
                float4 bgColor = tex2D(_BgTex, i.uv);
                //float4 frontColor = tex2D(_FrontTex, i.uv.zw);
                //float3 color = frontColor.rgb * frontColor.w + (1 - frontColor.w) * bgColor.rgb;
                //float3 color = lerp(bgColor.rgb, frontColor.rgb, frontColor.a);
                //color *= _Multipiler;
				// sample the texture
				//fixed4 col = tex2D(_MainTex, uv);
				//return col;
                return bgColor;
			}
			ENDCG
		}
	}
}
