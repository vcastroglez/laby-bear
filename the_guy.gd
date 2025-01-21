extends CharacterBody2D


const SPEED = 3000.0
var mouse_position = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var directionX = Input.get_axis("ui_left", "ui_right")
	var directionY = Input.get_axis("ui_up", "ui_down")
	if directionX:
		velocity.x = directionX * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if directionY:
		velocity.y = directionY * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	if mouse_position:
		var mouse_pos = get_global_mouse_position()
		var direction = global_position.direction_to(mouse_pos)
		velocity = direction * SPEED * delta
	move_and_slide()


func _input(event):
	print(event)
	if(event is InputEventMouseMotion):
		mouse_position = event.position
		return
