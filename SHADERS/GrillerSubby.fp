void main()
{
	vec3 colour = texture(InputTexture, TexCoord).rgb;
	ivec2 screensize = textureSize(InputTexture, 0);
	
	int pixelx = int(TexCoord.x * screensize.x);
	int pixely = int(TexCoord.y * screensize.y);
	
	if (pixelx % 6 > 2 && pixely % 4 < 2)
	{
		FragColor = vec4(colour -= grilldepth, 1.0);
	}
	else if (pixelx % 6 < 3 && pixely % 4 > 1)
	{
		FragColor = vec4(colour -= grilldepth, 1.0);
	}
	else
	{
		FragColor = vec4(colour, 1.0);
	}
}