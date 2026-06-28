// Soft natural vignette — edge darkening without harsh TC-style falloff.

void main()
{
	vec4 src = texture(InputTexture, TexCoord);
	vec2 uv = TexCoord * (1.0 - TexCoord.yx);
	float vig = pow(uv.x * uv.y * 12.0, sss_natural_vig_falloff);
	vig = clamp(vig, 0.0, 1.0);
	float mixAmt = (1.0 - vig) * sss_natural_vig_strength;
	FragColor = vec4(mix(src.rgb, src.rgb * (1.0 - mixAmt * 0.65), 1.0), src.a);
}
