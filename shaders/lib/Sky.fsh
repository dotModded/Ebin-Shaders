
// Start of #include "/lib/Sky.fsh"

// Prerequisites:
// 
// varying vec3 lightVector;


float CalculateSunlow(in vec4 viewSpacePosition) {
	float sunglow = max(0.0, dot(normalize(viewSpacePosition.xyz), lightVector) - 0.01);
	      sunglow = pow(sunglow, 8.0) * 5.0;
	
	return sunglow;
}


vec3 CalculateSkyGradient(in vec4 viewSpacePosition) {
	float radius = max(176.0, far * sqrt(2.0));
	const float horizonLevel = 72.0;
	
	vec3 worldPosition    = (gbufferModelViewInverse * vec4(normalize(viewSpacePosition.xyz), 0.0)).xyz;
	     worldPosition.y  = radius * worldPosition.y / length(worldPosition.xz) + cameraPosition.y - horizonLevel;    // Reproject the world vector to have a consistent horizon height
	     worldPosition.xz = normalize(worldPosition.xz) * radius;
	
	float dotUP = dot(normalize(worldPosition), vec3(0.0, 1.0, 0.0));
	
	float horizonCoeff = dotUP * 0.65;
	      horizonCoeff = abs(horizonCoeff);
	      horizonCoeff = pow(1.0 - horizonCoeff, 4.0) / 0.65 * 5.0;
	
	float sunglow = CalculateSunlow(viewSpacePosition);
	
	vec3 color  = horizonCoeff * pow(colorSkylight, vec3((10.0 - horizonCoeff) / 5.5)); // Sky desaturates as it approaches the horizon
	     color += sunglow * pow(colorSkylight, vec3(1.4));
	
	return color;
}

vec3 CalculateSunspot(in vec4 viewSpacePosition) {
	float sunspot  = max(0.0, dot(normalize(viewSpacePosition.xyz), lightVector) - 0.01);
	      sunspot  = pow(sunspot, 350.0);
	      sunspot  = pow(sunspot + 1.0, 400.0) - 1.0;
	      sunspot  = min(sunspot, 20.0);
	      sunspot += 100.0 * float(sunspot == 20.0);
	
	return sunspot * colorSunlight * colorSunlight;
}

vec3 CalculateAtmosphereScattering(in vec4 viewSpacePosition) {
	float factor = pow(length(viewSpacePosition.xyz), 1.4) * 0.00015 * ATMOSPHERIC_SCATTERING_AMOUNT;
	
	return pow(colorSkylight, vec3(3.5)) * factor;
}

void CompositeFog(inout vec3 color, in vec4 viewSpacePosition, in float fogVolume) {
	#ifndef FOG_ENABLED
	color += CalculateAtmosphereScattering(viewSpacePosition);
	#else
	float fogFactor  = CalculateFogFactor(viewSpacePosition, FOG_POWER);
	vec3  gradient   = CalculateSkyGradient(viewSpacePosition);
	vec3  sunspot    = CalculateSunspot(viewSpacePosition) * pow(fogFactor, 25);
	vec3  atmosphere = CalculateAtmosphereScattering(viewSpacePosition);
	vec4  skyComposite;
	
	skyComposite.a   = GetSkyAlpha(fogVolume, fogFactor);
	skyComposite.rgb = (gradient + sunspot + atmosphere) * SKY_BRIGHTNESS;
	
	color += atmosphere * SKY_BRIGHTNESS;
	color  = mix(color, skyComposite.rgb, skyComposite.a);
	#endif
}

vec3 CalculateSky(in vec4 viewSpacePosition) {
	viewSpacePosition.xyz = normalize(viewSpacePosition.xyz) * far;
	
	vec3 gradient   = CalculateSkyGradient(viewSpacePosition);
	vec3 sunspot    = CalculateSunspot(viewSpacePosition);
	vec3 atmosphere = CalculateAtmosphereScattering(viewSpacePosition);
	
	return (gradient + sunspot + atmosphere) * SKY_BRIGHTNESS;
}


// End of #include "/lib/Sky.fsh"