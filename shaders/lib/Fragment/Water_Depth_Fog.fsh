vec3 WaterFog(vec3 color, vec3 viewSpacePosition0, vec3 viewSpacePosition1) {
	float waterDepth = distance(viewSpacePosition1, viewSpacePosition0) * 0.5; // Depth of the water volume
	
	if (isEyeInWater == 1) waterDepth = length(viewSpacePosition0);
	
	float fogAccum = exp(-waterDepth * 0.2); // Beer's Law
	
	vec3 waterDepthColors = vec3(0.015, 0.04, 0.098) * sunlightColor;
	
	color *= pow(vec3(0.1, 0.5, 0.8), vec3(waterDepth));
	color  = mix(waterDepthColors, color, clamp01(fogAccum));
	
	return color;
}