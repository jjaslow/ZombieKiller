Shader "Custom/Clouds"
{
    Properties
    {
        [Header(General)]
        _MainTex ("iChannel0", 2D) = "white" {}
        _SecondTex ("iChannel1", 2D) = "white" {}
        _ThirdTex ("iChannel2", 2D) = "white" {}
        _FourthTex ("iChannel3", 2D) = "white" {}
        _Mouse ("Mouse", Vector) = (0.5, 0.5, 0.5, 0.5)
        [ToggleUI] _GammaCorrect ("Gamma Correction", Float) = 1
        _Resolution ("Resolution (Change if AA is bad)", Range(1, 1024)) = 1

        [Header(Raymarching)]
        [ToggleUI] _WorldSpace ("World Space Marching", Float) = 0
        _Offset ("Offset (W=Scale)", Vector) = (0, 0, 0, 1)

        [Header(Extracted)]
        cloudscale ("cloudscale", Float) = 1.1
        speed ("speed", Float) = 0.03
        clouddark ("clouddark", Float) = 0.5
        cloudlight ("cloudlight", Float) = 0.3
        cloudcover ("cloudcover", Float) = 0.2
        cloudalpha ("cloudalpha", Float) = 8
        skytint ("skytint", Float) = 0.5
        skycolour1 ("skycolour1", Vector) = (0.2,0.4,0.6)
        skycolour2 ("skycolour2", Vector) = (0.4,0.7,1)

    }
    SubShader
    {
        Pass
        {
            Cull Off

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
                float4 vertex : SV_POSITION;
                float3 ro_w : TEXCOORD1;
                float3 hitPos_w : TEXCOORD2;
            };

            // Built-in properties
            sampler2D _MainTex;   float4 _MainTex_TexelSize;
            sampler2D _SecondTex; float4 _SecondTex_TexelSize;
            sampler2D _ThirdTex;  float4 _ThirdTex_TexelSize;
            sampler2D _FourthTex; float4 _FourthTex_TexelSize;
            float4 _Mouse;
            float _GammaCorrect;
            float _Resolution;
            float _WorldSpace;
            float4 _Offset;

            // GLSL Compatability macros
            #define glsl_mod(x,y) (((x)-(y)*floor((x)/(y))))
            #define texelFetch(ch, uv, lod) tex2Dlod(ch, float4((uv).xy * ch##_TexelSize.xy + ch##_TexelSize.xy * 0.5, 0, lod))
            #define textureLod(ch, uv, lod) tex2Dlod(ch, float4(uv, 0, lod))
            #define iResolution float3(_Resolution, _Resolution, _Resolution)
            #define iFrame (floor(_Time.y / 60))
            #define iChannelTime float4(_Time.y, _Time.y, _Time.y, _Time.y)
            #define iDate float4(2020, 6, 18, 30)
            #define iSampleRate (44100)
            #define iChannelResolution float4x4(                      \
                _MainTex_TexelSize.z,   _MainTex_TexelSize.w,   0, 0, \
                _SecondTex_TexelSize.z, _SecondTex_TexelSize.w, 0, 0, \
                _ThirdTex_TexelSize.z,  _ThirdTex_TexelSize.w,  0, 0, \
                _FourthTex_TexelSize.z, _FourthTex_TexelSize.w, 0, 0)

            // Global access to uv data
            static v2f vertex_output;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv =  v.uv;

                if (_WorldSpace)
                {
                    o.ro_w = _WorldSpaceCameraPos;
                    o.hitPos_w = mul(unity_ObjectToWorld, v.vertex);
                }
                else
                {
                    o.ro_w = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));
                    o.hitPos_w = v.vertex;
                }

                return o;
            }

            const float cloudscale;
            const float speed;
            const float clouddark;
            const float cloudlight;
            const float cloudcover;
            const float cloudalpha;
            const float skytint;
            const float3 skycolour1;
            const float3 skycolour2;
            static const float2x2 m = transpose(float2x2(1.6, 1.2, -1.2, 1.6));
            float2 hash(float2 p)
            {
                p = float2(dot(p, float2(127.1, 311.7)), dot(p, float2(269.5, 183.3)));
                return -1.+2.*frac(sin(p)*43758.547);
            }

            float noise(in float2 p)
            {
                const float K1 = 0.36602542;
                const float K2 = 0.21132487;
                float2 i = floor(p+(p.x+p.y)*K1);
                float2 a = p-i+(i.x+i.y)*K2;
                float2 o = a.x>a.y ? float2(1., 0.) : float2(0., 1.);
                float2 b = a-o+K2;
                float2 c = a-1.+2.*K2;
                float3 h = max(0.5-float3(dot(a, a), dot(b, b), dot(c, c)), 0.);
                float3 n = h*h*h*h*float3(dot(a, hash(i+0.)), dot(b, hash(i+o)), dot(c, hash(i+1.)));
                return dot(n, ((float3)70.));
            }

            float fbm(float2 n)
            {
                float total = 0., amplitude = 0.1;
                for (int i = 0;i<7; i++)
                {
                    total += noise(n)*amplitude;
                    n = mul(m,n);
                    amplitude *= 0.4;
                }
                return total;
            }

            float4 frag (v2f __vertex_output, float facing : VFACE) : SV_Target
            {
                vertex_output = __vertex_output;
                float4 fragColor = 0;
                float2 fragCoord = vertex_output.uv * _Resolution;
                float2 p = fragCoord.xy/iResolution.xy;
                float2 uv = p*float2(iResolution.x/iResolution.y, 1.);
                float time = _Time.y*speed;
                float q = fbm(uv*cloudscale*0.5);
                float r = 0.;
                uv *= cloudscale;
                uv -= q-time;
                float weight = 0.8;
                for (int i = 0;i<8; i++)
                {
                    r += abs(weight*noise(uv));
                    uv = mul(m,uv)+time;
                    weight *= 0.7;
                }
                float f = 0.;
                uv = p*float2(iResolution.x/iResolution.y, 1.);
                uv *= cloudscale;
                uv -= q-time;
                weight = 0.7;
                for (int i = 0;i<8; i++)
                {
                    f += weight*noise(uv);
                    uv = mul(m,uv)+time;
                    weight *= 0.6;
                }
                f *= r+f;
                float c = 0.;
                time = _Time.y*speed*2.;
                uv = p*float2(iResolution.x/iResolution.y, 1.);
                uv *= cloudscale*2.;
                uv -= q-time;
                weight = 0.4;
                for (int i = 0;i<7; i++)
                {
                    c += weight*noise(uv);
                    uv = mul(m,uv)+time;
                    weight *= 0.6;
                }
                float c1 = 0.;
                time = _Time.y*speed*3.;
                uv = p*float2(iResolution.x/iResolution.y, 1.);
                uv *= cloudscale*3.;
                uv -= q-time;
                weight = 0.4;
                for (int i = 0;i<7; i++)
                {
                    c1 += abs(weight*noise(uv));
                    uv = mul(m,uv)+time;
                    weight *= 0.6;
                }
                c += c1;
                float3 skycolour = lerp(skycolour2, skycolour1, p.y);
                float3 cloudcolour = float3(.36, .36, .36)*clamp(clouddark+cloudlight*c, 0., 1.);
                f = cloudcover+cloudalpha*f*r;
                float3 result = lerp(skycolour, clamp(skytint*skycolour+cloudcolour, 0., 1.), clamp(f+c, 0., 1.));
                fragColor = float4(result, 1.);
                if (_GammaCorrect) fragColor.rgb = pow(fragColor.rgb, 2.2);
                return fragColor;
            }
            ENDCG
        }
    }
}

