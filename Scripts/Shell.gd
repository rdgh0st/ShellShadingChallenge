extends MeshInstance3D
@export var ShellShader: Shader;
var ShellChild = preload("res://Scenes/shell_child.tscn");

@export var ShellCount: int;
@export var ShellLength: float;
@export var DistanceAttenuation: float;
@export var Density: float;
@export var NoiseMin: float;
@export var NoiseMax: float;
@export var Thickness: float;
@export var Curvature: float;
@export var DisplacementStrength: float;
@export var Attenuation: float;
@export var OcclusionBias: float;
@export var ShellColor: Color;
@export var WindIntensity: float;
@export var WindDirection: Vector3;

var shells: Array;
var displacementDirection: Vector3;
var totalTime: float;

# Called when the node enters the scene tree for the first time.
func _ready():
	totalTime = -2;
	
	for i in ShellCount:
		# Create instance, attach copy of material, set initial parameters
		shells.append(ShellChild.instantiate());
		var shaderMat = shells[i].get_active_material(0).duplicate();
		shaderMat.set_shader_parameter("ShellCount", float(ShellCount));
		shaderMat.set_shader_parameter("ShellIndex", float(i));
		shaderMat.set_shader_parameter("ShellLength", ShellLength);
		shaderMat.set_shader_parameter("Density", Density);
		shaderMat.set_shader_parameter("Thickness", Thickness);
		shaderMat.set_shader_parameter("ShellDistanceAttenuation", DistanceAttenuation);
		shaderMat.set_shader_parameter("Curvature", Curvature);
		shaderMat.set_shader_parameter("DisplacementStrength", DisplacementStrength);
		shaderMat.set_shader_parameter("NoiseMin", NoiseMin);
		shaderMat.set_shader_parameter("NoiseMax", NoiseMax);
		shaderMat.set_shader_parameter("ShellColor", ShellColor);
		shaderMat.set_shader_parameter("Attenuation", Attenuation);
		shaderMat.set_shader_parameter("OcclusionBias", OcclusionBias);
		shells[i].set_surface_override_material(0, shaderMat);
		add_child(shells[i]);
		shells[i].set_owner(self);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	totalTime += delta;
	if (totalTime >= 3):
		totalTime = -2
	
	RenderingServer.global_shader_parameter_set("WindDirection", WindDirection);
	RenderingServer.global_shader_parameter_set("WindSource", self.position - WindDirection);
	
	# WindIntensity modeled after a function with sharp incline and gradual falloff, adding a sin wave to give it the appearance of some randomness
	WindIntensity = (2.0 / 1.67) * F((totalTime - 0.5) / 1.67) * P(10.0 * ((totalTime - 0.5) / 1.67)) + (sin(10.0 * totalTime) / 50.0);
	WindIntensity /= 1.5;
	
	# Update shader parameters
	for i in ShellCount:
		shells[i].get_active_material(0).set_shader_parameter("ShellCount", float(ShellCount));
		shells[i].get_active_material(0).set_shader_parameter("ShellIndex", float(i));
		shells[i].get_active_material(0).set_shader_parameter("ShellLength", ShellLength);
		shells[i].get_active_material(0).set_shader_parameter("Density", Density);
		shells[i].get_active_material(0).set_shader_parameter("Thickness", Thickness);
		shells[i].get_active_material(0).set_shader_parameter("ShellDistanceAttenuation", DistanceAttenuation);
		shells[i].get_active_material(0).set_shader_parameter("Curvature", Curvature);
		shells[i].get_active_material(0).set_shader_parameter("DisplacementStrength", DisplacementStrength);
		shells[i].get_active_material(0).set_shader_parameter("NoiseMin", NoiseMin);
		shells[i].get_active_material(0).set_shader_parameter("NoiseMax", NoiseMax);
		shells[i].get_active_material(0).set_shader_parameter("ShellColor", ShellColor);
		shells[i].get_active_material(0).set_shader_parameter("Attenuation", Attenuation);
		shells[i].get_active_material(0).set_shader_parameter("OcclusionBias", OcclusionBias);
		shells[i].get_active_material(0).set_shader_parameter("WindIntensity", WindIntensity);
		shells[i].get_active_material(0).set_shader_parameter("TotalTime", totalTime);

func erf(x):
	return 1.1 / (1.0 + 0.01 * exp(-3.2 * x));
func P(x):
	return 0.5 * (1.0 + erf(x / sqrt(2.0)))
func F(x):
	return (exp(-0.5 * pow(x / 0.5 , 2.0))) / (0.5 * sqrt(2.0));
