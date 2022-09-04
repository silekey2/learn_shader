// 圆角矩形生成类
using UnityEngine;

public class SmoothRect {
    // 创建定点绘图
    // vertices,   生成的顶点数组
    // trigangles, 生成的三角形索引数组
    // uvs,        生成的uv信息
    // size        矩形长宽
    // coner_radius  圆角半径
    // piece_num   每个圆角由几个线段组成
    // skin_width  内矩形与外矩形间隔距离
    public static void CreateVectexs(
                        out Vector3[] vertices,
                        out int[]     trigangles,
                        out Vector2[] uvs,
                        Vector2 size,
                        float coner_radius = 0.1f,
                        int piece_num = 5,
                        float skin_width = 0.1f)
    {
        Vector3[] outVertices = CreateSmoothRectVectexs(size, coner_radius, piece_num);                           // 生成的外框顶点
        Vector3[] interVertices = CreateSmoothRectVectexs(size - new Vector2(skin_width * 2, skin_width * 2),// 生成的内框顶点
                                                        coner_radius - skin_width, piece_num);
        float[] uvArrays = GetPercentOfLength(outVertices);
        Vector3[] allVertices = mergeVertices(outVertices, interVertices);

        // 添加最后两个顶点
        Vector3[] fainlVertices = mergeVertices(allVertices, new Vector3[] { outVertices[0], interVertices[0] });

        // 顶点索引
        int count = allVertices.Length;
        int pointCount = outVertices.Length;
        int[] newTriangles = new int[count * 3];

        for (int i = 0; i < pointCount - 1; i++)
        {
            int nextIndex = (i + 1) % pointCount; // 下一个index 防止越界, 会直接使用0

            newTriangles[i * 6] = i;
            newTriangles[i * 6 + 1] = pointCount + nextIndex;
            newTriangles[i * 6 + 2] = pointCount + i;

            newTriangles[i * 6 + 3] = i;
            newTriangles[i * 6 + 4] = nextIndex;
            newTriangles[i * 6 + 5] = pointCount + nextIndex;
        }
        // 最后三角形特殊处理
        int lastIndex = pointCount - 1;
        newTriangles[lastIndex * 6] = lastIndex;
        newTriangles[lastIndex * 6 + 1] = count + 1;  //pointCount + nextIndex;
        newTriangles[lastIndex * 6 + 2] = pointCount + lastIndex;

        newTriangles[lastIndex * 6 + 3] = lastIndex;
        newTriangles[lastIndex * 6 + 4] = count;
        newTriangles[lastIndex * 6 + 5] = count + 1;

        // 给每个顶点设置UV坐标
        Vector2[] newUV = new Vector2[count + 2];
        for (int i = 0; i < pointCount; i++)
        {
            float value = uvArrays[i];
            newUV[i] = new Vector2(value, 1);
            newUV[i + pointCount] = new Vector2(value, 0);
        }
        newUV[count] = new Vector2(1, 1);       // 外圈最后的顶点
        newUV[count + 1] = new Vector2(1, 0);   // 内圈最后的顶点

        vertices = fainlVertices;
        trigangles = newTriangles;
        uvs = newUV;
    }

    // 通过角度获得圆角矩形起始位置百分比
    // size  圆角矩形高宽
    // r     圆角矩形半径
    // angle 角度
    public static float GetProcessFromAngle(Vector2 size, float r, float angle)
    {
        // 内部计算全使用弧度
        float myPrecent = angle / 360;

        angle = angle * Mathf.Deg2Rad; // 角度转为弧度
        float rad90 = Mathf.PI / 2f; // 90 度角的弧度

        //float my_angle = angle % rad90;
        float circle_len = rad90 * r;
        float aLen = size.x / 2 - r;
        float bLen = size.y / 2 - r;

        float section_len = aLen + bLen + circle_len; // 单边长度
        float arc_len = section_len * 4;                                     // 整个圆角矩形边宽
        //float aPrecent = aLen / section_len;
        //float bPrecent = bLen / section_len;
        //float circlePrecent = circle_len / section_len;
        float subPrecent = aLen / arc_len;

        return myPrecent + subPrecent;
    }

    // 创建圆角矩形顶点
    // center 中点
    // r 半径
    // startAngle 启始坐标
    // endAngle 终点坐标
    // num 数量, 分切数量
    // 创建圆角矩形顶点
    // @param size, 圆角矩形的长宽
    static Vector3[] CreateSmoothRectVectexs(Vector2 size, float conerR, int num)
    {
        int sideNum = 2 + num - 1;                      // 每一面有几个定点 (由于头尾的顶点是与直线公用, 因此不需要添加)
        int verticeNum = sideNum * 4;                   // 4个角加4个边的定点数
        Vector3[] vertices = new Vector3[verticeNum];

        float r = conerR;//conerR * size.x; // 圆角半径
        float lineWidth = size.x - r * 2;
        float lineHeight = size.y - r * 2;
        float halfLineWidth = lineWidth / 2;
        float halfLineHeight = lineHeight / 2;
        float halfWidth = size.x / 2;
        float halfHeight = size.y / 2;

        // 创建线段顶点
        // 上
        Vector3 linePos00 = new Vector3(-halfLineWidth, halfHeight);
        Vector3 linePos01 = new Vector3(halfLineWidth, halfHeight);

        // 右
        Vector3 linePos10 = new Vector3(halfWidth, halfLineHeight);
        Vector3 linePos11 = new Vector3(halfWidth, -halfLineHeight);

        // 下
        Vector3 linePos20 = new Vector3(halfLineWidth, -halfHeight);
        Vector3 linePos21 = new Vector3(-halfLineWidth, -halfHeight);

        // 左
        Vector3 linePos30 = new Vector3(-halfWidth, -halfLineHeight);
        Vector3 linePos31 = new Vector3(-halfWidth, halfLineHeight);

        // 将直线的定点放入定点数组
        vertices[0] = linePos00;
        vertices[1] = linePos01;
        vertices[sideNum] = linePos10;
        vertices[sideNum + 1] = linePos11;
        vertices[sideNum * 2] = linePos20;
        vertices[sideNum * 2 + 1] = linePos21;
        vertices[sideNum * 3] = linePos30;
        vertices[sideNum * 3 + 1] = linePos31;

        // 将各个圆角的顶点放入数组
        Vector3 center0 = new Vector3(halfLineWidth, halfLineHeight);   // 各个圆角 右上
        Vector3 center1 = new Vector3(halfLineWidth, -halfLineHeight);  // 右下 
        Vector3 center2 = new Vector3(-halfLineWidth, -halfLineHeight); // 左下
        Vector3 center3 = new Vector3(-halfLineWidth, halfLineHeight);  // 左上

        // 设置圆弧的顶点
        SetCircleVectexs(vertices, 2, num, center0, conerR, 0, 90);                     // 右上角圆弧
        SetCircleVectexs(vertices, sideNum + 2, num, center1, conerR, 90, 180);         // 右下角圆弧
        SetCircleVectexs(vertices, sideNum * 2 + 2, num, center2, conerR, 180, 270);    // 左下角圆弧
        SetCircleVectexs(vertices, sideNum * 3 + 2, num, center3, conerR, 270, 360);    // 左上角圆弧
        return vertices;
    }

    // 设置圆角的顶点
    // data, 存入数组
    // startIndex, 数组启始坐标
    // num, 要切成多少分
    static void SetCircleVectexs(Vector3[] data, int startIndex, int num, Vector3 center, float r, float startAngle, float endAngle)
    {
        startAngle *= Mathf.Deg2Rad;
        endAngle *= Mathf.Deg2Rad;

        float stepAngle = (endAngle - startAngle) / num; // 圆弧包含多少段
        for (int i = 0; i < num - 1; i++)
        {
            float angle = (i + 1) * stepAngle + startAngle;
            Vector3 v = Vector3.zero;
            v.x = Mathf.Sin(angle) * r;
            v.y = Mathf.Cos(angle) * r;
            data[startIndex + i] = center + v;
        }
    }

    // 获得多边形的边长
    static float GetLengths(Vector3[] vertices)
    {
        float len = 0;
        int arr_len = vertices.Length;
        for (int i = 1; i < arr_len; i++)
        {
            len += Vector3.Distance(vertices[i - 1], vertices[i]);
        }
        len += Vector3.Distance(vertices[arr_len - 1], vertices[0]);
        return len;
    }

    // 每个顶点获得长度的百分比
    static float[] GetPercentOfLength(Vector3[] vertices)
    {
        float[] percents = new float[vertices.Length];
        float allLen = GetLengths(vertices);
        float len = 0;
        for (int i = 0; i < vertices.Length; i++)
        {
            if (i == 0)
            {
                percents[i] = 0;
            }
            else
            {
                float diff = Vector3.Distance(vertices[i - 1], vertices[i]);
                len += diff;
                percents[i] = len / allLen;
            }
        }
        //len += Vector3.Distance(vertices[0], vertices[vertices.Length - 1]);
        //percents[0] = len / allLen;

        return percents;
    }

    // 合并两段数组
    static Vector3[] mergeVertices(Vector3[] v1, Vector3[] v2)
    {
        Vector3[] oValue = new Vector3[v1.Length + v2.Length];
        for (int i = 0; i < v1.Length; i++)
            oValue[i] = v1[i];

        for (int i = 0; i < v2.Length; i++)
            oValue[v1.Length + i] = v2[i];
        return oValue;
    }
}
