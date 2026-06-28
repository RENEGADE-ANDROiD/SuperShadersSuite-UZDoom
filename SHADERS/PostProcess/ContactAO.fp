// Screen-space contact darkening with optional depth-proxy edge rejection.
// Engine SSAO uses real depth; custom PP uses luminance + depth proxy heuristics.

float Luma(vec3 c)
{
	return dot(c, vec3(0.2126, 0.7152, 0.0722));
}

float SkyMask(vec2 uv, vec3 rgb)
{
	float luma = Luma(rgb);
	float upper = smoothstep(0.10, 0.50, uv.y);
	float bright = smoothstep(0.18, 0.48, luma);
	float peak = smoothstep(0.45, 0.78, max(max(rgb.r, rgb.g), rgb.b));
	float cloudBody = upper * smoothstep(0.12, 0.38, luma);
	float brightSky = upper * bright * mix(0.7, 1.0, peak);
	return clamp(max(cloudBody, brightSky), 0.0, 1.0);
}

float DepthProxyEdge(vec2 uv, vec3 rgb)
{
	if (sss_depth_proxy <= 0.001)
		return 1.0;

	vec2 ts = 1.0 / textureSize(InputTexture, 0);
	float l0 = Luma(rgb);
	float lXp = Luma(texture(InputTexture, uv + vec2( ts.x, 0.0)).rgb);
	float lXm = Luma(texture(InputTexture, uv + vec2(-ts.x, 0.0)).rgb);
	float lYp = Luma(texture(InputTexture, uv + vec2(0.0,  ts.y)).rgb);
	float lYm = Luma(texture(InputTexture, uv + vec2(0.0, -ts.y)).rgb);
	float edge = max(max(abs(lXp - l0), abs(lXm - l0)), max(abs(lYp - l0), abs(lYm - l0)));
	float lower = 1.0 - smoothstep(0.08, 0.72, uv.y);
	return clamp(mix(1.0, edge * 8.0 + lower * 0.4, sss_depth_proxy), 0.15, 1.0);
}

// Attenuate on close flat mid-tones where texel crawl dominates (no depth buffer).
// Returns 1 = full effect, 0 = bypass. Keep in sync with mfx_lumasharp / mfx_bss_sharp.
float TextureCrawlEffectKeep(vec2 uv, vec3 rgb, float flatSoften)
{
	if (flatSoften <= 0.001)
		return 1.0;

	vec2 ts = 1.0 / textureSize(InputTexture, 0);
	float l0 = Luma(rgb);
	float midTone = smoothstep(0.10, 0.28, l0) * (1.0 - smoothstep(0.72, 0.92, l0));

	float lXp = Luma(texture(InputTexture, uv + vec2( ts.x, 0.0)).rgb);
	float lXm = Luma(texture(InputTexture, uv + vec2(-ts.x, 0.0)).rgb);
	float lYp = Luma(texture(InputTexture, uv + vec2(0.0,  ts.y)).rgb);
	float lYm = Luma(texture(InputTexture, uv + vec2(0.0, -ts.y)).rgb);
	float microAvg = (lXp + lXm + lYp + lYm) * 0.25;
	float microDev = max(max(abs(lXp - microAvg), abs(lXm - microAvg)),
	                     max(abs(lYp - microAvg), abs(lYm - microAvg)));

	vec2 ms = ts * 4.0;
	float LXp = Luma(texture(InputTexture, uv + vec2( ms.x, 0.0)).rgb);
	float LXm = Luma(texture(InputTexture, uv + vec2(-ms.x, 0.0)).rgb);
	float LYp = Luma(texture(InputTexture, uv + vec2(0.0,  ms.y)).rgb);
	float LYm = Luma(texture(InputTexture, uv + vec2(0.0, -ms.y)).rgb);
	float macroAvg = (LXp + LXm + LYp + LYm) * 0.25;
	float macroEdge = abs(l0 - macroAvg);

	float crawl = clamp((microDev - macroEdge * 0.85) / 0.08, 0.0, 1.0);
	crawl *= midTone;
	float flatMacro = 1.0 - smoothstep(0.015, 0.09, macroEdge);
	float soften = crawl * flatMacro * flatSoften;

	return 1.0 - clamp(soften, 0.0, 0.95);
}

// PB/HD floor tiles: repeating micro-contrast reads as AO crawl in the lower screen.
float FloorTextureGuard(vec2 uv, vec3 rgb, float flatSoften)
{
	if (flatSoften <= 0.001)
		return 1.0;

	float floorZone = smoothstep(0.42, 0.82, uv.y);
	if (floorZone < 0.01)
		return 1.0;

	vec2 ts = 1.0 / textureSize(InputTexture, 0);
	float l0 = Luma(rgb);
	float lXp = Luma(texture(InputTexture, uv + vec2( ts.x, 0.0)).rgb);
	float lXm = Luma(texture(InputTexture, uv + vec2(-ts.x, 0.0)).rgb);
	float lYp = Luma(texture(InputTexture, uv + vec2(0.0,  ts.y)).rgb);
	float lYm = Luma(texture(InputTexture, uv + vec2(0.0, -ts.y)).rgb);
	float microAvg = (lXp + lXm + lYp + lYm) * 0.25;
	float microDev = max(max(abs(lXp - microAvg), abs(lXm - microAvg)),
	                     max(abs(lYp - microAvg), abs(lYm - microAvg)));

	float detail = clamp(microDev / 0.055, 0.0, 1.0);
	float kill = floorZone * detail * flatSoften;
	return 1.0 - clamp(kill, 0.0, 0.97);
}

void main()
{
	if (sss_contactao_strength <= 0.0)
	{
		FragColor = texture(InputTexture, TexCoord);
		return;
	}

	vec4 center = texture(InputTexture, TexCoord);
	float sky = SkyMask(TexCoord, center.rgb);
	if (sky > 0.40)
	{
		FragColor = center;
		return;
	}

	float lum = Luma(center.rgb);
	vec2 texel = sss_contactao_radius / textureSize(InputTexture, 0);

	float occlusion = 0.0;
	const int samples = 8;
	for (int i = 0; i < samples; i++)
	{
		float angle = float(i) * 0.785398163;
		vec2 offset = vec2(cos(angle), sin(angle)) * texel;
		vec2 sampleUV = TexCoord + offset;
		float neighbor = Luma(texture(InputTexture, sampleUV).rgb);
		float depthW = DepthProxyEdge(sampleUV, texture(InputTexture, sampleUV).rgb);
		occlusion += max(neighbor - lum, 0.0) * depthW;
	}

	occlusion = clamp(occlusion * sss_contactao_strength * 0.35, 0.0, 0.65);
	occlusion *= 1.0 - sky;
	float keep = TextureCrawlEffectKeep(TexCoord, center.rgb, sss_pp_flat_soften);
	keep *= FloorTextureGuard(TexCoord, center.rgb, sss_pp_flat_soften);
	occlusion *= keep;
	FragColor = vec4(center.rgb * (1.0 - occlusion), center.a);
}
