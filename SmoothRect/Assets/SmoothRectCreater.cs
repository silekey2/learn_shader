using System.Collections;
using System.Collections.Generic;
using UnityEngine;

// 圆角矩形创建类
public class SmoothRectCreater : MonoBehaviour {
    public Vector2  _Size  = Vector2.one;  // 圆角矩形长宽
    public float    _ConerRadius = 0.1f;   // 圆角半径长度
    public int      _Num = 10;             // 每1/4圆角需要多少条曲线完成
    public float    _SkinWidth = 0.1f;     // 边框宽度


	// Use this for initialization
	void Start () {
        CreateVectexs();
    }

    // 创建定点绘图
    public void CreateVectexs()
    {
        // 创建模型
        Vector3[] vertices; // 顶点
        int[] trigangles;   // 三角面索引
        Vector2[] uvs;      // 顶点UV坐标
        SmoothRect.CreateVectexs(out vertices, out trigangles, out uvs, _Size, _ConerRadius, _Num, _SkinWidth);

        // 设置新的模型
        Mesh mesh = new Mesh();
        GetComponent<MeshFilter>().mesh = mesh;
        mesh.vertices = vertices;
        mesh.triangles = trigangles;
        mesh.uv = uvs;
    }
}
