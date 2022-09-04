using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FlowBorader : MonoBehaviour {
    public float _Width = 1f;           // 矩形的边长
    public float _FrameWidth = 0.15f;   // 边框的长度

	// Use this for initialization
	void Start () {
        float halfWidth = _Width / 2.0f;
        float realWidth = _Width - _FrameWidth;

        // 中心是0,0
        
        Rect bottom = new Rect(-halfWidth, -halfWidth, realWidth, _FrameWidth);
        Rect left   = new Rect(-halfWidth, -halfWidth + _FrameWidth, _FrameWidth, realWidth);
        Rect up     = new Rect(-halfWidth + _FrameWidth, halfWidth - _FrameWidth, realWidth, _FrameWidth);
        Rect right  = new Rect(halfWidth - _FrameWidth, -halfWidth, _FrameWidth, realWidth);
            /*
        Rect bottom = new Rect(-halfWidth, -halfWidth, _Width, _FrameWidth);
        Rect left = new Rect(-halfWidth, -halfWidth, _FrameWidth, _Width);
        Rect up = new Rect(-halfWidth, halfWidth - _FrameWidth, _Width, _FrameWidth);
        Rect right = new Rect(halfWidth - _FrameWidth, -halfWidth, _FrameWidth, _Width);
        */


        // 创建顶点
        Vector3[] newVertices = { new Vector3(bottom.xMax, bottom.yMin), bottom.min, new Vector3(bottom.xMin, bottom.yMax), bottom.max,                                              // 0,1,2,3
                                  left.min, new Vector3(left.xMin, left.yMax), left.max, new Vector3(left.xMax, left.yMin), // 4,5,6,7
                                  new Vector3(up.xMin, up.yMax), up.max, new Vector3(up.xMax, up.yMin), up.min,                                                      // 8, 9, 10, 11
                                  right.max, new Vector3(right.xMax, right.yMin), right.min, new Vector3(right.xMin, right.yMax)}; // 12, 13, 14, 15

        // 顶点索引
        int[] newTriangles = { 0, 1, 2, 0, 2, 3,
                               4, 5, 6, 4, 6, 7,
                               8, 9, 10, 8, 10, 11,
                               12, 13, 14, 12, 14, 15};


        Vector2[] newUV       = { new Vector2(1, 0),     new Vector2(0.75f, 0), new Vector2(0.75f, 1), new Vector2(1, 1),
                                  new Vector2(0.75f, 0), new Vector2(0.5f, 0), new Vector2(0.5f, 1), new Vector2(0.75f, 1),
                                  new Vector2(0.5f, 0), new Vector2(0.25f, 0), new Vector2(0.25f, 1), new Vector2(0.5f, 1),
                                  new Vector2(0.25f, 0), new Vector2(0, 0), new Vector2(0, 1), new Vector2(0.25f, 1),
                                };


        Mesh mesh = new Mesh();
        GetComponent<MeshFilter>().mesh = mesh;

        mesh.vertices = newVertices;
        mesh.uv = newUV;
        mesh.triangles = newTriangles;
	}
}