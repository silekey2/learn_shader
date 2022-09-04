// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// 逐像素实现漫反射
Shader "MyShaders/MyDiffuseFrag"
{
    Properties
    {
        //_MainTex ("Texture", 2D) = "white" {}
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags {"LightMode" = "ForwardBase"}

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            //#pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;   // 位置
                float3 normal : NORMAL;     // 法线
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;  // 将法线传过来
                //fixed3 color : COLOR0;
            };

            fixed4 _Diffuse;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = v.normal;
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                // 环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                fixed3 n = normalize(mul((float3x3)unity_ObjectToWorld, i.normal));   // 模型空间转为世界空间
                fixed3 l = normalize(_WorldSpaceLightPos0.xyz);             // 光照方向
                fixed3 outputColor = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(n, l));
                
                return fixed4(outputColor + ambient, 1.0);
            }
            
            ENDCG
        }
    }

        Fallback "VertexLit"
}
