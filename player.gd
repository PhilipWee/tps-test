extends RigidBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const CAMERA_CONTROLLER_ROTATION_SPEED = 3.0
const CAMERA_MOUSE_ROTATION_SPEED = 0.001
const CAMERA_X_ROT_MIN = -85
const CAMERA_X_ROT_MAX = 85
var aiming = false


onready var camera_base = $CameraBase
#onready var camera_animation = camera_base.get_node(@"Animation")
onready var camera_rot = camera_base.get_node(@"CameraRot")
onready var camera_spring_arm = camera_rot.get_node(@"SpringArm")
onready var camera_camera = camera_spring_arm.get_node(@"Camera")
onready var unit_pivot = $UnitPivot

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

	
func get_motion_amount():
	var motion_target = Vector3(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		0,
		Input.get_action_strength("move_back") - Input.get_action_strength("move_forward"))
	return motion_target.normalized()

func _integrate_forces(state):
	movementHandler(state)

	
func movementHandler(state):
#	print(transform.basis,moveDir)
	var camera_basis = camera_rot.global_transform.basis
	var camera_z = camera_basis.z
	var camera_x = camera_basis.x
	
	camera_z.y = 0
	camera_z = camera_z.normalized()
	camera_x.y = 0
	camera_x = camera_x.normalized()
	
	var localMoveDir = get_motion_amount()
	
	moveDir = camera_x * localMoveDir.x + camera_z * localMoveDir.z
	
	state.linear_velocity = moveDir * Speed
	
	if moveDir.length()>0.001:
		var finalBasis = Transform().looking_at(moveDir, Vector3.UP).basis
		unit_pivot.transform.basis = finalBasis
	
	
var moveDir = Vector3.ZERO
var Speed = 5

func _input(event):
	if event is InputEventMouseMotion:
		var camera_speed_this_frame = CAMERA_MOUSE_ROTATION_SPEED
		if aiming:
			camera_speed_this_frame *= 0.75
		rotate_camera(event.relative * camera_speed_this_frame)

var camera_x_rot = 0.0

func rotate_camera(move):
	camera_base.rotate_y(-move.x)
	# After relative transforms, camera needs to be renormalized.
	camera_base.orthonormalize()
	camera_x_rot -= move.y
	camera_x_rot = clamp(camera_x_rot, deg2rad(CAMERA_X_ROT_MIN), deg2rad(CAMERA_X_ROT_MAX))
	camera_rot.rotation.x = camera_x_rot
