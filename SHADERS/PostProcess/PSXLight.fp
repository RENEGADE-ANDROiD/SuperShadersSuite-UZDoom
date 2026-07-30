// Adapted from PSX DOOM CE (Molecicco) psxlight.fp — console gamma + 5:5:5 banding.
// Material PSX lighting (psx.fp) is intentionally not ported.

const float BRIGHT_LEVEL = 128.0;

float GetPsxBrightLevel(float level)
{
	return ((255.0 + level) / 255.0);
}

vec3 PSXClut(vec3 frag)
{
	float r = floor((frag.r * 255.0) / 8.0);
	float g = floor((frag.g * 255.0) / 8.0) * 32.0;
	float b = floor((frag.b * 255.0) / 8.0) * 1024.0;
	frag.r = ((r * 8.0)) / 255.0;
	frag.g = ((g / 32.0) * 8.0) / 255.0;
	frag.b = ((b / 1024.0) * 8.0) / 255.0;
	return frag;
}

void main()
{
	vec3 frag = texture(InputTexture, TexCoord).rgb;

	if (mode > 0)
	{
		float uPsxBrightLevel = GetPsxBrightLevel(BRIGHT_LEVEL);
		if (mode == 2) // milder D64-style compensation
			uPsxBrightLevel *= 0.75;
		frag.r = clamp(frag.r * uPsxBrightLevel, 0.0, 1.0);
		frag.g = clamp(frag.g * uPsxBrightLevel, 0.0, 1.0);
		frag.b = clamp(frag.b * uPsxBrightLevel, 0.0, 1.0);
	}

	if (banding == 1)
		frag = PSXClut(frag);

	FragColor = vec4(frag, 1.0);
}
