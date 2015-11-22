#define LumCoeff 		float3(0.212656, 0.715158, 0.072186)
#define zFarPlane 		1
#define zNearPlane 		0.001
#define ScreenSize 		float4(BUFFER_WIDTH, BUFFER_RCP_WIDTH, float(BUFFER_WIDTH) / float(BUFFER_HEIGHT), float(BUFFER_HEIGHT) / float(BUFFER_WIDTH)) //x=Width, y=1/Width, z=ScreenScaleY, w=1/ScreenScaleY
#define PixelSize  		float2(BUFFER_RCP_WIDTH, BUFFER_RCP_HEIGHT)
#define SamplerCurrent 	SamplerHDR2

#include "ArxFxContent/ArxFx.h"
#include "ArxFxContent/TextureSamplers.h"
#include "ArxFxContent/Colors.hlsl"
#include "ArxFxContent/Lighting.hlsl"
#include "ArxFxContent/Overlays.hlsl"
#include "ArxFxContent/ImageEnhancements.hlsl"

// Global stuff
#pragma message "ArxFX 1.0.0 by Arxae"

// Vertex Shader
void RFX_VS_PostProcess(in uint id : SV_VertexID, out float4 pos : SV_Position, out float2 texcoord : TEXCOORD)
{
	texcoord.x = (id == 2) ? 2.0 : 0.0;
	texcoord.y = (id == 1) ? 2.0 : 0.0;
	pos = float4(texcoord * float2(2.0, -2.0) + float2(-1.0, 1.0), 0.0, 1.0);
}

technique Emboss_Technique <bool enabled = 1; toggle = TOGGLE_EFFECTS_KEY; >
{
	#if (USE_BLOOM || USE_LENSDIRT)
		pass BloomPrePass
		{
			VertexShader = RFX_VS_PostProcess;
			PixelShader = PS_ME_BloomPrePass;
			RenderTarget = texBloom1;
		}

		pass BloomPass1
		{
			VertexShader = RFX_VS_PostProcess;
			PixelShader = PS_ME_BloomPass1;
			RenderTarget = texBloom2;
		}

		pass BloomPass2
		{
			VertexShader = RFX_VS_PostProcess;
			PixelShader = PS_ME_BloomPass2;
			RenderTarget = texBloom3;
		}

		pass BloomPass3
		{
			VertexShader = RFX_VS_PostProcess;
			PixelShader = PS_ME_BloomPass3;
			RenderTarget = texBloom4;
		}

		pass BloomPass4
		{
			VertexShader = RFX_VS_PostProcess;
			PixelShader = PS_ME_BloomPass4;
			RenderTarget = texBloom5;
		}
	#endif
	pass Colors
	{
		VertexShader = RFX_VS_PostProcess;
		PixelShader = PS_Colors;
	}

	pass Lighting
	{
		VertexShader = RFX_VS_PostProcess;
		PixelShader = PS_Lighting;
	}

	pass ImageEnhancements
	{
		VertexShader = RFX_VS_PostProcess;
		PixelShader = PS_ImageEnhancements;
	}

	pass Overlays
	{
		VertexShader = RFX_VS_PostProcess;
		PixelShader = PS_Overlays;
	}
}
