using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestRound : MonoBehaviour {
    Material mat;
    public float speed = 1.0f;
    public float process = 0.0f;
    public float my_angle = 0;
    private DrawSuperellipse _mybox;
	// Use this for initialization
	void Start () {
        mat = GetComponent<MeshRenderer>().material;
        _mybox = GetComponent<DrawSuperellipse>();

    }

    // size  圆角矩形高宽
    // r     圆角矩形半径
    // angle 角度
    public float GetProcessFromAngle(Vector2 size, float r, float angle)
    {
        // 内部计算全使用弧度
        float myPrecent = angle / 360;
        
        angle = angle * Mathf.Deg2Rad; // 角度转为弧度
        float rad90 = Mathf.PI / 2f; // 90 度角的弧度

        float my_angle = angle % rad90;
        //float section = Mathf.Floor(angle / rad90); // 获得4个区间代号之一[0,3]
        
        float circle_len = rad90 * r;
        float aLen = size.x / 2 - r;
        float bLen = size.y / 2 - r;

        float section_len = aLen + bLen + circle_len; // 单边长度
        float arc_len = section_len * 4;                                     // 整个圆角矩形边宽
        float aPrecent = aLen / section_len;
        float bPrecent = bLen / section_len;
        float circlePrecent = circle_len / section_len;

        float subPrecent = aLen / arc_len;
        
        return myPrecent + subPrecent;

        // 下面是第0区的百分比(0区是从上到下, 1区是正好反过来, 从下到上)
        /*
        Vector2 coner0 = new Vector2(size.x - r, size.y); // 第一个点
        Vector2 coner1 = new Vector2(size.x, size.y - r); // 第二个点
        
        float radConer0 = Mathf.Acos(Vector2.Dot(coner0.normalized, Vector2.up)); // 获得第一个点的弧度
        float radConer1 = Mathf.Acos(Vector2.Dot(coner1.normalized, Vector2.up)); // 获得第二个点的弧度

        float process = 0;
        if (my_angle <= radConer0)
        {
            process = my_angle / radConer0 * aPresent;
        }
        */
    }


    private void Update()
    {
        var start_process = GetProcessFromAngle(_mybox._Size, _mybox._ConerRadius, my_angle);
        mat.SetFloat("_Start", start_process);

        process += (Time.deltaTime * speed);
        process %= 1f;
        mat.SetFloat("_Progess", process);
    }
}
