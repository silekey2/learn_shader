using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MyDrawSmothConer : MonoBehaviour {
    public Color _Color = Color.red;
    public Color _CircleColor = Color.blue;
    public Vector2 _Size = Vector2.one;                 // 矩形宽高
    public float _ConerR = 0.1f;                        // 倒角半径 百分比
    public int _Num = 10;
    public Vector2 _Range = new Vector2(0, 30);
    public float _Inter = 0.9f;
	// Use this for initialization
	void Start () {
		
	}

    // center 中点
    // r 半径
    // startAngle 启始坐标
    // endAngle 终点坐标
    // num 数量, 分切数量
    void DrawCircle(Vector3 center, float r, float startAngle, float endAngle, Color c, int num = 10)
    {
        // _Range.x * Mathf.Deg2Rad, _Range.y *Mathf.Deg2Rad
        startAngle *= Mathf.Deg2Rad;
        endAngle *= Mathf.Deg2Rad;
        float stepAngle = (endAngle - startAngle) / num;
        Vector3 lastPos = Vector3.zero;
        for (int i = 0; i <= num; i++) // 需要最后一个点要补完
        {
            float angle = i * stepAngle + startAngle;
            Vector3 v = Vector3.zero;
            v.x = Mathf.Sin(angle) * r;
            v.y = Mathf.Cos(angle) * r;
            if (i != 0)
            {
                Debug.DrawLine(center + lastPos, center + v, c);
            }
            lastPos = v;
        }
    }

    void drawSmoothRect(Vector2 size, float conerR)
    {
        // 画线
        Vector3 sPos = transform.position; // 起始坐标

        // 画上面的直线
        float r = conerR;//conerR * size.x; // 圆角半径
        float lineWidth = size.x - r * 2;
        float lineHeight = size.y - r * 2;
        float halfLineWidth = lineWidth / 2;
        float halfLineHeight = lineHeight / 2;
        float halfWidth = size.x / 2;
        float halfHeight = size.y / 2;
        
        Vector3 linePos00 = new Vector3(-halfLineWidth, halfHeight);
        Vector3 linePos01 = new Vector3(halfLineWidth, halfHeight);

        Vector3 linePos10 = new Vector3(-halfLineWidth, -halfHeight);
        Vector3 linePos11 = new Vector3(halfLineWidth, -halfHeight);

        Vector3 linePos20 = new Vector3(-halfWidth, -halfLineHeight);
        Vector3 linePos21 = new Vector3(-halfWidth, halfLineHeight);

        Vector3 linePos30 = new Vector3(halfWidth, -halfLineHeight);
        Vector3 linePos31 = new Vector3(halfWidth, halfLineHeight);

        // 画直线
        Debug.DrawLine(linePos00 + sPos, linePos01 + sPos, _Color);
        Debug.DrawLine(linePos10 + sPos, linePos11 + sPos, _Color);
        Debug.DrawLine(linePos20 + sPos, linePos21 + sPos, _Color);
        Debug.DrawLine(linePos30 + sPos, linePos31 + sPos, _Color);

        // 画圆角
        Vector3 center0 = new Vector3(halfLineWidth, halfLineHeight);
        Vector3 center1 = new Vector3(halfLineWidth, -halfLineHeight);
        Vector3 center2 = new Vector3(-halfLineWidth, -halfLineHeight);
        Vector3 center3 = new Vector3(-halfLineWidth, halfLineHeight);

        DrawCircle(center0 + sPos, r, 0, 90, _CircleColor, _Num);
        DrawCircle(center1 + sPos, r, 90, 180, _CircleColor, _Num);
        DrawCircle(center2 + sPos, r, 180, 270, _CircleColor, _Num);
        DrawCircle(center3 + sPos, r, 270, 360, _CircleColor, _Num);
    }

    private void OnDrawGizmos()
    {
        //DrawSuperEllipse();
        //DrawSuperEllipse(inter);
        //DrawCircle(transform.position, _ConerR, _Range.x * Mathf.Deg2Rad, _Range.y *Mathf.Deg2Rad, _Num);
        drawSmoothRect(_Size, _ConerR);

        //float scale = (_Size.x - _Inter) / _Size.x;
        drawSmoothRect(_Size - new Vector2(_Inter * 2, _Inter * 2), _ConerR - _Inter);
    }

    public void Update()
    {
    }


}
