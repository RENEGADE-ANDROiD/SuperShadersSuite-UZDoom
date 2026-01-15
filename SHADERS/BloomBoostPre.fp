void main()
{
	vec3 colour = texture(InputTexture, TexCoord).rgb;
	colour = pow(colour, vec3(gamma));
	colour *= contrast;
	colour += brightness;
	FragColor = vec4(colour, 1.0);
}
