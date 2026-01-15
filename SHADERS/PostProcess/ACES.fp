const float FP16Scale = 0.0009765625f;

vec3 toLinear(vec3 rgb)
{
  rgb = max(vec3(6.10352e-5), rgb);
  bvec3 bRGB = greaterThan(rgb, vec3(0.04045));
  if(bRGB.x && bRGB.y && bRGB.z) return pow( rgb * (1.0 / 1.055) + 0.0521327, vec3(2.4) );
  else rgb * (1.0 / 12.92);
}

vec3 toGamma(vec3 lin)
{
  lin = max(vec3(6.10352e-5), lin);
  return min(lin * 12.92, pow(max(lin, 0.00313067), vec3(1.0/2.4)) * 1.055 - 0.055);
}

vec3 LinearTosRGB(in vec3 color)
{
    vec3 x = color * 12.920;
    vec3 y = 1.0550 * pow(clamp(color,0.0,1.0), vec3(0.416666666)) - vec3(0.0550); //1.0 / 2.4

    vec3 clr = color;
    clr.r = color.r < 0.00313080 ? x.r : y.r;
    clr.g = color.g < 0.00313080 ? x.g : y.g;
    clr.b = color.b < 0.00313080 ? x.b : y.b;

    return clr;
}

vec3 SRGBToLinear(in vec3 color)
{
    vec3 x = color / 12.92f;
    vec3 y = pow(max((color + vec3(0.055f)) / 1.055f, 0.0f), vec3(2.4f));
	
    vec3 clr = color;
    clr.r = color.r <= 0.04045f ? x.r : y.r;
    clr.g = color.g <= 0.04045f ? x.g : y.g;
    clr.b = color.b <= 0.04045f ? x.b : y.b;

    return clr;
}

float SaturationBasedExposure()
{
    float maxLuminance = (7800.0f / 65.0f) * (ApertureFNumber * ApertureFNumber) / (ISO * ShutterSpeedValue);
    return log2(1.0f / maxLuminance);
}

float StandardOutputBasedExposure(float middleGrey)
{
    float lAvg = (1000.0f / 65.0f) * (ApertureFNumber * ApertureFNumber) / (ISO * ShutterSpeedValue);
    return log2(middleGrey / lAvg);
}

float CalcLuminance(vec3 color)
{
    return dot(color, vec3(0.75, 0.75, 0.75));
}

float Log2Exposure(in vec3 color)
{
	float exposure = 0.0;
	if(ExposureMode == 0) {
		exposure = SaturationBasedExposure();
	}
	else {
		exposure = StandardOutputBasedExposure(0.18);
	}
	exposure -= log2(FP16Scale);
	return exposure;
}

const mat3 ACESInputMat = mat3(
	0.597190, 0.354580, 0.048230, 
	0.076000, 0.908340, 0.015660, 
	0.028400, 0.133830, 0.837770
);

const mat3 ACESOutputMat = mat3(
	 1.604750, -0.531080, -0.073670, 
	 -0.102080, 1.108130, -0.006050,
	 -0.003270, -0.072760, 1.076020
);

vec3 RRTAndODTFit(vec3 v)
{
    vec3 a = v * (v + vec3(0.0245786)) - vec3(0.000090537);
    vec3 b = v * (0.983729 * v + vec3(0.4329510)) + vec3(0.238081);
    return a / b;
}

vec3 ACESTonemap(in vec3 color)
{
	vec3 acesColor = color * ACESInputMat;

	acesColor = max( vec3(0.0), acesColor );

	acesColor = RRTAndODTFit(acesColor);

	acesColor = acesColor * ACESOutputMat;

	acesColor = clamp(acesColor,0.0,1.0);

	return acesColor;
}

float max3 (vec3 v) {
  return max (max (v.x, v.y), v.z);
}

vec3 ACESWrapper(in vec3 color)
{
	vec3 exp = exp2(Log2Exposure(color)) * SRGBToLinear(color);
	
	vec3 tonemapMax = vec3(max3(exp));
	vec3 ratio = exp / tonemapMax;
	tonemapMax = ACESTonemap(tonemapMax);
	
	ratio = pow(ratio, vec3(saturation / crossSaturation));
	ratio = mix(ratio, vec3(1.0), pow(tonemapMax, vec3(crossTalk) ));
	ratio = pow(ratio, vec3(crossSaturation));
	
	vec3 outColor = tonemapMax * ratio;

	return LinearTosRGB(outColor * 1.8f);
}

void main()
{
	vec3 color = texture(InputTexture, TexCoord).rgb;
	vec3 outColor = ACESWrapper(color);
	FragColor = vec4(outColor,1.0);
}