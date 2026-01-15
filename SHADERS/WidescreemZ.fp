void main()
{
	vec2 xy = TexCoord;
	xy.x -= 0.5;
	
	xy.x *= pitch;
	
	xy.x += 0.5;
	FragColor = texture(InputTexture, xy);
}