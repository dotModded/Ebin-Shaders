#define iSteps 128
#define jSteps 3

cfloat     planetRadius = 6371.0e3;
cfloat atmosphereRadius = 6471.0e3;

cvec2 radiiSquared = pow(vec2(planetRadius, atmosphereRadius), vec2(2.0));

cvec3  rayleighCoeff = vec3(5.5e-6, 13.0e-6, 22.4e-6);
cfloat      mieCoeff = 21e-6;

cfloat g = 0.85;
cfloat rayleighHeight = 8.0e3;
cfloat      mieHeight = 1.2e3;

cvec2 invScatterHeight = -1.0 / vec2(rayleighHeight, mieHeight); // Optical step constant to save computations inside the loop

vec2 AtmosphereDistances(in vec3 worldPosition, in vec3 worldDirection) {
	// Returns the length of air visible to the pixel inside the atmosphere
	// Considers the planet's center as the coordinate origin, as per convention
	
	// worldPosition should probably be: vec3(0.0, planetRadius + cameraPosition.y, 0.0)
	// worldDirection is just the normalized worldSpacePosition
	
	float b  = -dot(worldPosition, worldDirection);
	float bb = b * b;
	vec2  c  = dot(worldPosition, worldPosition) - radiiSquared;
	
	vec2 delta   = sqrt(max(bb - c, 0.0)); // .x is for planet distance, .y is for atmosphere distance
	     delta.x = -delta.x; // Invert delta.x so we don't have to subtract it later
	
	if (worldPosition.y < atmosphereRadius) { // Uniform condition
		return vec2(b + (bb < c.x || b < 0.0 ? delta.y : delta.x), 0.0); // If the earth is not visible to the ray, check against the atmosphere instead
	} else {
		if (b < 0.0) return swizzle.gg;
		
		if (bb < c.x) return vec2(2.0 * delta.y, b - delta.y);
		
		return vec2(delta.y + delta.x, b - delta.y);
	}
}

float AtmosphereLength(in vec3 worldPosition, in vec3 worldDirection) { // Assumes the sample is inside the atmosphere
	float b  = -dot(worldPosition, worldDirection);
	float bb = b * b;
	vec2  c  = dot(worldPosition, worldPosition) - radiiSquared;
	
	vec2 delta = sqrt(max(bb - c, 0.0));
	
	return b + delta.y;
}

vec3 ComputeAtmosphericSky(vec3 playerSpacePosition, vec3 worldPosition, vec3 pSun, cfloat iSun) {
	vec3 worldDirection = normalize(playerSpacePosition);
	
	vec2 atmosphereDistances = AtmosphereDistances(worldPosition, worldDirection);
	
	if (atmosphereDistances.x <= 0.0) return vec3(0.0);
	
	// Calculate the step size of the primary ray
	float iStepSize = atmosphereDistances.x / float(iSteps);
	vec3  iStep     = worldDirection * iStepSize;
	
	float iCount = 0.0; // Initialize the primary ray counter
	
	vec3 rayleigh = vec3(0.0); // Initialize accumulators for Rayleigh and Mie scattering
	vec3 mie      = vec3(0.0);
	
	vec4 opticalDepth = vec4(0.0); // Initialize optical depth accumulators, .rg represents rayleigh and mie for the 'i' loop, .ba represent the same for the 'j' loop
	
	vec3 iPos = worldPosition + worldDirection * (iStepSize * 0.5 + atmosphereDistances.y); // Calculate the primary ray sample position
	
    // Sample the primary ray
	for (int i = 0; i < iSteps; i++) {
		float iHeight = length(iPos) - planetRadius; // Calculate the height of the sample
		
		vec2 opticalStep = exp(iHeight * invScatterHeight) * iStepSize; // Calculate the optical depth of the Rayleigh and Mie scattering for this step
		
		opticalDepth.rg += opticalStep; // Accumulate optical depth
		
		float jStepSize = AtmosphereLength(iPos, pSun) / float(jSteps); // Calculate the step size of the secondary ray
		
		float jCount = 0.0; // Initialize the secondary ray counter
		
		opticalDepth.ba = vec2(0.0); // Re-initialize optical depth accumulators for the 'j' loop (secondary ray)
		
		// Sample the secondary ray.
		for (int j = 0; j < jSteps; j++) {
			vec3 jPos = iPos + pSun * (jCount + jStepSize * 0.5); // Calculate the secondary ray sample position.
			
			float jHeight = length(jPos) - planetRadius; // Calculate the height of the sample
			
			opticalDepth.ba += exp(jHeight * invScatterHeight) * jStepSize; // Accumulate optical depth.
			
			jCount += jStepSize; // Increment the secondary ray counter
		}
		
		// Accumulate scattering
		
		
		vec3 attn = exp(rayleighCoeff * dot(opticalDepth.rb, swizzle.bb) + mieCoeff * dot(opticalDepth.ga, swizzle.bb));
		
		rayleigh += opticalStep.r * attn;
		mie      += opticalStep.g * attn;
		
		iPos += iStep; // Increment the primary ray
    }
	
	// Calculate the Rayleigh and Mie phases
	cfloat gg = g * g;
    float  mu = dot(worldDirection, pSun);
    float rayleighPhase = 1.5 * (1.0 + mu * mu);
    float      miePhase = rayleighPhase * (1.0 - gg) / (pow(1.0 + gg - 2.0 * mu * g, 1.5) * (2.0 + gg));
	
	show(mie * 0.001);
	
    // Calculate and return the final color
    return iSun * (rayleigh * rayleighPhase * rayleighCoeff + mie * miePhase * mieCoeff);
}