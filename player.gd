extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const CAMERA_CONTROLLER_ROTATION_SPEED = 3.0
const CAMERA_MOUSE_ROTATION_SPEED = 0.001
const CAMERA_X_ROT_MIN = -40
const CAMERA_X_ROT_MAX = 30
var aiming = false


onready var camera_base = $CameraBase
#onready var camera_animation = camera_base.get_node(@"Animation")
onready var camera_rot = camera_base.get_node(@"CameraRot")
onready var camera_spring_arm = camera_rot.get_node(@"SpringArm")
onready var camera_camera = camera_spring_arm.get_node(@"Camera")

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func get_camera_move_amount(delta):
	var camera_move = Vector2(
			Input.get_action_strength("view_right") - Input.get_action_strength("view_left"),
			Input.get_action_strength("view_up") - Input.get_action_strength("view_down"))
	var camera_speed_this_frame = delta * CAMERA_CONTROLLER_ROTATION_SPEED
	if aiming:
		camera_speed_this_frame *= 0.5
	return camera_speed_this_frame*camera_move
	
func _physics_process(delta):
	var camera_move_amount = get_camera_move_amount(delta)
	rotate_camera(camera_move_amount) #This is for controllers

func _input(event):
	if event is InputEventMouseMotion:
		var camera_speed_this_frame = CAMERA_MOUSE_ROTATION_SPEED
		if aiming:
			camera_speed_this_frame *= 0.75
		rotate_camera(event.relative * camera_speed_this_frame)

var camera_z_rot = 0.0

func rotate_camera(move):
	camera_base.rotate_z(move.x)
	# After relative transforms, camera needs to be renormalized.
	camera_base.orthonormalize()
	camera_z_rot += move.y
	camera_z_rot = clamp(camera_z_rot, deg2rad(CAMERA_X_ROT_MIN), deg2rad(CAMERA_X_ROT_MAX))
	camera_rot.rotation.y = camera_z_rot
