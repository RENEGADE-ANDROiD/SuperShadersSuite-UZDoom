void main()
{
	vec3 colour = texture(InputTexture, TexCoord).rgb;

	colour *= temp;
	
	FragColor = vec4(colour, 1.0);
}

//Big credit goes to Tanner Helland (great last name) for their temperature algo:
//http://www.tannerhelland.com/4435/convert-temperature-rgb-algorithm-code/