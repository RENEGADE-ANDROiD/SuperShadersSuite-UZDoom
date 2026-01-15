void main()
{
    vec3 C = vec3(0.0);
    int actualSamples = min(samples, 50);
    
    if(actualSamples <= 1)
    {
        vec3 sampleColor = texture(InputTexture, TexCoord).rgb;
        if(blendmode != 1)
        {
            float luminance = dot(sampleColor, vec3(0.299, 0.587, 0.114));
            C = mix(vec3(luminance), sampleColor, saturation);
        }
        else
        {
            C = sampleColor;
        }
        FragColor = vec4(C, 1.0);
        return;
    }
    
    float totalWeight = 0.0;
    
    for(int i = 0; i < 50; i++)
    {
        if(i >= actualSamples) break;
        
        float t = float(i) / float(actualSamples - 1);
        vec2 offset = steps * float(i);
        
        vec2 sampleCoord = clamp(TexCoord + offset, vec2(0.0), vec2(1.0));
        vec3 sampleColor = texture(InputTexture, sampleCoord).rgb;
        
        float centerDist = abs(t - 0.5) * 2.0;
        float weight = 1.0 - centerDist * centerDist;
        weight = max(weight, 0.2);
        
        switch(blendmode)
        {
            case 0:
                C += sampleColor * weight;
                totalWeight += weight;
                break;
            case 1:
                C = max(C, sampleColor);
                break;
            case 2:
                C += sampleColor;
                break;
        }
    }
    
    if(blendmode == 0)
    {
        if(totalWeight > 0.001)
        {
            C /= totalWeight;
        }
        else
        {
            C = texture(InputTexture, TexCoord).rgb;
        }
    }
    else if(blendmode == 2)
    {
        float normalizeFactor = 1.0 / float(actualSamples);
        C = C * normalizeFactor * 1.5;
        
        C = min(C, vec3(1.5));
    }
    
    if(blendmode != 1)
    {
        float luminance = dot(C, vec3(0.299, 0.587, 0.114));
        C = mix(vec3(luminance), C, saturation);
    }
    
    FragColor = vec4(C, 1.0);
}