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
@export var NoiseTexture: Texture2D;

var shells: Array;
var displacementDirection: Vector3;

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for i in ShellCount:
		#set_instance_shader_parameter("ShellIndex", 100);
		#print(get_instance_shader_parameter("ShellIndex"));
		#self.get_active_material(0)
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
		shaderMat.set_shader_parameter("PerlinNoise", NoiseTexture);
		shells[i].set_surface_override_material(0, shaderMat);
		add_child(shells[i]);
		shells[i].set_owner(self);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
	for i in ShellCount:
		#set_instance_shader_parameter("ShellIndex", 100);
		#print(get_instance_shader_parameter("ShellIndex"));
		#self.get_active_material(0)
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
