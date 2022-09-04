Shader "MyShaders/Textures/MyNormalmap"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}  // 漫反色贴图
        _NormalMap("Normal", 2D) = "white" {} // 法线贴图

        _Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _Diffuse("Diffuse", Color) = (1.0, 1.0, 1.0, 1.0)
        _Specular("Specular", Color) = (1.0, 1.0, 1.0, 1.0)

        _BumpScacle("BumpScacle", Float) = 1.0
        _Glow ("Glow", Float) = 1.0
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

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 tangent : TANGENT;   // 切线
                float3 normal : NORMAL;     // 法线
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;        // 对应的纹理坐标
                float3 lightDir : TEXCOORD1;  // 切线空间下的光照方向
                float3 lookDir :  TEXCOORD2;  // 切线空间下的摄像机方向
                float4 vertex : SV_POSITION;  // 裁剪空间下的坐标
            };

            sampler2D _MainTex;
            sampler2D _NormalMap;
            fixed3    _Color;
            fixed3    _Diffuse;
            fixed3    _Specular;
            float     _Glow;
            float    _BumpScacle;
            
            float4 _MainTex_ST;
            //float4 _NormalMap_ST; // 与MainTex使用同一个UV

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                // 获得切线空间的Y坐标
                float3 tangenX = normalize(v.tangent);
                float3 normal = normalize(v.normal);
                float3 tangentY = normalize(cross(tangenX, normal) * v.tangent.w); // 通过W识别切线空间y轴方向 
                float3x3 tangenSpace2object = float3x3(tangenX, tangentY, normal); // 切线空间到模型空间的矩阵
                float3x3 rotation = transpose(tangenSpace2object);                 // 由于只包含旋转, 转置矩阵就是逆矩阵

                // 获得顶点到光照的向量
                float3 lightDir = ObjSpaceLightDir(v.vertex);

                // 获得顶点到观察者方向
                float3 lookDir = ObjSpaceViewDir(v.vertex);

                // 全都转到切线空间中去计算
                o.lightDir = mul(rotation, lightDir);
                o.lookDir = mul(rotation, lookDir);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 l = normalize(i.lightDir);
                float3 v = normalize(i.lookDir);

                // 图片的像素点采样
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 baseNormal = tex2D(_NormalMap, i.uv); // 
                float3 n = UnpackNormal(baseNormal).xyz;
                n.xy *= _BumpScacle;
                n.z = sqrt(1.0 - dot(n.xy, n.xy)); // 保证是一个单位向量

                // 使用漫反射
                // 兰伯特公式
                fixed3 outputColor = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(n, l));

                // 使用高光Blinn
                float3 h = normalize(v + l);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(n, h)), _Glow);
                
                fixed3 albedo = col.rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;

                return fixed4((ambient + outputColor + specular), 1.0);
                //return fixed4(outputColor, 1.0);
            }
            ENDCG
        }
    }
}
