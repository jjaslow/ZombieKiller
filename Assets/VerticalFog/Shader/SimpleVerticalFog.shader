Shader "NLS/SimpleVerticalFog"
{
	Properties 
	{
		_Color("Fog Color", Color) = (1, 1, 1, 1)

		_DepthFactor("Depth Factor", Range(0,5)) = 1.0
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

			float4 _Color;

			float _DepthFactor;

			struct vertexInput
			{
				float4 vertex : POSITION;
			};
			
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 screenPos : TEXCOORD1;
			};
			
			vertexOutput vert(vertexInput input)
			{
			  vertexOutput output;
			
			  // convert obj-space position to camera clip space
			  output.pos = UnityObjectToClipPos(input.vertex);

			  // compute depth (screenPos is a float4)
			  output.screenPos = ComputeScreenPos(output.pos);

			  return output;
			}
		
			float4 frag(vertexOutput input) : COLOR
			{
			  // sample camera depth texture
			  float4 depthSample = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, input.screenPos);
			  float depth = LinearEyeDepth(depthSample).r;

			  // caculate depth value
			  float foamLine = saturate(_DepthFactor * (depth - input.screenPos.w));
			  
			  // recolor fog with predefined colors
			  float4 col =_Color;

			  //change fog's transparency based on edge value
			  col.a = foamLine;
			  return col;
			}
		
		  ENDCG
		}
	}
}