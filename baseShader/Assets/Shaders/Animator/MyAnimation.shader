Shader "MyShaders/Animator/MyAnimation"
{
	Properties
	{
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Image Sequence", 2D) = "white" {}
        _HorizontalAmount ("Horizontal  Amount", Float) = 4
        _VerticalAmount ("Vertical Amount", Float) = 4
        _Fps ("Fps", Range(1, 100)) = 30
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

            fixed4    _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
            float _HorizontalAmount; // 多少列
            float _VerticalAmount;   // 多少行
            float _Fps;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
                // Time 4个分量是t/20, t, 2t, 3t
                float frameNum = floor(_Time.y * _Fps); // 计算当前是第几帧

                float rowCount = floor(frameNum / _HorizontalAmount);       // 计算行数
                float colCount = frameNum - rowCount * _HorizontalAmount;   // 计算列数
                rowCount = fmod(rowCount, _VerticalAmount);                 // 

                float2 uv = i.uv + float2(colCount, _VerticalAmount - rowCount - 1);

                uv.x /= _HorizontalAmount;
                uv.y /= _VerticalAmount;

				// sample the texture
				fixed4 col = tex2D(_MainTex, uv);
				return col;
			}
			ENDCG
		}
	}
}
