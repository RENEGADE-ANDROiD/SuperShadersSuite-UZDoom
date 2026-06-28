// Screen-space aerial perspective — distance proxy via lower-screen weight + luma falloff.

float Luma(vec3 c)
{
	return dot(c, vec3(0.2126, 0.7152, 0.0722));
}

void main()
{
	vec4 src = texture(InputTexture, TexCoord);
	if (sss_atmo_haze_strength <= 0.001)
	{
		FragColor = src;
		return;
	}

	float sky = smoothstep(0.12, 0.55, TexCoord.y);
	float depthProxy = (1.0 - TexCoord.y) * (1.0 - sky);
	depthProxy *= smoothstep(0.05, 0.35, Luma(src.rgb));
	depthProxy = pow(clamp(depthProxy, 0.0, 1.0), 1.35);

	vec3 tint = mix(vec3(1.0), vec3(0.72, 0.82, 1.0), sss_atmo_haze_tint);
	float haze = depthProxy * sss_atmo_haze_strength;
	vec3 outRgb = mix(src.rgb, src.rgb * tint + tint * 0.04, haze);
	outRgb = mix(src.rgb, outRgb, 1.0 - sky * 0.85);

	FragColor = vec4(outRgb, src.a);
}
