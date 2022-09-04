using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestRound : MonoBehaviour {
    Material mat;
    public float speed = 1.0f;
    public float process = 0.0f;
    public float my_angle = 0;
    private SmoothRectCreater _mybox;
	// Use this for initialization
	void Start () {
        mat = GetComponent<MeshRenderer>().material;
        _mybox = GetComponent<SmoothRectCreater>();

    }

    private void Update()
    {
        var start_process = SmoothRect.GetProcessFromAngle(_mybox._Size, _mybox._ConerRadius, my_angle);
        mat.SetFloat("_Start", start_process);

        process += (Time.deltaTime * speed);
        process %= 1f;
        mat.SetFloat("_Progess", process);
    }
}
