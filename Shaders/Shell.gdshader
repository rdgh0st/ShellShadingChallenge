shader_type spatial;
render_mode depth_prepass_alpha, cull_disabled, world_vertex_coords;

uniform float ShellIndex;
uniform float ShellCount;
uniform float ShellLength;
uniform float Density;
uniform float NoiseMin;
uniform float NoiseMax;
uniform float Thickness;
uniform float ShellDistanceAttenuation;
uniform float Curvature;
uniform float DisplacementStrength;
uniform vec3 ShellColor: source_color;
uniform float Attenuation;
uniform float OcclusionBias;
uniform float WindIntensity;
uniform float CurrentStep;
uniform float TotalTime;
global uniform vec3 ShellDirection;
global uniform vec3 WindDirection;
global uniform vec3 WindSource;
global uniform float SelfShadowMin;
global uniform float Shininess;

varying float distanceFromWind;
varying float currentStep;
varying vec3 tangentForLight;
varying vec3 vert;
varying vec3 currentVert;
varying vec3 normal;

//test

float random( vec2 p )
{
   // e^pi (Gelfond's constant)
   // 2^sqrt(2) (Gelfond–Schneider constant)
     vec2 K1 = vec2( 23.14069263277926, 2.665144142690225 );

   //return fract( cos( mod( 12345678., 256. * dot(p,K1) ) ) ); // ver1
   //return fract(cos(dot(p,K1)) * 123456.); // ver2
     return fract(cos(dot(p,K1)) * 12345.6789); // ver3
}

float hash(uint n) {
	// integer hash copied from Hugo Elias
	n = (n << 13U) ^ n;
	n = n * (n * n * 15731U + 0x789221U) + 1376312589U;
	return float(n & uint(0x7fffffffU)) / float(0x7fffffff);
}

vec3 CalculateTangent() {
	vec3 prevVert = vert;
	float NormalMovement = 0.0;
	float WindMovement = 0.0;
	for (float j = 0.0; j < ShellIndex - 1.0; j++) {
		float theta = ((ShellIndex - 1.0) / ShellCount) * (PI / 2.0) * (WindIntensity / distanceFromWind);
		NormalMovement += ShellLength * cos(theta);
		WindMovement += ShellLength * sin(theta);
	}
	
	if (WindDirection == vec3(0, 0, 0)) {
		float height = (ShellIndex - 1.0) / ShellCount;
		height = pow(height, ShellDistanceAttenuation);
		prevVert += normal * ShellLength * height;
		float k = pow(height, Curvature);
		prevVert += ShellDirection * k * DisplacementStrength;
	} else {
		vec3 localWindDirection = WindDirection - dot(WindDirection, normal) * normal;
		prevVert += normal * NormalMovement;
		prevVert += localWindDirection * WindMovement;
	}
	
	return currentVert - prevVert;
	
}

void vertex() {
	vert = VERTEX;
	normal = NORMAL;
	distanceFromWind = pow(distance(VERTEX, WindSource), 2);
	float NormalMovement = 0.0;
	float WindMovement = 0.0;
	for (float j = 0.0; j < ShellIndex; j++) {
		float theta = (ShellIndex / ShellCount) * (PI / 2.0) * (WindIntensity / distanceFromWind);
		NormalMovement += ShellLength * cos(theta);
		WindMovement += ShellLength * sin(theta);
	}
	// larger distance value, lower windintensity-- but little effect when value is close
	// windintensity needs to stay between -1, 1
	
	if (WindDirection == vec3(0, 0, 0)) {
		float height = ShellIndex / ShellCount;
		height = pow(height, ShellDistanceAttenuation);
		VERTEX += NORMAL * ShellLength * height;
		float k = pow(height, Curvature);
		VERTEX += ShellDirection * k * DisplacementStrength;
	} else {
		vec3 localWindDirection = WindDirection - dot(WindDirection, NORMAL) * NORMAL;
		VERTEX += NORMAL * NormalMovement;
		VERTEX += localWindDirection * WindMovement;
	}
	currentVert = VERTEX;
	tangentForLight = normalize(CalculateTangent());
}

void fragment() {
	vec2 newUV = UV * Density;
	vec2 localUV = fract(newUV) * 2.0 - 1.0;
	NORMAL = vec3(localUV.x, 1, localUV.y);
	
	float localDistFromCenter = length(localUV);
	
	uint seed = uint(newUV.x) + 100u * uint(newUV.y) + 100u * 10u;
	
	float rand = mix(NoiseMin, NoiseMax, hash(seed));
	//rand = mix(NoiseMin, NoiseMax, texture(PerlinNoise, localUV).r);
	//rand = texture(PerlinNoise, UV).r;
	float height = ShellIndex / ShellCount;
	bool outsideThickness = (localDistFromCenter) > (Thickness * (rand - height));
	if (outsideThickness && ShellIndex > 0.0) {
		discard;
	}
	
	float ambientOcc = pow(height, Attenuation);
	ambientOcc += OcclusionBias;
	ambientOcc = clamp(ambientOcc, 0.0, 1.0);
	
	ALBEDO = ShellColor * ambientOcc;
}

void light() {
	vec3 diffuseNormal = normalize(LIGHT - (dot(tangentForLight, LIGHT)) * tangentForLight);
	vec3 H = clamp(dot(diffuseNormal, LIGHT), 0.0, 1.0) * ATTENUATION * LIGHT_COLOR * 0.5 + 0.5;
	H = H * H;
    DIFFUSE_LIGHT += H;
	DIFFUSE_LIGHT *= (ShellIndex / ShellCount) * (1.0 - SelfShadowMin) + SelfShadowMin;
	
	vec3 HALF = normalize(LIGHT + VIEW);
	vec3 newNormal = normalize(HALF - (dot(tangentForLight, HALF)) * tangentForLight);
	
	SPECULAR_LIGHT = pow(max(dot(HALF, newNormal), 0), Shininess) * ATTENUATION * LIGHT_COLOR;
	SPECULAR_LIGHT *= (ShellIndex / ShellCount) * (1.0 - SelfShadowMin) + SelfShadowMin;
}
