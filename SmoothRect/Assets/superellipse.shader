Shader "MyShaders/superellipse"
{
	Properties
	{
        _Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
        _N("N", Float) = 5.0
        _A("A", Float) = 1.0
        _B("B", Float) = 1.0
        _Inter("Inter", Range(0, 1)) = 0
        _Angle("Angle", Float) = 1.0
	}

	SubShader
	{
        Tags { "Queue" = "AlphaTest" "RenderType" = "AlphaTest" "IgnoreProjector" = "True" }
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
			//#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
                float3 mPos : TEXCOORD1;        // 模型控件下的坐标
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
            fixed4 _Color;
            float _N;
            float _A;
            float _B;
            float _Angle;
            float _PI = 3.1415926;
            float _Inter;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
                o.mPos = v.vertex;
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				//UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
                /*
                float2 v = i.uv;// -float2(0.5, 0.5);
                v.x = 2 * v.x - 1;
                v.y = 2 * v.y - 1;
                float ret = pow(abs(v.x), _N) + pow(abs(v.y), _N);
                fixed4 c = _Color;
                clip(1 - ret);

                float interValue = pow(_Inter, _N);
                clip(ret - interValue);
                */
                float2 v = i.mPos.xy;
                v.x = 2 * v.x;
                v.y = 2 * v.y;
                float ret = pow(abs(v.x), _N) + pow(abs(v.y), _N);
                fixed4 c;
                c.rgb = i.mPos + ret;
                //c.a = ret;
                clip(1 - ret);

                float interValue = pow(_Inter, _N);
                clip(ret - interValue);

                /*
                float2 n = norma lize(v); // 归一化
                float cosAngle = acos(dot(n, float2(0, 1)));
                clip(_Angle - cosAngle);
                */
                return c;
			}
			ENDCG
		}
	}
}
