float3 DPXPass(float3 InputColor)
{
	float3x3 RGB =
		float3x3(
			2.67147117265996,-1.26723605786241,-0.410995602172227,
			-1.02510702934664,1.98409116241089,0.0439502493584124,
			0.0610009456429445,-0.223670750812863,1.15902104167061
		);

	float3x3 XYZ =
		float3x3(
			0.500303383543316,0.338097573222739,0.164589779545857,
			0.257968894274758,0.676195259144706,0.0658358459823868,
			0.0234517888692628,0.1126992737203,0.866839673124201
		);

	float DPXContrast = 0.1;
	float DPXGamma = 1.0;

	float RedCurve = DPXRed;
	float GreenCurve = DPXGreen;
	float BlueCurve = DPXBlue;

	float3 RGB_Curve = float3(DPXRed,DPXGreen,DPXBlue);
	float3 RGB_C = float3(DPXRedC,DPXGreenC,DPXBlueC);

	float3 B = InputColor.rgb;
	B = pow(B, 1.0/DPXGamma);
 	B = B * (1.0 - DPXContrast) + (0.5 * DPXContrast);

	float3 Btemp = (1.0 / (1.0 + exp(RGB_Curve / 2.0)));
	B = ((1.0 / (1.0 + exp(-RGB_Curve * (B - RGB_C)))) / (-2.0 * Btemp + 1.0)) + (-Btemp / (-2.0 * Btemp + 1.0));

    float value = max(max(B.r, B.g), B.b);
	float3 color = B / value;
	color = saturate(color);
	color = pow(color, 1.0/DPXColorGamma);

	float3 c0 = color * value;
    c0 = mul(XYZ, c0);

	float luma = dot(c0, float3(0.30, 0.59, 0.11)); //Use BT 709 instead?
    c0 = (1.0 - DPXSaturation) * luma + DPXSaturation * c0;
	c0 = mul(RGB, c0);

	InputColor.rgb = lerp(InputColor.rgb, c0, DPXBlend);

	return InputColor;
}

float3 TechnicolorPass( float3 colorInput )
{
	#define cyanfilter float3(0.0, 1.30, 1.0)
	#define magentafilter float3(1.0, 0.0, 1.05)
	#define yellowfilter float3(1.6, 1.6, 0.05)

	#define redorangefilter float2(1.05, 0.620) //RG_
	#define greenfilter float2(0.30, 1.0)       //RG_
	#define magentafilter2 magentafilter.rb     //R_B

	float3 tcol = colorInput.rgb;

  	float2 rednegative_mul   = tcol.rg * (1.0 / (redNegativeAmount * TechniPower));
	float2 greennegative_mul = tcol.rg * (1.0 / (greenNegativeAmount * TechniPower));
	float2 bluenegative_mul  = tcol.rb * (1.0 / (blueNegativeAmount * TechniPower));

  	float rednegative   = dot( redorangefilter, rednegative_mul );
	float greennegative = dot( greenfilter, greennegative_mul );
	float bluenegative  = dot( magentafilter2, bluenegative_mul );

	float3 redoutput   = rednegative.rrr + cyanfilter;
	float3 greenoutput = greennegative.rrr + magentafilter;
	float3 blueoutput  = bluenegative.rrr + yellowfilter;

	float3 result = redoutput * greenoutput * blueoutput;
	colorInput.rgb = lerp(tcol, result, TechniAmount);
	return colorInput;
}

float3 VibrancePass( float3 colorInput )
{
   	#define Vibrance_coeff float3(Vibrance_RGB_balance * Vibrance)

	float3 color = colorInput; //original input color
  	float3 lumCoeff = float3(0.212656, 0.715158, 0.072186);  //Values to calculate luma with

	float luma = dot(LumCoeff, color.rgb); //calculate luma (grey)

	float max_color = max(colorInput.r, max(colorInput.g,colorInput.b)); //Find the strongest color
	float min_color = min(colorInput.r, min(colorInput.g,colorInput.b)); //Find the weakest color

  	float color_saturation = max_color - min_color; //The difference between the two is the saturation

   	color.rgb = lerp(luma, color.rgb, (1.0 + (Vibrance_coeff * (1.0 - (sign(Vibrance_coeff) * color_saturation))))); //extrapolate between luma and original by 1 + (1-saturation) - current

 	return color; //return the result
}

float3 CrossPass(float3 color)
{
	float2 CrossMatrix [3] = {
		float2(1.03, 0.04),
		float2(1.09, 0.01),
		float2(0.78, 0.13)
	};

	float3 image1 = color;
	float3 image2 = color;
	float gray = dot(float3(0.5,0.5,0.5), image1);

	image1 = lerp (gray, image1,CrossSaturation);
	image1 = lerp (0.35, image1,CrossContrast);
	image1 +=CrossBrightness;
	image2.r = image1.r * CrossMatrix[0].x + CrossMatrix[0].y;
	image2.g = image1.g * CrossMatrix[1].x + CrossMatrix[1].y;
	image2.b = image1.b * CrossMatrix[2].x + CrossMatrix[2].y;
	color = lerp(image1, image2, CrossAmount);

	return color;
}

float4 PS_Colors(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float4 color = tex2D(RFX_backbufferColor, texcoord);

	#if (USE_SWFX_TECHNICOLOR == 1)
		color.xyz = TechnicolorPass(color.xyz);
	#endif

	#if (USE_DPX == 1)
		color.xyz = DPXPass(color.xyz);
	#endif

	#if (USE_VIBRANCE == 1)
		color.xyz = VibrancePass(color.xyz);
	#endif

	#if (USE_CROSSPROCESS == 1)
		color.xyz = CrossPass(color.xyz);
	#endif

	return color;
}
