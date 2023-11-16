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
	# IDEA: add/subract from Texture itself before sending it to shader
	
	for i in ShellCount:
		#set_instance_shader_parameter("ShellIndex", 100);
		#print(get_instance_shader_parameter("ShellIndex"));
		#self.get_active_material(0)
		var normalMovement = 0;
		var windMovement = 0;
		for j in i:
			var theta = (float(i) / float(ShellCount)) * (PI / 2) * WindIntensity;
			normalMovement += ShellLength * cos(theta);
			windMovement += ShellLength * sin(theta);
		
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
		shaderMat.set_shader_parameter("NormalMovement", normalMovement);
		shaderMat.set_shader_parameter("WindMovement", windMovement);
		shells[i].set_surface_override_material(0, shaderMat);
		add_child(shells[i]);
		shells[i].set_owner(self);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	totalTime += delta;
	if (totalTime >= 3):
		totalTime = -2
	
	var velocity = 1.0;
	var direction = Vector3(0, 0, 0);
	var opposite = Vector3(0, 0, 0);
	
	direction.x = Input.get_axis("Left", "Right");
	direction.y = Input.get_axis("Down", "Up");
	direction.z = Input.get_axis("Backward", "Forward");
	
	direction = direction.normalized();
	
	self.position += direction * velocity * delta;
	
	displacementDirection -= direction * delta * 10;
	if direction == Vector3.ZERO:
		displacementDirection.y -= 10 * delta;
	
	if displacementDirection.length() > 1:
		displacementDirection = displacementDirection.normalized();
	
	RenderingServer.global_shader_parameter_set("ShellDirection", displacementDirection);
	RenderingServer.global_shader_parameter_set("WindDirection", WindDirection);
	RenderingServer.global_shader_parameter_set("WindSource", self.position - WindDirection);
	
	#\sin^{2}\left(x\right)\ \frac{\sin\left(5x\right)}{2}+\ 0.5
	#WindIntensity = (sin(totalTime) * sin(totalTime)) * (sin(5 * totalTime) / 2) + 0.5 + (sin(25 * totalTime) / 100);
	
	
	WindIntensity = (2.0 / 1.67) * F((totalTime - 0.5) / 1.67) * P(10 * ((totalTime - 0.5) / 1.67)) + (sin(20 * totalTime) / 100.0);
	WindIntensity /= 1.5;
	
	
	for i in ShellCount:
		#set_instance_shader_parameter("ShellIndex", 100);
		#print(get_instance_shader_parameter("ShellIndex"));
		#self.get_active_material(0)
		#var normalMovement = 0;
		#var windMovement = 0;
		#for j in i:
		#	var theta = (float(i) / float(ShellCount)) * (PI / 2) * WindIntensity;
		#	normalMovement += ShellLength * cos(theta);
		#	windMovement += ShellLength * sin(theta);
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
		#shells[i].get_active_material(0).set_shader_parameter("NormalMovement", normalMovement);
		#shells[i].get_active_material(0).set_shader_parameter("WindMovement", windMovement);

func erf(x):
	return 1.1 / (1 + 0.01 * exp(-3.2 * x));
func P(x):
	return 0.5 * (1 + erf(x / sqrt(2)))
func F(x):
	return (exp(-0.5 * pow(x / 0.5 , 2))) / (0.5 * sqrt(2));
