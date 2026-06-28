// Radial god-ray bloom from bright upper-screen pixels (no depth buffer).

float Luma(vec3 c)
{
	return dot(c, vec3(0.2126, 0.7152, 0.0722));
}

float SkyMask(vec2 uv, vec3 rgb)
{
	float upper = smoothstep(0.08, 0.45, uv.y);
	float bright = smoothstep(0.35, 0.75, Luma(rgb));
	return upper * bright;
}

void main()
{
	vec4 src = texture(InputTexture, TexCoord);
	if (sss_atmo_godrays_strength <= 0.001)
	{
		FragColor = src;
		return;
	}

	vec2 lightPos = vec2(0.5, 0.82);
	vec2 delta = TexCoord - lightPos;
	float dist = length(delta);
	vec2 dir = delta / max(dist, 0.0001);

	float accum = 0.0;
	const int steps = 8;
	vec2 ts = 1.0 / vec2(textureSize(InputTexture, 0));
	for (int i = 1; i <= steps; i++)
	{
		vec2 sampleUV = TexCoord - dir * ts * float(i) * 6.0;
		vec3 sampleRgb = texture(InputTexture, sampleUV).rgb;
		float bright = max(max(sampleRgb.r, sampleRgb.g), sampleRgb.b);
		accum += bright * SkyMask(sampleUV, sampleRgb);
	}
	accum /= float(steps);

	float shaft = accum * sss_atmo_godrays_strength;
	shaft *= smoothstep(0.65, 0.05, dist);
	shaft *= 1.0 - SkyMask(TexCoord, src.rgb) * 0.7;

	vec3 outRgb = src.rgb + vec3(1.0, 0.95, 0.82) * shaft;
	FragColor = vec4(outRgb, src.a);
}
