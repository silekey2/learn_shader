using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestFunction : MonoBehaviour {
    public delegate int MY_DELEGATE(Vector2 pos, Vector2 conter);
	// Use this for initialization
	void Start () {
        Debug.Log(Sign(0));
        RunTest(GetPosIndexCounter);
    }

    static float Sign(float v)
    {
        if (v < 0)
            return -1;
        if (v > 0)
            return 1;
        return 0;
    }

    int GetPosIndexCounter(Vector2 pos, Vector2 coner)
    {
        /*
        Vector2 d = pos - coner;
        Vector2 d2 = pos - (Vector2.one - coner);

        Vector2 v1 = new Vector2(Sign(d.x), Sign(d.y));
        Vector2 v2 = new Vector2(Sign(d2.x), Sign(d2.y));
        */
        return 0;
    }

    void RunTest(MY_DELEGATE func)
    {
        int v = func(new Vector2(0, 0), new Vector2(0.2f, 0.2f));
        Debug.Assert(v == 0, v.ToString());

        v = func(new Vector2(0.3f, 0.1f), new Vector2(0.2f, 0.2f));
        Debug.Assert( v == 1, v.ToString());

        v = func(new Vector2(0.9f, 0.1f), new Vector2(0.2f, 0.2f));
        Debug.Assert(v == 2, v.ToString());

        v = func(new Vector2(0.9f, 0.5f), new Vector2(0.2f, 0.2f));
        Debug.Assert(v == 3, v.ToString());

        v = func(new Vector2(0.95f, 0.85f), new Vector2(0.2f, 0.2f));
        Debug.Assert(v == 4, v.ToString());

        v = func(new Vector2(0.5f, 0.81f), new Vector2(0.2f, 0.2f));
        Debug.Assert(v == 5, v.ToString());

        v = func(new Vector2(0.1f, 0.95f), new Vector2(0.2f, 0.2f));
        Debug.Assert(v == 6, v.ToString());

        v = func(new Vector2(0.15f, 0.4f), new Vector2(0.2f, 0.2f));
        Debug.Assert(v == 7, v.ToString());

        v = func(new Vector2(0.6f, 0.6f), new Vector2(0.2f, 0.2f));
        Debug.Assert(v == 8, v.ToString());
        Debug.Log("all success!");
    }





    int GetPosIndex(Vector2 pos, Vector2 coner)
    {
        if (pos.x < coner.x && pos.y < coner.y)
            return 0;

        if (pos.x >= coner.x && pos.x < 1 - coner.x 
            && pos.y <coner.y)
        {
            return 1;
        }

        if (pos.x >= 1 - coner.x && pos.y < coner.y)
            return 2;

        if (pos.x >= 1 - coner.x && pos.y < 1 - coner.y)
            return 3;

        if (pos.x >= 1 - coner.x && pos.y >= 1 - coner.y)
            return 4;

        if (pos.x >= coner.x && pos.x < 1 -coner.x 
            && pos.y >= 1 - coner.y)
            return 5;

        if (pos.x < coner.x && pos.y >= 1 - coner.y)
            return 6;

        if (pos.x < coner.x && pos.y >= coner.y && pos.y < 1 - coner.y)
            return 7;

        return 8;
        //Mathf.Sign(pos.x - coner.x);
    }
}
