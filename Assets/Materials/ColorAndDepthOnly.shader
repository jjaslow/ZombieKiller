Shader "Custom/ColorAndDepthOnly"
{
    
    Properties {
        _Color ("Color", Color) = (1, 1, 1, 1)
    }

    SubShader {
	
		Tags {"Queue"="Geometry+1" "LightMode" = "ForwardBase"}
        Pass {

            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            fixed4 _Color;

            struct VertexData {
                float4 vertex : POSITION;
            };

            struct Interpolators {
                float4 vertex : SV_POSITION;
            };

            Interpolators vert (VertexData v) {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float4 frag (Interpolators i) : SV_TARGET {
                return _Color;
            }

            ENDCG
        }


    }

    FallBack "Diffuse"
}
