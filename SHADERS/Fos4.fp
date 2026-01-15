void main()
{
	vec3 colour = texture(InputTexture, TexCoord).rgb;
	ivec2 screensize = textureSize(InputTexture, 0);
	
	int pixelx = int(TexCoord.x * screensize.x);
	int pixely = int(TexCoord.y * screensize.y);
	
	if (pixelx % 3 == 2) 
	{
		colour.rb *= rgbsplit;
		colour.g = clamp(colour.g, residue, 1.0);
	}
	else if	(pixelx % 3 == 0)
	{
		colour.rg *= rgbsplit;
		colour.b = clamp(colour.b, residue, 1.0);
	}
	else 
	{
		colour.gb *= rgbsplit;
		colour.r = clamp(colour.r, residue, 1.0);
	}
	
	FragColor = vec4(colour, 1.0);
}
