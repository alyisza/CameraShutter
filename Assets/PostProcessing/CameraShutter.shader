Shader "Hidden/Custom/CameraShutter"
{
    HLSLINCLUDE
// StdLib.hlsl holds pre-configured vertex shaders (VertDefault), varying structs (VaryingsDefault), and most of the data you need to write common effects.
    #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"
    #define PI 3.14159265359
    #define TWO_PI 6.28318530718
    TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);

    float _Scale;
    int _SegmentCount;
    float _ScreenWidth;
    float _ScreenHeight;
    float4 _CameraShutterColor;
    float4 _LineColor;
    float _LineWidth;

    float drawLine (float2 p1, float2 p2, float2 uv, float a)
    {
        float r = 0.;
        float width = _ScreenWidth/2500;

        // get dist between points
        float d = distance(p1, p2);
    
        // get dist between current pixel and p1
        float duv = distance(p1, uv);

        //if point is on line, according to dist, it should match current uv 
        r = 1.-floor(1.-(a*width)+distance (lerp(p1, p2, clamp(duv/d, 0., 1.)),  uv));
        
        return r;
    }

    bool drawCircle(float r, float x0, float y0, float x, float y)
    {
        return (pow(r, 2) > pow((x - x0), 2) + pow(y - y0, 2));
    }

    float map(float s, float a1, float a2, float b1, float b2)
    {
        return b1 + (s-a1)*(b2-b1)/(a2-a1);
    }

    float4 Frag(VaryingsDefault i) : SV_Target
    {
        float max_screen_scale = max(_ScreenWidth, _ScreenHeight);
        float pixel_scale = max_screen_scale * _Scale / 2;
        float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
        //in pixels
        float2 position;
        position.x = map(i.texcoord.x, 0, 1, -_ScreenWidth/2, _ScreenWidth/2);
        position.y = map(i.texcoord.y, 0, 1, -_ScreenHeight/2, _ScreenHeight/2);

        // Angle and radius from the current pixel
        float a = atan2(position.x, position.y) + PI;
        float r = TWO_PI/float(_SegmentCount);

        // Shaping function that modulate the distance
        float d = cos(floor(.5 + a/r) * r - a)* length(position);

        float coef = (cos(PI/_SegmentCount));
        //r to R
        float s = pixel_scale * coef;
        float result = smoothstep(s - 0.01, s, d);

        if(result == 1.0)
        {
            color = _CameraShutterColor;
        }

        float2 center = 0;

        for(int vert_index = 0; vert_index < _SegmentCount; vert_index++)
        {
            float start_angle = -PI/2;
            float segment_angle = TWO_PI/_SegmentCount;
            float angle1 = start_angle - segment_angle * (0.5 + vert_index);
            float angle2 = start_angle - segment_angle * (1.5 + vert_index);

            //calculate direction
            //current vertice point
            float x1 = center.x + cos(angle1);
            float y1 = center.y + sin(angle1);
            //next vertice point
            float x2 = center.x + cos(angle2);
            float y2 = center.y + sin(angle2);

            float2 vect_direct = float2(x2 - x1, y2 - y1);
            float length = sqrt(pow(vect_direct.x, 2) + pow(vect_direct.y, 2));
            float default_length = max_screen_scale;
            vect_direct = vect_direct * default_length/length;

            float x_start = center.x + pixel_scale * cos(angle1);
            float y_start = center.y + pixel_scale * sin(angle1);

            float x_dest = x_start + vect_direct.x;
            float y_dest = y_start + vect_direct.y;

            if(drawLine(float2(x_start, y_start), float2(x_dest, y_dest), position, _LineWidth) > 0) 
            {
                color = _LineColor;
            }
        }

        return color;
    }

  ENDHLSL
  SubShader
  {
      Cull Off ZWrite Off ZTest Always
      Pass
      {
          HLSLPROGRAM
              #pragma vertex VertDefault
              #pragma fragment Frag
          ENDHLSL
      }
  }
}
