void main()
{
	if (amount <= 0.0 || samples <= 0)
	{
		FragColor = texture(InputTexture, TexCoord);
		return;
	}

	vec4 src = texture(InputTexture, TexCoord);
	vec4 c = vec4(src.rgb, 1.0);
	vec4 fc = vec4(src.rgb, 1.0);

	for (int pass = 0; pass < 5; pass++)
	{
		float size;
		if (pass == 0) size = 0.5;
		else if (pass == 1) size = 0.35;
		else if (pass == 2) size = 0.8;
		else if (pass == 3) size = 1.0;
		else size = 0.98;

		for (int i = 0; i < samples; i++)
		{
			vec2 tc = TexCoord;
			if (pass == 4)
			{
				size += distance * 2.0;
				tc *= size;
			}
			else
			{
				size += distance;
				tc.x = tc.x * (1.0 - size) + size * 0.5;
				tc.y = tc.y * (1.0 - size) + size * 0.5;
			}
			fc += vec4(texture(InputTexture, tc).rgb, 1.0);
		}
	}

	fc = fc / (samples * 3.0);
	fc = fc - threshold;
	fc = clamp(fc, 0.0, 1000000.0);

	FragColor = vec4(c + (fc * vec4(0.8, 0.8, 1.0, 1.0)) * amount);
}
