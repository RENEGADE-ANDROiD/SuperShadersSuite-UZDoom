void main()
{
	vec2 xy = TexCoord;
	xy -= 0.5;
	
	xy.x *= 0.833333333333333;
	xy.y *= pitch;
	
	xy += 0.5;
	FragColor = texture(InputTexture, xy);
}