extends Node2D

export (int) var _actualAnim = 0
export (int) var run_speed = 200
export (int) var walk_speed = 100
export (int) var jump_speed = -800
export (int) var gravity = 1200

var velocity = Vector2()
var jumping = false

var actual_run_speed = 0
var actual_dir = 1
const R_DIR = 1
const L_DIR = -1 

onready var body: KinematicBody2D = $KinematicBody2D
onready var animTree: AnimationTree = $KinematicBody2D/AnimationTree
onready var animationPlayer = $KinematicBody2D/AnimationPlayer
onready var stateMachine: AnimationNodeStateMachinePlayback = animTree.get("parameters/playback")

# Animations states
#	0 -> idle
#	1 -> jump
#	2 -> rolling
#	3 -> running
#	4 -> shield_up
#	5 -> shield_front_walk 
#	6 -> walk
#	7 ->

# Called when the node enters the scene tree for the first time.
func _ready():
	stateMachine.start("idle")
	pass

func _process(delta):
	get_input()
	velocity.y += gravity * delta
	if jumping and body.is_on_floor():
		jumping = false
	velocity = body.move_and_slide(velocity, Vector2(0, -1))
	updateAnimationStateMachine()

func get_input():
	var right = Input.is_action_pressed('ui_right')
	var left = Input.is_action_pressed('ui_left')
	var jump = Input.is_action_just_pressed('ui_select')

	if Input.is_action_just_pressed('ui_right'):
		if actual_dir != R_DIR:
			actual_dir = R_DIR
			body.scale.x = -1
	
	elif Input.is_action_just_pressed('ui_left'):
		if actual_dir != L_DIR:
			actual_dir = L_DIR
			body.scale.x = -1
	
	if jump and body.is_on_floor():
		jumping = true
		velocity.y = jump_speed
	
	if right:
		if (actual_run_speed < run_speed):
			actual_run_speed += 2

	elif left:
		if (actual_run_speed > -run_speed):
			actual_run_speed -= 2
	
	if !right and !left or right and left:
		gradualStop()
	
	velocity.x = actual_run_speed

func gradualStop():
	if body.is_on_floor():
		if actual_run_speed > -4 and actual_run_speed < 4:
			actual_run_speed = 0
		elif actual_run_speed  < 0:
			actual_run_speed += 4
		elif actual_run_speed  > 0:
			actual_run_speed -= 4

func animationStateMachine():
	var animation = "idle"
	match _actualAnim:
		0:
			animation = "idle"
		1:
			animation = "jump"
		2:
			animation = "rolling"
		3:
			animation = "running"
		4:
			animation = "shield_up"
		5:
			animation = "shield_front_walk"
		6:
			animation = "walk"
		7:
			animation = "idle"
	animationPlayer.play(animation)

func updateAnimationStateMachine():
	if actual_run_speed > 1 and actual_run_speed < 100:
		stateMachine.travel("walk")
	elif actual_run_speed > 100:
		stateMachine.travel("running")

