const float FP16Scale = 0.0009765625;

// Mild global exposure tame for Doom emissives (skies, fireballs). Tune here only.
const float kPostExposureScale = 0.92;

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
	return clamp(acesColor, 0.0, 1.0);
}

vec3 ACESTonemapNarkowicz(in vec3 x)
{
	const float a = 2.51;
	const float b = 0.03;
	const float c = 2.43;
	const float d = 0.59;
	const float e = 0.14;
	return clamp((x * (a * x + b)) / (x * (c * x + d) + e), 0.0, 1.0);
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

float Luma(vec3 c)
{
	return dot(c, vec3(0.2126, 0.7152, 0.0722));
}

// Heuristic sky mask (no depth buffer in custom PP shaders). Upper frame + clouds/moon.
float ComputeSkyMask(vec2 uv, vec3 lin)
{
	float luma = Luma(lin);
	float upper = smoothstep(0.10, 0.50, uv.y);
	float bright = smoothstep(0.14, 0.42, luma);
	float peak = smoothstep(0.22, 0.58, max3(lin));
	float cloudBody = upper * smoothstep(0.10, 0.32, luma);
	float brightSky = upper * bright * mix(0.65, 1.0, peak);
	return clamp(max(cloudBody, brightSky), 0.0, 1.0);
}

vec3 SoftHighlightShoulder(vec3 c)
{
	return c / (vec3(1.0) + max(c - 0.94, vec3(0.0)) * 2.0);
}

vec3 ApplyChromaPreservingTonemap(in vec3 exposed)
{
	vec3 peak = vec3(max3(exposed));
	peak = max(peak, vec3(1e-5));
	vec3 ratio = exposed / peak;

	vec3 tonemapPeak = ApplyTonemap(peak);

	float crossSat = max(crossSaturation, 1e-3);
	ratio = pow(ratio, vec3(saturation / crossSat));

	float bleach = pow(clamp(max3(tonemapPeak), 0.0, 1.0), crossTalk * 0.45);
	bleach = min(bleach, 0.50);
	ratio = mix(ratio, vec3(1.0), bleach);
	ratio = pow(ratio, vec3(crossSat));

	vec3 outCol = SoftHighlightShoulder(tonemapPeak * ratio);
	return clamp(outCol, 0.0, 1.0);
}

// Skies: skip chroma bleach (banding source) and use a gentler per-channel curve.
vec3 ApplySkyTonemap(in vec3 exposed)
{
	vec3 skyExposed = exposed * 0.90;
	vec3 outCol = ApplyTonemap(skyExposed);
	outCol = mix(outCol, SoftHighlightShoulder(outCol), 0.35);
	return clamp(outCol, 0.0, 1.0);
}

void main()
{
	vec3 color = texture(InputTexture, TexCoord).rgb;
	vec3 lin = SRGBToLinear(color);
	vec3 exposed = lin * exp2(CalcExposure()) * exposureBias * kPostExposureScale;

	vec3 world = ApplyChromaPreservingTonemap(exposed);
	vec3 sky = ApplySkyTonemap(exposed);
	float skyBlend = ComputeSkyMask(TexCoord, lin) * clamp(skySoften, 0.0, 1.0);
	vec3 tonemapped = mix(world, sky, skyBlend);

	FragColor = vec4(LinearTosRGB(tonemapped), 1.0);
}
