// Upgrade NOTE: upgraded instancing buffer 'MyProperties' to new syntax.

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/MyBillboard" // Shader名字
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1) 
        _Value("Value", Range(0, 1)) = 1 // 是否固定Y轴, 1表示不固定, 0表示固定
    }

        // 一个效果
    SubShader
    {
        //Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }// "DisableBatching" = "True" }
            Tags { "RenderType" = "Opaque" }
        LOD 100

        // 一个完整的渲染流程
        Pass
        {
    	    ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            //Cull Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            //#pragma multi_compile_fog
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"


            sampler2D   _MainTex;
            fixed4      _MainTex_ST;
            //fixed4      _Color;
            float       _Value;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;       
                float4 vertex : SV_POSITION;  
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            UNITY_INSTANCING_BUFFER_START(MyProperties)
            UNITY_DEFINE_INSTANCED_PROP(fixed4,  _Color)
#define _Color_arr MyProperties
                //            UNITY_DEFINE_INSTANCED_PROP(fixed4, _Value)
                //#define _Value_arr MyProperties
            UNITY_INSTANCING_BUFFER_END(MyProperties)


            v2f vert(appdata v ) {

                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);


                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                float4 center = float4(0, 0, 0, 1);
                float3 forward = -normalize(ObjSpaceViewDir(center)); // 模型空间中心点到摄像机方向的向量 作为z轴(normal)
                forward.y = forward.y * _Value;// UNITY_ACCESS_INSTANCED_PROP(_Value_arr, _Value);
                //float3 up = abs(forward.y) > 0.99f ? float3(0, 0, 1) : float3(0, 1, 0);                  // Y轴
                float3 up = float3(0, 1, 0);                  // Y轴
                float3 right = normalize(cross(up, forward)); // x轴
                float3 up0 = normalize(cross(forward, right));           // 重新获取up

                //v.vertex // 模型空间变换到
                float3x3 ptoc = float3x3 (right.x, up0.x, forward.x,
                                          right.y, up0.y, forward.y,
                                          right.z, up0.z, forward.z);

                float3 newPos = mul(ptoc, v.vertex.xyz);
                o.vertex = UnityObjectToClipPos(newPos);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
                UNITY_SETUP_INSTANCE_ID(i);
                fixed4 col = tex2D(_MainTex, i.uv);
                return col * UNITY_ACCESS_INSTANCED_PROP(_Color_arr, _Color);
                //return fixed4(1.0, 1.0, 0.0, 1.0); // 返回纯色
            }

            ENDCG
        }
    }

	Fallback "VertexLit"
}
