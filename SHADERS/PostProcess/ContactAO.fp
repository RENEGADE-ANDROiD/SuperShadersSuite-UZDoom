// Screen-space contact darkening (luminance contrast AO — no depth buffer)

float Luma(vec3 c)
{
	return dot(c, vec3(0.299, 0.587, 0.114));
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
		float neighbor = Luma(texture(InputTexture, TexCoord + offset).rgb);
		occlusion += max(neighbor - lum, 0.0);
	}

	occlusion = clamp(occlusion * sss_contactao_strength * 0.35, 0.0, 0.65);
	occlusion *= 1.0 - sky;
	FragColor = vec4(center.rgb * (1.0 - occlusion), center.a);
}
