// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/MyBase" // Shader名字
{
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

			// POSITION CG语义 表示这是模型顶点的位置
			// SV_POSITION CG语义 告诉Unity 返回值是裁剪空间中的坐标
			float4 vert(float4 v : POSITION) : SV_POSITION {
				// mul是矩阵乘法
				// UNITY_MATRIX_MVP 表示将模型空间坐标转换到 裁剪空间中去
				return UnityObjectToClipPos(v); // 自动将mul(UNITY_MATRIX_MVP, v) 转换成UnityObjectToClipPos
			}

			fixed4 frag() : SV_Target 
			{
				return fixed4(1.0, 1.0, 0.0, 1.0); // 返回纯色
			}

            ENDCG
        }
    }

	Fallback "VertexLit"
}
