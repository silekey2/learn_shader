// 3D 透视效果
Shader "MyShaders/CharacterXRay"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
        _Pow ("Pow", Range(1, 3)) = 1
        _Color("Color", Color) = (1, 1, 1, 1)
	}

    CGINCLUDE
        #include "UnityCG.cginc"

		struct appdata
		{
			float4 vertex : POSITION;
			float2 uv : TEXCOORD0;
            float3 normal : NORMAL;
		};

		struct v2f
		{
			float2 uv : TEXCOORD0;
			float4 vertex : SV_POSITION;
		};

        struct v2f_xray
		{
			fixed4 color : TEXCOORD0;
			float4 vertex : SV_POSITION;
		};


		sampler2D _MainTex;
		float4 _MainTex_ST;
        float  _Pow;
        fixed4 _Color;
		
			
    ENDCG

	SubShader
	{
		Tags { "RenderType"="Opaque" }
        Tags{ "Queue" = "Transparent+100" "RenderType" = "OpaqueSilekey" }
		LOD 100
		Pass 
		{
            Blend SrcAlpha OneMinusSrcAlpha
            ZTest   Greater // 深度大于Z缓存就通过
            ZWrite  Off

            Stencil {
                Ref 1
                Comp NotEqual
                ZFail Replace
            }

			CGPROGRAM  
			#pragma vertex vert_xray
			#pragma fragment frag
            v2f_xray vert_xray (appdata v)
		    {
			    v2f_xray o;
			    o.vertex = UnityObjectToClipPos(v.vertex);
                o.color = _Color;

                float3 viewDir = normalize(ObjSpaceViewDir(v.vertex));
                //o.color.a = pow(1 - saturate(dot(v.normal, viewDir)), _Pow);
                o.color.a = 1 - saturate(dot(v.normal, viewDir));
                //o.color.rgb = o.color.rgb * o.color.a;
			    return o; 
		    }

            fixed4 frag (v2f_xray i) : SV_Target
		    {
			    fixed4 col = i.color;//tex2D(_MainTex, i.uv);
                //clip(-1);
			    return col;
		    }
			ENDCG
		}

        Pass
        {
            ZWrite On          // 对深度缓存不写入
            ZTest  LEqual      // 使用正常的

            CGPROGRAM
			#pragma vertex vert
            #pragma fragment frag

            v2f vert (appdata v)
		    {
			    v2f o;
			    o.vertex = UnityObjectToClipPos(v.vertex);
			    o.uv     = TRANSFORM_TEX(v.uv, _MainTex);
			    return o;
		    }

            fixed4 frag (v2f i) : SV_Target
            {
			    fixed4 col = tex2D(_MainTex, i.uv);
			    return col;
            }
            ENDCG
        }

	}
}
