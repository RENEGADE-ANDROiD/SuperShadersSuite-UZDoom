void main()
{
	const vec2 offset = vec2(0.25, 0.5);
	
	vec2 detail = vec2(xlevel, ylevel);
	
	vec2 scaledsize = textureSize(InputTexture, 0) * detail;
	vec2 pos = (floor(TexCoord * scaledsize) + offset) / scaledsize;
	
	FragColor = texture(InputTexture, pos);
}

//Thanks to the Low Detail Shader which is where this code comes from :)