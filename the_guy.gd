extends CharacterBody2D


const SPEED = 300.0
var dragging = false
var mouse_inside = false
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
	
	if dragging && mouse_inside:
		position = get_global_mouse_position()
	move_and_slide()


func _on_input_event(viewport, event, shape_idx):
	if(event is InputEventMouseButton):
		dragging = event.pressed
		return


func _on_mouse_exited():
	mouse_inside = false
	dragging = false


func _on_mouse_entered():
	mouse_inside = true
