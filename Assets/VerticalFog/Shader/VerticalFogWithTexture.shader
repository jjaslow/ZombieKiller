Shader "NLS/VerticalFogWithTexture"
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
	{//JJ:: was  "Queue"="Transparent" "RenderType"="Transparent"
		Tags { "RenderType"="Opaque"  }
		LOD 100
		Pass
		{
			//JJ: was Off
			ZWrite Off

			//Regular alpha blending

			//JJ was SrcAlpha OneMinusSrcAlpha
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
			};
			
			vertexOutput vert(vertexInput input)
			{
			  vertexOutput output;
			
			  // convert obj-space position to camera clip space
			  output.pos = UnityObjectToClipPos(input.vertex);
			  float2 newUV1 = TRANSFORM_TEX(input.uv, _FogTexture1);
			  float2 newUV2 = TRANSFORM_TEX(input.uv, _FogTexture2);

			  // compute depth (screenPos is a float4)
			  output.screenPos = ComputeScreenPos(output.pos);
			  output.animteduv.xy = newUV1 + float2(_FogAnimationSpeed.xy)*_Time.x;
			  output.animteduv.zw = newUV2 + float2(_FogAnimationSpeed.zw)*_Time.x;
			  return output;
			}
		
			float4 frag(vertexOutput input) : COLOR
			{
			  // sample camera depth texture
			  float4 depthSample = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, input.screenPos);
			  float depth = LinearEyeDepth(depthSample).r;

			  // sample fog texture with offsetted uv
			  float4 fogTexA = tex2D(_FogTexture1, input.animteduv.xy);
			  float4 fogTexB = tex2D(_FogTexture2, input.animteduv.zw);

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