Shader "Custom/CameraShutter"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _CameraShutterColor ("Camera Shutter Color", Color) = (1, 1, 1, 0)
        _LineColor ("Line Color", Color) = (0, 1, 0, 0)
        _SegmentCount ("Segments Count", integer) = 6
        _Scale ("Scale", Range(0.0, 2.0)) = 0.5 
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

#define PI 3.14159265359
#define TWO_PI 6.28318530718
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _CameraShutterColor;
            float4 _LineColor;
            float _Scale;
            int _SegmentCount;
            float _LineWidth = 1;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            float drawLine (float2 p1, float2 p2, float2 uv, float a)
            {
                float r = 0.;
                float width = 0.003;// 1.0;//1. / iResolution.x; //not really one px
    
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

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 color = tex2D(_MainTex, i.uv);

                // Remap the space to -1. to 1.
                float2 uv = i.uv * 2 - 1.;

                // Angle and radius from the current pixel
                float a = atan2(uv.x,uv.y)+PI;
                float r = TWO_PI/float(_SegmentCount);

                // Shaping function that modulate the distance
                float d = cos(floor(.5+a/r)*r-a)* length(uv);

                float coef = (cos(PI/_SegmentCount));
                //r to R
                float s = _Scale * coef;
                float result = smoothstep(s - 0.01, s, d);

                if(result == 1.0)
                {
                    color = _CameraShutterColor;
                }
                else 
                {
                    color = 0;
                }
               
                float2 center = (0.5, 0.5);

                for(int vert_index = 0; vert_index < _SegmentCount; vert_index++)
                {
                    float start_angle = -PI/2;
                    float segment_angle = TWO_PI/_SegmentCount;
                    float v1_angle = start_angle - segment_angle * (0.5 + vert_index);
                    float v2_angle = start_angle - segment_angle * (1.5 + vert_index);

                    //calculate direction
                    //current vertice point
                    float x_v1 = center.x + cos(v1_angle);
                    float y_v1 = center.y + sin(v1_angle);
                    //next vertice point
                    float x_v2 = center.x + cos(v2_angle);
                    float y_v2 = center.y + sin(v2_angle);

                    float2 lineDirection = float2(x_v2 - x_v1, y_v2 - y_v1);
                    float length = sqrt(pow(lineDirection.x, 2) + pow(lineDirection.y, 2));
                    float defaultLength = 2;
                    lineDirection = lineDirection * defaultLength/length;

                    float x_r = center.x + _Scale/2 * cos(v1_angle);
                    float y_r = center.y + _Scale/2 * sin(v1_angle);

                    float x = x_r + lineDirection.x;
                    float y = y_r + lineDirection.y;

                    if(drawLine(float2(x_r, y_r), float2(x, y), i.uv, 1.) > 0) 
                    {
                        color = _LineColor;
                    }
                }              

                return color;
            }
            ENDCG
        }
    }
}
