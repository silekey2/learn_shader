Shader "MyShaders/Animator/MyRollBg"
{
	Properties
	{
        _BgTex ("Bg Tex", 2D) = "white" {}
        _FrontTex ("Font Tex", 2D) = "white" {}
        _BgSpeed ("BgSpeed", Float) = 1
        _FrontSpeed ("FrontSpeed", Float) = 1
        _Multipiler("Layer Multipliter", Float) = 1
	}

	SubShader
	{
		Tags { "Queue"="Transparent" "RenderType"="Transparent" "IgnoreProjector" = "True" }
		LOD 100

		Pass
		{
            Tags {" LightMode" = "ForwardBase" }
            ZWrite Off
            //Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _BgTex;
			float4 _BgTex_ST;

            sampler2D _FrontTex;
			float4 _FrontTex_ST;

            float _BgSpeed;      // 背景图片速度
            float _FrontSpeed;   // 前景图片数度
            float _Multipiler;   // 调节亮度
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
                // 移动uv坐标达到移动图片的目的
				o.uv.xy = TRANSFORM_TEX(v.uv0, _BgTex) + float2(frac(_BgSpeed * _Time.y), 0);     
                o.uv.zw = TRANSFORM_TEX(v.uv1, _FrontTex) + float2(frac(_FrontSpeed * _Time.y), 0);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
                float4 bgColor = tex2D(_BgTex, i.uv.xy);
                float4 frontColor = tex2D(_FrontTex, i.uv.zw);
                //float3 color = frontColor.rgb * frontColor.w + (1 - frontColor.w) * bgColor.rgb;
                float3 color = lerp(bgColor.rgb, frontColor.rgb, frontColor.a);
                color *= _Multipiler;
				// sample the texture
				//fixed4 col = tex2D(_MainTex, uv);
				//return col;
                return fixed4(color, 1);
			}
			ENDCG
		}
	}
}
