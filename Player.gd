extends Area2D

signal hit # custom signal for colliding with enemy

# Member variables
export var speed = 400 # (pixels/sec). 'export' lets us change it in inspector
var screen_size


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector2.ZERO
	
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
		
	if velocity.length() > 0:
		# ensure velocity length is 1 (normal vector)
		velocity = velocity.normalized() * speed
		$AnimatedSprite.play()
	else:
		# '$' is shorthand for 'get_node()', at relative path to current node
		$AnimatedSprite.stop()
	
	# change position based on velocity	
	position += velocity * delta
	# clamp is used to ensure player stays on screen
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
		
	# choose animation to play
	if velocity.x != 0:
		$AnimatedSprite.animation = "walk"
		$AnimatedSprite.flip_v = false
		$AnimatedSprite.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite.animation = "up"
		$AnimatedSprite.flip_v = velocity.y > 0


func _on_Player_body_entered(body):
	hide() # player disappears after being hit
	emit_signal("hit")
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true) # disable collision after hit
	
# for resetting player when starting new game
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
