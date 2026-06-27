extends CharacterBody2D

# ---------------- NODES ----------------
@onready var PlayerSprite: AnimatedSprite2D = $PlayerSprite
@onready var PlayerFootsteps: AudioStreamPlayer2D = $AudioStreamer/Footsteps


# ---------------- MOVEMENT ----------------
@export var acceleration := 12.0
@export var sprintSpeed := 150.0
@export var walkSpeed := 75.0

var input := Vector2.ZERO
var isMoving := false
var isSprinting := false
var baseSpeed := 0.0


# ---------------- STAMINA ----------------
@export var maxStamina := 1000.0
@export var depletionRate := 100.0
@export var recoveryRate := 35.5

var stamina := 0.0
var staminaCooldown := false
var staminaTimer := 3.0


func _ready() -> void:
	stamina = maxStamina


func _process(delta: float) -> void:
	_handle_movement(delta)
	_handle_animation()


# ---------------- INPUT ----------------
func _get_input() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	).normalized()


# ---------------- MOVEMENT (FIXED) ----------------
func _handle_movement(delta: float) -> void:
	input = _get_input()
	isMoving = input != Vector2.ZERO

	# Sprint condition
	if Input.is_action_pressed("sprint") and stamina > 0 and isMoving and !staminaCooldown:
		isSprinting = true
	else:
		isSprinting = false

	# Speed control (NO LERP BUG)
	if isSprinting:
		baseSpeed = sprintSpeed
		stamina -= depletionRate * delta
		stamina = clamp(stamina, 0, maxStamina)

		if stamina <= 0:
			staminaCooldown = true
	else:
		baseSpeed = walkSpeed

		if staminaCooldown:
			staminaTimer -= delta
			if staminaTimer <= 0:
				staminaCooldown = false
				staminaTimer = 3.0
		else:
			stamina += recoveryRate * delta
			stamina = clamp(stamina, 0, maxStamina)

	# ✅ REAL MOVEMENT (THIS IS THE FIX)
	var target_velocity = input * baseSpeed
	velocity = velocity.move_toward(target_velocity, acceleration)
	move_and_slide()


# ---------------- ANIMATION (CLEAN) ----------------
func _handle_animation() -> void:
	if !isMoving:
		PlayerSprite.play("idle")
		PlayerFootsteps.stop()
		PlayerSprite.speed_scale = 1.0
		return

	# Flip
	if input.x < 0:
		PlayerSprite.flip_h = true
	elif input.x > 0:
		PlayerSprite.flip_h = false

	# Sprint / Walk animations
	if isSprinting:
		PlayerSprite.play("run")
		PlayerSprite.speed_scale = 1.4
	else:
		PlayerSprite.play("walk")
		PlayerSprite.speed_scale = 1.0

	# Footsteps
	if !PlayerFootsteps.playing:
		PlayerFootsteps.play()
