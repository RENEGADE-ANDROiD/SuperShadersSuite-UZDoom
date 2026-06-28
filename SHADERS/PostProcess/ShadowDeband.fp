// Ordered dither in crushed shadows — pairs with Dark Doom + tonemap banding.

float Luma(vec3 c)
{
	return dot(c, vec3(0.2126, 0.7152, 0.0722));
}

float HashDither(vec2 p)
{
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453) - 0.5;
}

void main()
{
	vec4 src = texture(InputTexture, TexCoord);
	if (sss_atmo_deband_strength <= 0.001)
	{
		FragColor = src;
		return;
	}

	float l = Luma(src.rgb);
	float shadow = 1.0 - smoothstep(0.02, 0.22, l);
	if (shadow <= 0.001)
	{
		FragColor = src;
		return;
	}

	vec2 px = TexCoord * vec2(textureSize(InputTexture, 0));
	float d = HashDither(px) * sss_atmo_deband_strength * shadow;
	FragColor = vec4(clamp(src.rgb + d, 0.0, 1.0), src.a);
}
