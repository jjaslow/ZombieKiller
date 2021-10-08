Shader "NLS/MeshFogWithTexture"
{
	Properties 
	{
		_Color1("Fog Color (1)", Color) = (1, 1, 1, 1)
		_Color2("Fog Color (2)", Color) = (1, 1, 1, 1)
		//width of the edge effect
		_DepthFactor("Depth Factor", Range(0,5)) = 1.0
		_FogTexture1("Fog Texture (1)", 2D) = "white" {}
		_FogTexture2("Fog Texture (2)", 2D) = "white" {}

		//x and y control the speed of fog from R channel in the u and v direction
		//z and w control the speed of fog from G channel in the u and v direction
		_FogAnimationSpeed ("Fog Speed", Vector) = (0,0,0,0)
	}
	SubShader
	{
		Tags { "Queue"="Transparent" "RenderType"="Transparent"  }
		LOD 100
		Pass
		{
			ZWrite Off

			//Regular alpha blending
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			// required to use ComputeScreenPos()
			#include "UnityCG.cginc"
		
			#pragma vertex vert
			#pragma fragment frag
		 
			// Unity built-in - NOT required in Properties
			sampler2D _CameraDepthTexture;
			sampler2D _FogTexture1;
			float4 _FogTexture1_ST;
			sampler2D _FogTexture2;
			float4 _FogTexture2_ST;

			float4 _Color1;
			float4 _Color2;

			float _DepthFactor;
			float4 _FogAnimationSpeed;

			struct vertexInput
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};
			
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 screenPos : TEXCOORD1;
				float4 animteduv : TEXCOORD2;
				float4 screenUV : TEXCOORD3;
				float4 screenUV2 : TEXCOORD4;
			};

			inline void ObjSpaceUVOffset(inout float2 screenUV, in float screenRatio, float2 textureST)
            {

                float2 objPos = float2(UNITY_MATRIX_MV[3].x * screenRatio, 
                                       UNITY_MATRIX_MV[3].y);

                float offsetFactorX = 0.5;
                float offsetFactorY = offsetFactorX * screenRatio;
                // apply tiling from properties
                offsetFactorX *= textureST.x;
                offsetFactorY *= textureST.y;

                // sign(UNITY_MATRIX_P[1].y) is different in Scene and Game views
                screenUV.x -= objPos.x * offsetFactorX * sign(UNITY_MATRIX_P[1].y);
                screenUV.y -= objPos.y * offsetFactorY * sign(UNITY_MATRIX_P[1].y);
            }

			void TextureScalingOffset(inout float2 scrUV, float2 textureST)
            {
			    float scrRatio = _ScreenParams.y / _ScreenParams.x;
			    scrUV.y *= scrRatio;
			    ObjSpaceUVOffset(scrUV, scrRatio, textureST); 
            }

			vertexOutput vert(vertexInput input)
			{
			  vertexOutput output;
			
			  // convert obj-space position to camera clip space
			  output.pos = UnityObjectToClipPos(input.vertex);

			  // compute depth (screenPos is a float4)
			  output.screenPos = ComputeScreenPos(output.pos);
			  output.animteduv.xy =  float2(_FogAnimationSpeed.xy)*_Time.x;
			  output.animteduv.zw =  float2(_FogAnimationSpeed.zw)*_Time.x;
			  
			  output.screenUV = ComputeScreenPos(output.pos);
			  output.screenUV.xy = TRANSFORM_TEX(output.screenUV, _FogTexture1);
			  
			  output.screenUV2 = ComputeScreenPos(output.pos);
			  output.screenUV2.xy = TRANSFORM_TEX(output.screenUV2, _FogTexture2);
			  
			  return output;
			}
		
			float4 frag(vertexOutput input) : COLOR
			{
			  // sample camera depth texture
			  float4 depthSample = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, input.screenPos);
			  float depth = LinearEyeDepth(depthSample).r;

			  // Screenspace UV
			  float2 screenUV = input.screenUV.xy / input.screenUV.w;
              TextureScalingOffset(screenUV, _FogTexture1_ST.xy);			
			  float2 screenUV2 = input.screenUV2.xy / input.screenUV2.w;
              TextureScalingOffset(screenUV2, _FogTexture2_ST.xy);

			  // animate uvs
			  screenUV += input.animteduv.xy;
			  screenUV2 += input.animteduv.zw;

			  // sample fog texture with offsetted uv
			  float4 fogTexB = tex2D(_FogTexture2, screenUV2);
			  float4 fogTexA = tex2D(_FogTexture1, screenUV);

			  // caculate depth value
			  float foamLine = saturate(_DepthFactor * (depth - input.screenPos.w));
			  
			  // recolor fog with predefined colors
			  float4 col =lerp(_Color2,_Color1, (fogTexA.r * fogTexB.r));

			  //change fog's transparency based on edge value
			  col.a = foamLine;
			  return col;
			}
		
		  ENDCG
		}
	}
}