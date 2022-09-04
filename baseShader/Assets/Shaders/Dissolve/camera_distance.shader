Shader "MyShaders/camera_distance"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
        _MaxDistance ("MaxDistance", Float) = 3
        _Pow         ("Pow", Float) = 1

	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
            //Blend SrcAlpha OneMinusSrcAlpha
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
                float4 viewColor : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
            float  _MaxDistance;
			float _Pow;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
                o.viewColor = o.vertex;//mul(UNITY_MATRIX_MV, v.vertex); // 转换到观察空间
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
                float4 pos = i.viewColor;
                //pos.w = 1;

                //pos = UnityObjectToClipPos(pos);
                float color = length(pos.xy) / pos.w;//i.vertex.xy;//pow(length(i.vertex.xy) / _MaxDistance, _Pow);
                float c = 1 - saturate(color);
                return fixed4(c, c, c, c);
				//return col;
			}
			ENDCG
		}
	}
}
