extends CharacterBody3D
# psp-efootball-2026 - Player Controller - PES PH Edition
# Realistic PSP style movement

@export var team_id: int = 0 # 0=home, 1=away
@export var is_controlled: bool = false
@export var player_name: String = "Player"
@export var overall: int = 80

var speed: float = 5.0
var sprint_speed: float = 8.5
var ball: Node3D = null
var has_ball: bool = false

func _ready():
    add_to_group("players")
    if team_id == 0:
        is_controlled = true # control home for now
    ball = get_tree().get_first_node_in_group("ball")

func _physics_process(delta):
    var input_dir = Vector2.ZERO
    
    if is_controlled:
        # Human control - keyboard + joystick
        input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
    else:
        # Simple AI - follow ball if close
        if ball:
            var dist = global_position.distance_to(ball.global_position)
            if dist < 20.0:
                var dir = (ball.global_position - global_position)
                dir.y = 0
                input_dir = Vector2(dir.x, dir.z).normalized()
    
    # Move
    var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
    var current_speed = speed
    if Input.is_action_pressed("sprint") and is_controlled:
        current_speed = sprint_speed
    
    velocity.x = direction.x * current_speed
    velocity.z = direction.z * current_speed
    velocity.y -= 9.8 * delta # gravity
    
    if direction.length() > 0.1:
        look_at(global_position + direction, Vector3.UP)
    
    move_and_slide()
    
    # Actions - only for controlled player
    if is_controlled:
        if Input.is_action_just_pressed("pass"):
            pass_ball()
        if Input.is_action_just_pressed("shoot"):
            shoot()
        if Input.is_action_just_pressed("through_pass"):
            through_pass()

func pass_ball():
    if ball and global_position.distance_to(ball.global_position) < 2.0:
        var team_mate = get_closest_teammate()
        if team_mate:
            var dir = (team_mate.global_position - ball.global_position).normalized()
            ball.apply_impulse(dir * 8.0 + Vector3.UP * 0.5)

func shoot():
    if ball and global_position.distance_to(ball.global_position) < 2.0:
        var goal_dir = Vector3(50, 0, 0) if team_id == 0 else Vector3(-50, 0, 0)
        var dir = (goal_dir - ball.global_position).normalized()
        ball.apply_impulse(dir * 18.0 + Vector3.UP * 2.0)
        print(player_name + " SHOOTS!")

func through_pass():
    if ball and global_position.distance_to(ball.global_position) < 2.0:
        var forward = -transform.basis.z
        ball.apply_impulse(forward * 12.0 + Vector3.UP * 1.0)

func get_closest_teammate():
    var teammates = get_tree().get_nodes_in_group("home_team" if team_id == 0 else "away_team")
    var closest = null
    var min_dist = 100.0
    for tm in teammates:
        if tm == self: continue
        var d = global_position.distance_to(tm.global_position)
        if d < min_dist:
            min_dist = d
            closest = tm
    return closest
