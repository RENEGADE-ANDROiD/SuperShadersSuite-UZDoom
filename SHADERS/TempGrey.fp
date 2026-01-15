void main()
{
	vec3 colour = texture(InputTexture, TexCoord).rgb;

	float maxRGB = max(colour.r, max(colour.g, colour.b));
	float minRGB = min(colour.r, min(colour.g, colour.b));
	
	if (maxRGB == minRGB) { colour *= temp; }
	else
	{
		vec3 temp2 = temp;
		
		temp2 *= temp2;
		temp2.r *= 0.299;
		temp2.g *= 0.587;
		temp2.b *= 0.114;
		
		colour *= sqrt(temp2.r + temp2.g + temp2.b);
	}
	
	FragColor = vec4(colour, 1.0);
}

//Big credit goes to Tanner Helland (great last name) for their temperature algo:
//http://www.tannerhelland.com/4435/convert-temperature-rgb-algorithm-code/

//if (tempmode == 3)	{ colour *= 1.0 - ((1.0 - temp) * sat); }