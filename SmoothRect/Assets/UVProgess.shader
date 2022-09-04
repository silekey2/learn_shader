// 通过UV动画完成进度效果
Shader "MyShaders/Animator/UVProgess"
{
	Properties
	{
        _BgTex ("Bg Tex", 2D) = "white" {}
        _Start ("Start", Float) = 0.2
        _Progess ("Progess", Float) = 1
        _Color ("Color", Color) = (1,1,1,1)
	}

	SubShader
	{
		Tags { "Queue"="AlphaTest" "RenderType"="AlphaTest" "IgnoreProjector" = "True" }
		LOD 100

		Pass
		{
            Tags {" LightMode" = "ForwardBase" }
            //ZWrite Off
            //Blend SrcAlpha OneMinusSrcAlpha

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
            float _Start;      // 起始进度位置
            float _Progess;    // 进度
            fixed4 _Color;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _BgTex);// +float2(frac(_BgSpeed * _Time.y), 0);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
                float4 bgColor = tex2D(_BgTex, i.uv);
                float p = fmod(1 + i.uv.x - _Start, 1);
                clip(_Progess - p);
                bgColor = bgColor * _Color;
                return bgColor;
			}
			ENDCG
		}
	}
}
