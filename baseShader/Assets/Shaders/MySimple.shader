// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/MySimple" // Shader名字
{
    Properties{
        _Color("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
    }

	// 一个效果
    SubShader 
    {
        Tags { "RenderType" = "Opaque" }

		// 一个完整的渲染流程
        Pass 
        {
            CGPROGRAM // 表示下面是CG代码
            #pragma vertex vert   // 顶点着色器使用 vert 函数
            #pragma fragment frag // 片元着色器使用 frag 函数

			struct a2v { // appdat2vertex
                float4 vertex : POSITION; // 模型定点
                float3 normal : NORMAL;   // 顶点法线
                float4 texcoord : TEXCOORD0; // 第一个贴图
			};

            struct v2f { // vertex2fragment
                float4 pos : SV_POSITION; // 裁剪空间的3D坐标
                fixed3 color : COLOR0;    // 12位定点数， 输出顶点颜色
            };

            fixed4 _Color;

			v2f vert(a2v v) {
				// mul是矩阵乘法
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);           // 表示将模型空间坐标转换到 裁剪空间中去
                o.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5); // 根据定点法线修改顶点颜色
                //o.color = v.normal;
                return o;
			}

			fixed4 frag(v2f i) : SV_Target 
			{
                // 直接将顶点颜色输出到屏幕上
                return fixed4(i.color * _Color.rgb, 1.0);
				//return fixed4(1.0, 1.0, 0.0, 1.0); // 返回纯色
			}

            ENDCG
        }
    }

	Fallback "VertexLit"
}
