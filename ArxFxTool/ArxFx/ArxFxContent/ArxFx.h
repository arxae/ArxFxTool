// General/Debug stuff
#define TOGGLE_EFFECTS_KEY		0x23
//#define USE_DEPTBUFFER_OUTPUT	0
//#define USE_SPLITSCREEN			0

// Effects
// Color
#define USE_SWFX_TECHNICOLOR	1
#define USE_DPX					1
#define USE_VIBRANCE			1
#define USE_CROSSPROCESS		1

// Lighting
#define USE_LENSDIRT			1
#define USE_BLOOM				1

// Overlays
#define USE_VIGNETTE			1

// Image Enhancements
#define USE_ADPSHARPENING		0

// Other
#define RENDERMODE 				RGBA8 // RGBA8 | RGBA16F | RGBA32F

// Color effect parameters
// SWFX_TECHNICOLOR
#define TechniAmount 			0.4    	//[0.00 to 1.00] Amount of color change you want
#define TechniPower  			4.0    	//[0.00 to 8.00] Power of color change
#define redNegativeAmount   	0.88 	//[0.00 to 1.00] controls for different technicolor power on the respective color channels
#define greenNegativeAmount 	0.88   	//[0.00 to 1.00]
#define blueNegativeAmount  	0.88   	//[0.00 to 1.00]

//DPX
#define DPXRed   				8.0  	//[1.0 to 15.0] Amount of DPX applies on Red color channel
#define DPXGreen 				8.0  	//[1.0 to 15.0] ""
#define DPXBlue  				8.0  	//[1.0 to 15.0] ""
#define DPXColorGamma    		2.5  	//[0.1 to 2.5] Adjusts the colorfulness of the effect in a manner similar to Vibrance. 1.0 is neutral.
#define DPXSaturation 			3.0  	//[0.0 to 8.0] Adjust saturation of the effect. 1.0 is neutral.
#define DPXRedC   				0.36 	//[0.60 to 0.20]
#define DPXGreenC 				0.36 	//[0.60 to 0.20]
#define DPXBlueC  				0.34 	//[0.60 to 0.20]
#define DPXBlend 				0.2  	//[0.00 to 1.00] How strong the effect should be.

//VIBRANCE
#define Vibrance     			1.15  	//[-1.00 to 1.00] Intelligently saturates (or desaturates if you use negative values) the pixels depending on their original saturation.
#define Vibrance_RGB_balance 	float3(1.00, 1.00, 1.00) //[-10.00 to 10.00,-10.00 to 10.00,-10.00 to 10.00] A per channel multiplier to the Vibrance strength so you can give more boost to certain colors over others

// CROSSPROCESS
#define CrossContrast			0.95  	// [ 0.5 to 2.00 ] The names of these values should explain their functions
#define CrossSaturation			1.12  	// [ 0.5 to 2.00 ]
#define CrossBrightness			-0.052  // [ -0.3 to 0.30 ]
#define CrossAmount				1.0 	// [ 0.05 to 1.5 ]

// Lighting effect parameters
//LENSDIRT
#define fLensdirtIntensity 		3.0	//[0.0 to 2.0] Intensity of lensdirt.
#define fLensdirtSaturation		4.0	//[0.0 to 2.0] Color saturation of lensdirt.
#define fLensdirtTint			float3(1.0,1.0,1.0) //[0.0 to 1.0] R, G and B components of lensdirt tintcolor the lensdirt color gets shifted to.
#define iLensdirtMixmode		2	//[1 to 4] 1: Linear add | 2: Screen add | 3: Screen/Lighten/Opacity | 4: Lighten

//BLOOM
#define iBloomMixmode			2	//[1 to 4] 1: Linear add | 2: Screen add | 3: Screen/Lighten/Opacity | 4: Lighten
#define fBloomThreshold			0.6	//[0.1 to 1.0] Every pixel brighter than this value triggers bloom.
#define fBloomAmount			0.3	//[1.0 to 20.0] Intensity of bloom.
#define fBloomSaturation 		0.8	//[0.0 to 2.0] Bloom saturation. 0.0 means white bloom, 2.0 means very very colorful bloom.
#define fBloomTint 				float3(0.7, 0.8, 1.0) //[0.0 to 1.0] R, G and B components of bloom tintcolor the bloom color gets shifted to.

// Overlays
//STANDARDVIGNETTE
#define fVignetteAmount			2.9	//[0.0 to 5.0] Amount of vignette color change.
#define fVignetteCurve			1.5	//[0.0 to 5.0] Curve of vignette color change.
#define fVignetteRadius			0.95//[0.0 to 5.0] Radius from center where vignette color change kicks in.
#define fVignetteColor			float3(0.0, 0.0, 0.0) //[0.0 to 1.0] RGB vignette color.

// Image Enhancements
//Adaptive Sharpen
#define curve_height 1.00 //[0.15:3.0] //-Main sharpening strength.
#define video_level_out 0 //[0:1] //-(MPC-HC and MPDN specific) True to preserve BTB & WTW (minor summation error). Normally it should be set to false (0).
#define curveslope (curve_height*1.5) //-Sharpening curve slope, edge region.
#define D_overshoot 0.016 //-Max dark overshoot before max compression.
#define D_comp_ratio 0.250 //-Max compression ratio, dark overshoot (1/0.25=4x).
#define L_overshoot 0.004 //-Max light overshoot before max compression.
#define L_comp_ratio 0.167 //-Max compression ratio, light overshoot (1/0.167=6x).
#define max_scale_lim 10.0 //-Abs change before max compression (1/10=?10%).
