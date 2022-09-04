
// 包含高光
Shader "MyShaders/MySpecular"
{
    Properties
    {
        //_MainTex ("Texture", 2D) = "white" {}
        _Diffuse ("Diffuse", Color) = (1,1,1,1)
        _Specular ("Specular", Color) = (1,1,1,1)
        _Glow ("Glow", Float) = 1
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
                fixed3 color : COLOR0;
            };

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Glow;
            v2f vert (appdata v)
            {
                // 环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz; 

                v2f o;
                float3 n;
                n = mul((float3x3)unity_ObjectToWorld, v.normal); // 模型空间转为世界空间(向量运算)
                 
                n = normalize(n);                               // 归一化
                float3 l = normalize(_WorldSpaceLightPos0.xyz); // 光照方向
                
                // 兰伯特公式
                fixed3 outputColor = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(n, l));

                // 高光Phong 算法
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex); // 世界空间坐标
                float3 cameraDir = normalize(_WorldSpaceCameraPos.xyz - worldPos.xyz); // 往摄像机方向
                float3 r = 2 * dot(n, l) * n - l;// 反射方向
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(cameraDir, r)), _Glow);
                //fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(0, dot(cameraDir, r)), _Glow);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.color = outputColor + ambient.xyz + specular;
                //o.color = (specular + outputColor) * 0.5 + ambient.xyz * 0.5;
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(i.color, 1.0);
            }
            
            ENDCG
        }
    }

        Fallback "VertexLit"
}
