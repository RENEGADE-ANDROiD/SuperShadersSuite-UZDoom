// Screen-space contact darkening (luminance contrast AO — no depth buffer)

float Luma(vec3 c)
{
	return dot(c, vec3(0.299, 0.587, 0.114));
}

void main()
{
	vec4 center = texture(InputTexture, TexCoord);
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
	FragColor = vec4(center.rgb * (1.0 - occlusion), center.a);
}
