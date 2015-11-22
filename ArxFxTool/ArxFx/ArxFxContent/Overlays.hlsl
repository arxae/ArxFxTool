float GetLinearDepth(float depth)
{
	return  1 / ((depth * ((zFarPlane - zNearPlane) / (-zFarPlane * zNearPlane)) + zFarPlane / (zFarPlane * zNearPlane)));
}

float4 PS_Overlays(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float4 color = tex2D(RFX_backbufferColor, texcoord);

	#if (USE_VIGNETTE)
		float2 uv=(texcoord-0.5)*fVignetteRadius;
		float vignetteold=saturate(dot(uv.xy, uv.xy));
		float3	EVignetteColor=fVignetteColor;

		vignetteold=pow(vignetteold, fVignetteCurve);
		color.xyz=lerp(color.xyz, EVignetteColor, vignetteold*fVignetteAmount);
	#endif

	#if(USE_DEPTHBUFFER_OUTPUT == 1)
		color.xyz = GetLinearDepth(tex2D(SamplerDepth, IN.txcoord.xy).x);
	#endif

	return color;
}
