texture   texBloom1 { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RENDERMODE;};
texture   texBloom2 { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = RENDERMODE;};
texture   texBloom3 { Width = BUFFER_WIDTH/2; Height = BUFFER_HEIGHT/2; Format = RENDERMODE;};
texture   texBloom4 { Width = BUFFER_WIDTH/4; Height = BUFFER_HEIGHT/4; Format = RENDERMODE;};
texture   texBloom5 { Width = BUFFER_WIDTH/8; Height = BUFFER_HEIGHT/8; Format = RENDERMODE;};
texture   texDirt   < string source = "ArxFxContent/textures/lensdirt.png"; > {Width = BUFFER_WIDTH;Height = BUFFER_HEIGHT;Format = RGBA8;};

sampler SamplerBloom1 { Texture = texBloom1; };
sampler SamplerBloom2 { Texture = texBloom2; };
sampler SamplerBloom3 { Texture = texBloom3; };
sampler SamplerBloom4 { Texture = texBloom4; };
sampler SamplerBloom5 { Texture = texBloom5; };

sampler2D SamplerDirt
{
	Texture = texDirt;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU = Clamp;
	AddressV = Clamp;
};

float4 GaussBlur22(float2 coord, sampler tex, float mult, float lodlevel, bool isBlurVert) //texcoord, texture, blurmult in pixels, tex2dlod level, axis (0=horiz, 1=vert)
{
	float4 sum = 0;
	float2 axis = (isBlurVert) ? float2(0, 1) : float2(1, 0);
	float  weight[11] = {0.082607, 0.080977, 0.076276, 0.069041, 0.060049, 0.050187, 0.040306, 0.031105, 0.023066, 0.016436, 0.011254};

	for(int i=-10; i < 11; i++)
	{
		float currweight = weight[abs(i)];
		sum	+= tex2Dlod(tex, float4(coord.xy + axis.xy * (float)i * PixelSize * mult,0,lodlevel)) * currweight;
	}

	return sum;
}

float4 PS_ME_BloomPrePass(float4 vpos : SV_POSITION, float2 texcoord : TEXCOORD) : SV_Target
{
	float4 bloom=0.0;
	float2 bloomuv;

	float2 offset[4]=
	{
		float2(1.0, 1.0),
		float2(1.0, 1.0),
		float2(-1.0, 1.0),
		float2(-1.0, -1.0)
	};

	for (int i=0; i<4; i++)
	{
		bloomuv.xy=offset[i]*PixelSize.xy*2;
		bloomuv.xy=texcoord.xy + bloomuv.xy;
		float4 tempbloom=tex2Dlod(SamplerLDR, float4(bloomuv.xy, 0, 0));
		tempbloom.xyz = max(0, tempbloom.xyz-fBloomThreshold);

		bloom+=tempbloom;
	}

	bloom *= 0.25;
	return bloom;
}

float4 PS_ME_BloomPass1(float4 vpos : SV_POSITION, float2 texcoord : TEXCOORD) : SV_Target
{
	float4 bloom=0.0;
	float2 bloomuv;

	float2 offset[8]=
	{
		float2(1.0, 1.0),
		float2(0.0, -1.0),
		float2(-1.0, 1.0),
		float2(-1.0, -1.0),
		float2(0.0, 1.0),
		float2(0.0, -1.0),
		float2(1.0, 0.0),
		float2(-1.0, 0.0)
	};

	for (int i=0; i<8; i++)
	{
		bloomuv.xy=offset[i]*PixelSize.xy*4;
		bloomuv.xy=texcoord.xy + bloomuv.xy;
		float4 tempbloom=tex2Dlod(SamplerBloom1, float4(bloomuv.xy, 0, 0));
		bloom+=tempbloom;
	}

	bloom *= 0.125;
	return bloom;
}

float4 PS_ME_BloomPass2(float4 vpos : SV_POSITION, float2 texcoord : TEXCOORD) : SV_Target
{
	float4 bloom=0.0;
	float2 bloomuv;

	float2 offset[8]=
	{
		float2(0.707, 0.707),
		float2(0.707, -0.707),
		float2(-0.707, 0.707),
		float2(-0.707, -0.707),
		float2(0.0, 1.0),
		float2(0.0, -1.0),
		float2(1.0, 0.0),
		float2(-1.0, 0.0)
	};

	for (int i=0; i<8; i++)
	{
		bloomuv.xy=offset[i]*PixelSize.xy*8;
		bloomuv.xy=texcoord.xy + bloomuv.xy;
		float4 tempbloom=tex2Dlod(SamplerBloom2, float4(bloomuv.xy, 0, 0));
		bloom+=tempbloom;
	}

	bloom *= 0.5; //to brighten up the sample, it will lose brightness in H/V gaussian blur
	return bloom;
}


float4 PS_ME_BloomPass3(float4 vpos : SV_POSITION, float2 texcoord : TEXCOORD) : SV_Target
{
	float4 bloom = 0.0;
	bloom = GaussBlur22(texcoord.xy, SamplerBloom3, 16, 0, 0);
	bloom.xyz *= fBloomAmount;
	return bloom;
}

float4 PS_ME_BloomPass4(float4 vpos : SV_POSITION, float2 texcoord : TEXCOORD) : SV_Target
{
	float4 bloom = 0.0;
	bloom.xyz = GaussBlur22(texcoord.xy, SamplerBloom4, 16, 0, 1).xyz*2.5;
	return bloom;
}

float4 PS_Lighting(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float4 color = tex2D(RFX_backbufferColor, texcoord);

	#if (USE_BLOOM == 1)
		float3 colorbloom=0;

		colorbloom.xyz += tex2D(SamplerBloom3, texcoord.xy).xyz*1.0;
		colorbloom.xyz += tex2D(SamplerBloom5, texcoord.xy).xyz*9.0;
		colorbloom.xyz *= 0.1;

		colorbloom.xyz = saturate(colorbloom.xyz);
		float colorbloomgray = dot(colorbloom.xyz, 0.333);
		colorbloom.xyz = lerp(colorbloomgray, colorbloom.xyz, fBloomSaturation);
		colorbloom.xyz *= fBloomTint;
		float colorgray = dot(color.xyz, 0.333);

		if(iBloomMixmode == 1) color.xyz = color.xyz + colorbloom.xyz;
		if(iBloomMixmode == 2) color.xyz = 1-(1-color.xyz)*(1-colorbloom.xyz);
		if(iBloomMixmode == 3) color.xyz = max(0.0f,max(color.xyz,lerp(color.xyz,(1.0f - (1.0f - saturate(colorbloom.xyz)) *(1.0f - saturate(colorbloom.xyz * 1.0))),1.0)));
		if(iBloomMixmode == 4) color.xyz = max(color.xyz, colorbloom.xyz);
	#endif

	#if (USE_LENSDIRT == 1)
		float lensdirtmult = dot(tex2D(SamplerBloom5, texcoord.xy).xyz, 0.333);
		float3 dirttex = tex2D(SamplerDirt, texcoord.xy).xyz;

		float3 lensdirt = dirttex.xyz*lensdirtmult*fLensdirtIntensity*fLensdirtTint;
		lensdirt = lerp(dot(lensdirt.xyz,0.333), lensdirt.xyz, fLensdirtSaturation);

		if(iLensdirtMixmode == 1) color.xyz = color.xyz + lensdirt.xyz;
		if(iLensdirtMixmode == 2) color.xyz = 1-(1-color.xyz)*(1-lensdirt.xyz);
		if(iLensdirtMixmode == 3) color.xyz = max(0.0f,max(color.xyz,lerp(color.xyz,(1.0f - (1.0f - saturate(lensdirt.xyz)) *(1.0f - saturate(lensdirt.xyz * 1.0))),1.0)));
		if(iLensdirtMixmode == 4) color.xyz = max(color.xyz, lensdirt.xyz);
	#endif

	// unsharp
	return color;
}
