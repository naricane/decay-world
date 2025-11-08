extends CharacterBody2D
class_name CharacterController

const SPEED := 150.0 
const ACCELERATION := 2000.0 
const FRICTION := 1400.0

const DASH_SPEED := 650.0 
const DASH_DELAY := 0.3
const DASH_FRICTION := 2700.0
 
const JUMP_GRAVITY := 700.0 
const FALL_GRAVITY := 1000.0
const FALL_MAX_SPEED := 300 
const JUMP_VELOCITY := -320.0
const JUMP_CUTOFF := JUMP_VELOCITY / 6
const INPUT_BUFFER_TIME := 0.1
const COYOTE_TIME := 0.1

var input_buffer: Timer 
var coyote_timer: Timer 
var coyote_jump_available: bool

var dash_timer: Timer
var dashing := false

enum Direction {
	Left, Right
}

var direction := Direction.Right

func _ready() -> void:
	input_buffer = Timer.new()
	input_buffer.wait_time = INPUT_BUFFER_TIME
	input_buffer.one_shot = true
	add_child(input_buffer)

	coyote_timer = Timer.new()
	coyote_timer.wait_time = COYOTE_TIME
	coyote_timer.one_shot = true
	add_child(coyote_timer)
	coyote_timer.timeout.connect(coyote_timeout)
	
	dash_timer = Timer.new()
	dash_timer.wait_time = DASH_DELAY
	dash_timer.one_shot = true
	add_child(dash_timer)

func _physics_process(delta: float) -> void:
	if velocity.x > 0:
		direction = Direction.Right
	elif velocity.x < 0:
		direction = Direction.Left
	
	var horizontal_input := Input.get_axis("Left", "Right")
	
	if Input.is_action_just_pressed("Jump"):
		input_buffer.start()
	
	if input_buffer.time_left > 0:
		if is_on_floor() or coyote_jump_available:
			velocity.y = JUMP_VELOCITY
			coyote_jump_available = false

	if Input.is_action_just_released("Jump") and velocity.y < JUMP_CUTOFF:
		velocity.y = JUMP_CUTOFF
		
	if is_on_floor():
		coyote_jump_available = true
		coyote_timer.stop()
	else:
		if coyote_jump_available and coyote_timer.is_stopped():
			coyote_timer.start()
		
		if !dashing:
			velocity.y += get_player_gravity() * delta
		
		if velocity.y > FALL_MAX_SPEED:
			velocity.y = FALL_MAX_SPEED
	
	if Input.is_action_just_pressed("Dash") and dash_timer.is_stopped():
		dashing = true
		dash_timer.start()
		
		if direction == Direction.Left:
			velocity.x = -DASH_SPEED
		else:
			velocity.x = DASH_SPEED
			
		velocity.y = 0
	
	if abs(velocity.x) < SPEED:
		dashing = false
	
	var floor_damping := 1.0 if is_on_floor() else 0.8
	if dashing:
		velocity.x = move_toward(velocity.x, 0, DASH_FRICTION * delta)
	elif horizontal_input:
		velocity.x = move_toward(velocity.x, horizontal_input * SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, (FRICTION * delta) * floor_damping)

	move_and_slide()
	
func get_player_gravity() -> float:
	if velocity.y < 0:
		return JUMP_GRAVITY
	else:
		return FALL_GRAVITY

func coyote_timeout() -> void:
	coyote_jump_available = false
