const float FP16Scale = 0.0009765625;

vec3 LinearTosRGB(in vec3 color)
{
	vec3 x = color * 12.920;
	vec3 y = 1.055 * pow(clamp(color, 0.0, 1.0), vec3(0.416666666)) - vec3(0.055);

	vec3 clr;
	clr.r = color.r < 0.00313080 ? x.r : y.r;
	clr.g = color.g < 0.00313080 ? x.g : y.g;
	clr.b = color.b < 0.00313080 ? x.b : y.b;
	return clr;
}

vec3 SRGBToLinear(in vec3 color)
{
	vec3 x = color / 12.92;
	vec3 y = pow(max((color + vec3(0.055)) / 1.055, 0.0), vec3(2.4));

	vec3 clr;
	clr.r = color.r <= 0.04045 ? x.r : y.r;
	clr.g = color.g <= 0.04045 ? x.g : y.g;
	clr.b = color.b <= 0.04045 ? x.b : y.b;
	return clr;
}

float SaturationBasedExposure()
{
	float maxLuminance = (7800.0 / 65.0) * (ApertureFNumber * ApertureFNumber) / (ISO * ShutterSpeedValue);
	return log2(1.0 / maxLuminance);
}

float StandardOutputBasedExposure(float middleGrey)
{
	float lAvg = (1000.0 / 65.0) * (ApertureFNumber * ApertureFNumber) / (ISO * ShutterSpeedValue);
	return log2(middleGrey / lAvg);
}

float CalcExposure()
{
	float exposure = ExposureMode == 0 ?
		SaturationBasedExposure() :
		StandardOutputBasedExposure(0.18);
	return exposure - log2(FP16Scale);
}

const mat3 ACESInputMat = mat3(
	0.597190, 0.354580, 0.048230,
	0.076000, 0.908340, 0.015660,
	0.028400, 0.133830, 0.837770
);

const mat3 ACESOutputMat = mat3(
	 1.604750, -0.531080, -0.073670,
	-0.102080,  1.108130, -0.006050,
	-0.003270, -0.072760,  1.076020
);

vec3 RRTAndODTFit(vec3 v)
{
	vec3 a = v * (v + vec3(0.0245786)) - vec3(0.000090537);
	vec3 b = v * (0.983729 * v + vec3(0.4329510)) + vec3(0.238081);
	return a / b;
}

vec3 ACESTonemapFull(in vec3 color)
{
	vec3 acesColor = max(color * ACESInputMat, vec3(0.0));
	acesColor = RRTAndODTFit(acesColor);
	acesColor = acesColor * ACESOutputMat;
	return max(acesColor, vec3(0.0));
}

vec3 ACESTonemapNarkowicz(in vec3 x)
{
	const float a = 2.51;
	const float b = 0.03;
	const float c = 2.43;
	const float d = 0.59;
	const float e = 0.14;
	return max((x * (a * x + b)) / (x * (c * x + d) + e), vec3(0.0));
}

vec3 ApplyTonemap(in vec3 color)
{
	if (ACESMode == 1)
		return ACESTonemapNarkowicz(color);
	return ACESTonemapFull(color);
}

float max3(vec3 v)
{
	return max(max(v.x, v.y), v.z);
}

vec3 SoftHighlightShoulder(vec3 c)
{
	// Gentle roll-off above ~0.9 so skies/emissives keep hue instead of clipping to white.
	return c / (vec3(1.0) + max(c - 0.90, vec3(0.0)) * 3.0);
}

vec3 ApplyChromaPreservingTonemap(in vec3 exposed)
{
	vec3 peak = vec3(max3(exposed));
	peak = max(peak, vec3(1e-5));
	vec3 ratio = exposed / peak;

	vec3 tonemapPeak = ApplyTonemap(peak);

	float crossSat = max(crossSaturation, 1e-3);
	ratio = pow(ratio, vec3(saturation / crossSat));
	// User crosstalk is aggressive at 3+; scale and cap bleach so fireballs/sky keep color.
	float bleach = pow(clamp(max3(tonemapPeak), 0.0, 1.0), crossTalk * 0.40);
	bleach = min(bleach, 0.50);
	ratio = mix(ratio, vec3(1.0), bleach);
	ratio = pow(ratio, vec3(crossSat));

	vec3 outCol = SoftHighlightShoulder(tonemapPeak * ratio);
	return clamp(outCol, 0.0, 1.0);
}

void main()
{
	vec3 color = texture(InputTexture, TexCoord).rgb;
	vec3 lin = SRGBToLinear(color);
	float hot = max3(lin);
	// Pull back exposure on already-bright emissive pixels (sky, fireballs, explosions).
	float hlGate = 1.0 / (1.0 + max(hot - 0.65, 0.0) * 1.75);
	vec3 exposed = lin * exp2(CalcExposure()) * exposureBias * mix(1.0, hlGate, 0.65);
	vec3 tonemapped = ApplyChromaPreservingTonemap(exposed);
	FragColor = vec4(LinearTosRGB(tonemapped), 1.0);
}
