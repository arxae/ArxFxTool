// Color to Grayscale
float CtG(float3 RGB) { return  sqrt( (1.0/3.0)*((RGB*RGB).r + (RGB*RGB).g + (RGB*RGB).b) ); }

float4 AdaptiveSharpenPass(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	// Get points and saturate out of range values (BTB & WTW)
	// [                c22               ]
	// [           c24, c9,  c23          ]
	// [      c21, c1,  c2,  c3, c18      ]
	// [ c19, c10, c4,  c0,  c5, c11, c16 ]
	// [      c20, c6,  c7,  c8, c17      ]
	// [           c15, c12, c14          ]
	// [                c13               ]
	float3 c19 = saturate( tex2D(RFX_backbufferColor, texcoord + float2(-3*PixelSize.x,   0)).rgb );
	float3 c21 = saturate( tex2D(RFX_backbufferColor, texcoord + float2(-2*PixelSize.x,  -PixelSize.y)).rgb );
	float3 c10 = saturate( tex2D(RFX_backbufferColor, texcoord + float2(-2*PixelSize.x,   0)).rgb );
	float3 c20 = saturate( tex2D(RFX_backbufferColor, texcoord + float2(-2*PixelSize.x,   PixelSize.y)).rgb );
	float3 c24 = saturate( tex2D(RFX_backbufferColor, texcoord + float2(  -PixelSize.x,-2*PixelSize.y)).rgb );
	float3 c1  = saturate( tex2D(RFX_backbufferColor, texcoord + float2(  -PixelSize.x,  -PixelSize.y)).rgb );
	float3 c4  = saturate( tex2D(RFX_backbufferColor, texcoord + float2(  -PixelSize.x,   0)).rgb );
	float3 c6  = saturate( tex2D(RFX_backbufferColor, texcoord + float2(  -PixelSize.x,   PixelSize.y)).rgb );
	float3 c15 = saturate( tex2D(RFX_backbufferColor, texcoord + float2(  -PixelSize.x, 2*PixelSize.y)).rgb );
	float3 c22 = saturate( tex2D(RFX_backbufferColor, texcoord + float2(   0, -3*PixelSize.y)).rgb );
	float3 c9  = saturate( tex2D(RFX_backbufferColor, texcoord + float2(   0, -2*PixelSize.y)).rgb );
	float3 c2  = saturate( tex2D(RFX_backbufferColor, texcoord + float2(   0,   -PixelSize.y)).rgb );
	float3 c0  = saturate( tex2D(RFX_backbufferColor, texcoord).rgb );
	float3 c7  = saturate( tex2D(RFX_backbufferColor, texcoord + float2(   0,    PixelSize.y)).rgb );
	float3 c12 = saturate( tex2D(RFX_backbufferColor, texcoord + float2(   0,  2*PixelSize.y)).rgb );
	float3 c13 = saturate( tex2D(RFX_backbufferColor, texcoord + float2(   0,  3*PixelSize.y)).rgb );
	float3 c23 = saturate( tex2D(RFX_backbufferColor, texcoord + float2(   PixelSize.x,-2*PixelSize.y)).rgb );
	float3 c3  = saturate( tex2D(RFX_backbufferColor, texcoord + float2(   PixelSize.x,  -PixelSize.y)).rgb );
	float3 c5  = saturate( tex2D(RFX_backbufferColor, texcoord + float2(   PixelSize.x,   0)).rgb );
	float3 c8  = saturate( tex2D(RFX_backbufferColor, texcoord + float2(   PixelSize.x,   PixelSize.y)).rgb );
	float3 c14 = saturate( tex2D(RFX_backbufferColor, texcoord + float2(   PixelSize.x, 2*PixelSize.y)).rgb );
	float3 c18 = saturate( tex2D(RFX_backbufferColor, texcoord + float2( 2*PixelSize.x,  -PixelSize.y)).rgb );
	float3 c11 = saturate( tex2D(RFX_backbufferColor, texcoord + float2( 2*PixelSize.x,   0)).rgb );
	float3 c17 = saturate( tex2D(RFX_backbufferColor, texcoord + float2( 2*PixelSize.x,   PixelSize.y)).rgb );
	float3 c16 = saturate( tex2D(RFX_backbufferColor, texcoord + float2( 3*PixelSize.x,   0)).rgb );

	// Blur, gauss 3x3
	float3 blur   = (2*(c2 + c4 + c5 + c7) + (c1 + c3 + c6 +c8) + 4*c0)/16;
	float  blur_Y = (blur.r*(1.0/3.0) + blur.g*(1.0/3.0) + blur.b*(1.0/3.0));

	// Edge detection
	// Matrix, relative weights
	// [           1          ]
	// [       4,  4,  4      ]
	// [   1,  4,  4,  4,  1  ]
	// [       4,  4,  4      ]
	// [           1          ]
	float edge = length( abs(blur-c0) + abs(blur-c1) + abs(blur-c2) + abs(blur-c3)
	                   + abs(blur-c4) + abs(blur-c5) + abs(blur-c6) + abs(blur-c7) + abs(blur-c8)
	                   + 0.25*(abs(blur-c9) + abs(blur-c10) + abs(blur-c11) + abs(blur-c12)) )*(1.0/3.0);

	// Edge detect contrast compression, center = 0.5
	edge *= min((0.8+2.7*pow(2, (-7.4*blur_Y))), 3.2);

	// RGB to greyscale
	float c0_Y = CtG(c0);

	float kernel[25] = { c0_Y,  CtG(c1), CtG(c2), CtG(c3), CtG(c4), CtG(c5), CtG(c6), CtG(c7), CtG(c8),
	                     CtG(c9), CtG(c10), CtG(c11), CtG(c12), CtG(c13), CtG(c14), CtG(c15), CtG(c16),
	                     CtG(c17), CtG(c18), CtG(c19), CtG(c20), CtG(c21), CtG(c22), CtG(c23), CtG(c24) };

	// Partial laplacian outer pixel weighting scheme
	float mdiff_c0  = 0.03 + 4*( abs(kernel[0]-kernel[2]) + abs(kernel[0]-kernel[4])
	                           + abs(kernel[0]-kernel[5]) + abs(kernel[0]-kernel[7])
	                           + 0.25*(abs(kernel[0]-kernel[1]) + abs(kernel[0]-kernel[3])
	                                  +abs(kernel[0]-kernel[6]) + abs(kernel[0]-kernel[8])) );

	float mdiff_c9  = ( abs(kernel[9]-kernel[2])   + abs(kernel[9]-kernel[24])
	                  + abs(kernel[9]-kernel[23])  + abs(kernel[9]-kernel[22])
	                  + 0.5*(abs(kernel[9]-kernel[1]) + abs(kernel[9]-kernel[3])) );

	float mdiff_c10 = ( abs(kernel[10]-kernel[20]) + abs(kernel[10]-kernel[19])
	                  + abs(kernel[10]-kernel[21]) + abs(kernel[10]-kernel[4])
	                  + 0.5*(abs(kernel[10]-kernel[1]) + abs(kernel[10]-kernel[6])) );

	float mdiff_c11 = ( abs(kernel[11]-kernel[17]) + abs(kernel[11]-kernel[5])
	                  + abs(kernel[11]-kernel[18]) + abs(kernel[11]-kernel[16])
	                  + 0.5*(abs(kernel[11]-kernel[3]) + abs(kernel[11]-kernel[8])) );

	float mdiff_c12 = ( abs(kernel[12]-kernel[13]) + abs(kernel[12]-kernel[15])
	                  + abs(kernel[12]-kernel[7])  + abs(kernel[12]-kernel[14])
	                  + 0.5*(abs(kernel[12]-kernel[6]) + abs(kernel[12]-kernel[8])) );

	float4 weights  = float4( (min((mdiff_c0/mdiff_c9), 2)), (min((mdiff_c0/mdiff_c10),2)),
	                          (min((mdiff_c0/mdiff_c11),2)), (min((mdiff_c0/mdiff_c12),2)) );

	// Negative laplace matrix
	// Matrix, relative weights, *Varying 0<->8
	// [          8*         ]
	// [      4,  1,  4      ]
	// [  8*, 1,      1,  8* ]
	// [      4,  1,  4      ]
	// [          8*         ]
	float neg_laplace = ( 0.25 * (kernel[2] + kernel[4] + kernel[5] + kernel[7])
	                      +      (kernel[1] + kernel[3] + kernel[6] + kernel[8])
	                      +      ((kernel[9]*weights.x) + (kernel[10]*weights.y)
	                      +      (kernel[11]*weights.z) + (kernel[12]*weights.w)) )
	                      /      (5 + weights.x + weights.y + weights.z + weights.w);

	// Compute sharpening magnitude function, x = edge mag, y = laplace operator mag
	float sharpen_val =  0.01 + (curve_height/(curveslope*pow(edge, 3.5) + 0.5))
	                          - (curve_height/(8192*pow((edge*2.2), 4.5) + 0.5));

	// Calculate sharpening diff and scale
	float sharpdiff = (c0_Y - neg_laplace)*(sharpen_val*0.8);

	// Calculate local near min & max, partial cocktail sort (No branching!)
	[unroll] // ps_4_0+ does not unroll without this
	for (int i = 0; i < 2; ++i)
	{
		for (int i1 = 1+i; i1 < 25-i; ++i1)
		{
			float temp   = kernel[i1-1];
			kernel[i1-1] = min(kernel[i1-1], kernel[i1]);
			kernel[i1]   = max(temp, kernel[i1]);
		}

		for (int i2 = 23-i; i2 > i; --i2)
		{
			float temp   = kernel[i2-1];
			kernel[i2-1] = min(kernel[i2-1], kernel[i2]);
			kernel[i2]   = max(temp, kernel[i2]);
		}
	}

	float nmax = max(((kernel[23] + kernel[24])/2), c0_Y);
	float nmin = min(((kernel[0]  + kernel[1])/2),  c0_Y);

	// Calculate tanh scale factor, pos/neg
	float nmax_scale = max((1/((nmax - c0_Y) + L_overshoot)), max_scale_lim);
	float nmin_scale = max((1/((c0_Y - nmin) + D_overshoot)), max_scale_lim);

	// Soft limit sharpening with tanh, lerp to control maximum compression
	sharpdiff = lerp( (tanh((max(sharpdiff, 0))*nmax_scale)/nmax_scale), (max(sharpdiff, 0)), L_comp_ratio )
	          + lerp( (tanh((min(sharpdiff, 0))*nmin_scale)/nmin_scale), (min(sharpdiff, 0)), D_comp_ratio );

	// Set the alpha channel to 1 to prevent strange effects in MPDN
	if (video_level_out == 1) { return float4( (tex2D(RFX_backbufferColor, texcoord) + sharpdiff).rgb, 1 ); }

	return float4( (c0 + sharpdiff), 1 );
}

float4 PS_ImageEnhancements(float4 vpos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target
{
	float4 color = tex2D(RFX_backbufferColor, texcoord);

	#if(USE_ADPSHARPENING == 1)
		color = AdaptiveSharpenPass(color, texcoord);
	#endif

	return color;
}
