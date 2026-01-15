void main()
{
	const vec3 grey = vec3(0.299, 0.587, 0.114);
	vec3 colour = texture(InputTexture, TexCoord).rgb;
		
	colour = vec3(dot(colour, grey)) * invsat + (colour * saturation);
	colour = pow(colour, vec3(gamma)) * contrast + brightness;
	
	FragColor = vec4(colour, 1.0);
}
//saturation algo adapted from chapter 16 of the opengl shading language