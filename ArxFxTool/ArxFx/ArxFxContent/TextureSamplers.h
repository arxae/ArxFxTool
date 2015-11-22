// Textures & Samplers
texture RFX_depthBufferTex : DEPTH;
texture RFX_depthTex { Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; Format = R32F; };
texture RFX_backbufferTex : COLOR;
texture RFX_originalTex : COLOR;
texture2D texLDR : COLOR;
texture   texHDR1 	{ Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; MipLevels = 5; Format = RENDERMODE;};
texture   texHDR2 	{ Width = BUFFER_WIDTH; Height = BUFFER_HEIGHT; MipLevels = 5; Format = RENDERMODE;};

sampler RFX_depthColor { Texture = RFX_depthBufferTex; };
sampler RFX_depthTexColor { Texture = RFX_depthTex; };
sampler RFX_backbufferColor { Texture = RFX_backbufferTex; };
sampler RFX_originalColor { Texture = RFX_originalTex; };

sampler2D SamplerLDR
{
	Texture = texLDR;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU = Clamp;
	AddressV = Clamp;
};

sampler2D SamplerHDR1
{
	Texture = texHDR1;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU = Clamp;
	AddressV = Clamp;
};

sampler2D SamplerHDR2
{
	Texture = texHDR2;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU = Clamp;
	AddressV = Clamp;
};
