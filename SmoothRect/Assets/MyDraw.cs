using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MyDraw : MonoBehaviour {
    public Color mycolor = Color.red;
    public float n = 5;
    public float a = 1f;
    public float b = 1f;
    public int maxStep = 100;
    public float processStep = 10;
    public float speed = 1.0f;
    public float inter = 0.9f;
    public float Length = 0;

	// Use this for initialization
	void Start () {
		
	}

    Vector3 getPosition(float v, float scale = 1)
    {
        float na = 2 / n;
        float cos_t = Mathf.Cos(v);
        float sin_t = Mathf.Sin(v);
        float x = Mathf.Pow(Mathf.Abs(cos_t), na) * a * Mathf.Sign(cos_t);
        float y = Mathf.Pow(Mathf.Abs(sin_t), na) * b * Mathf.Sign(sin_t);
        return new Vector3(x * scale, y * scale, 0) + transform.position;
    }

    void DrawSuperEllipse(float scale = 1f)
    {
        float piece = (UnityEngine.Mathf.PI * 2) / maxStep;

        float t = 0;
        Length = 0;
        Vector3 startPos = getPosition(0, scale);
        for (int i = 1; i <= processStep + 1; i++)
        {
            t += piece;
            Vector3 curPos = getPosition(t, scale);
            Length += Vector3.Distance(startPos, curPos);
            Debug.DrawLine(startPos, curPos, mycolor);
            startPos = curPos;
        }
    }

    private void OnDrawGizmos()
    {
        DrawSuperEllipse();
        DrawSuperEllipse(inter);
    }

    public void Update()
    {
        processStep += (Time.deltaTime * speed);
        if (processStep >= maxStep)
            processStep = 0;
    }


}
