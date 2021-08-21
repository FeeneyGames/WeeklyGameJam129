extends KinematicBody2D

const MOVE_SPEED = 50
const DASH_COOLDOWN = .5
const DASH_DURATION = .11
const DASH_SPEED = 10
const DASH_SPRITE_COOLDOWN = .02

var dash_timer = 0
var dash_direction = Vector2(1, 0)
var dash_sprite_scene = load("res://DashSprite.tscn")
var dash_sprite_timer = 0

onready var anim_player = $AnimationPlayer
onready var sprite = $Sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	var motion = parse_input(delta)
	move_and_slide(motion)
	char_anim(motion)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for body in $Area2D.get_overlapping_areas():
		if body.get_parent().get_name() == "Goal":
			var level_name = get_tree().get_current_scene().get_name()
			var level_num = int(level_name[5]) + 1
			get_tree().change_scene("res://level" + String(level_num) + ".tscn")
		elif body.get_parent().get_name() == "GoalExit":
			get_tree().quit()
		elif dash_timer < DASH_COOLDOWN - DASH_DURATION:
			play_anim("death")

func parse_input(delta):
	var velocity = Vector2()
	if dash_timer < DASH_COOLDOWN - DASH_DURATION:
		if Input.is_action_pressed("move_left"):
			velocity.x -= 1
		if Input.is_action_pressed("move_right"):
			velocity.x += 1
		if Input.is_action_pressed("move_up"):
			velocity.y -= 1
		if Input.is_action_pressed("move_down"):
			velocity.y += 1
		velocity = velocity.normalized()
		if Input.is_action_just_pressed("dash") and dash_timer == 0:
			dash_direction = velocity
			velocity *= DASH_SPEED
			dash_timer = DASH_COOLDOWN
	else:
		velocity = dash_direction * DASH_SPEED
	if dash_timer > 0:
		dash_timer -= delta
		dash_sprite_timer -= delta
		if dash_timer < 0:
			dash_timer = 0
	velocity *= MOVE_SPEED
	if anim_player.current_animation == "death":
		velocity *= 0
	return velocity

func char_anim(velocity):
	if velocity.x > 0:
		if velocity.y > 0:
			play_anim("walkDR")
		elif velocity.y < 0:
			play_anim("walkUR")
		else:
			play_anim("walkR")
	elif velocity.x < 0:
		if velocity.y > 0:
			play_anim("walkDL")
		elif velocity.y < 0:
			play_anim("walkUL")
		else:
			play_anim("walkL")
	elif velocity.y > 0:
		play_anim("walkD")
	elif velocity.y < 0:
		play_anim("walkU")
	else:
		play_anim("idle")
	if dash_timer > DASH_COOLDOWN - DASH_DURATION and dash_sprite_timer <= 0:
		var dash_sprite = dash_sprite_scene.instance()
		dash_sprite.set_position(self.get_position())
		get_parent().add_child(dash_sprite)
		dash_sprite_timer = DASH_SPRITE_COOLDOWN

func play_anim(anim_name):
	if anim_player.is_playing() and anim_player.current_animation == anim_name:
		return
	if anim_player.current_animation != "death":
		anim_player.play(anim_name)

func death():
	get_tree().reload_current_scene()