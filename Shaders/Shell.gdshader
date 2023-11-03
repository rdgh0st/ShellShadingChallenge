shader_type spatial;
render_mode depth_prepass_alpha, cull_disabled;

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
global uniform vec3 ShellDirection;

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


void vertex() {
	float height = ShellIndex / ShellCount;
	height = pow(height, ShellDistanceAttenuation);
	VERTEX += NORMAL * ShellLength * height;
	float k = pow(height, Curvature);
	VERTEX += ShellDirection * k * DisplacementStrength;
}

void fragment() {
	vec2 newUV = UV * Density;
	vec2 localUV = fract(newUV) * 2.0 - 1.0;
	
	float localDistFromCenter = length(localUV);
	
	uint seed = uint(newUV.x) + 100u * uint(newUV.y) + 100u * 10u;
	
	float rand = mix(NoiseMin, NoiseMax, hash(seed));
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
	vec3 H = clamp(dot(NORMAL, LIGHT), 0.0, 1.0) * ATTENUATION * LIGHT_COLOR * 0.5 + 0.5;
	H = H * H;
    DIFFUSE_LIGHT += H;
}
