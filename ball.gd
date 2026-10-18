extends RigidBody3D
# psp-efootball-2026 - Ball Physics - Realistic

@export var friction: float = 0.08
var owner_player = null

func _ready():
    add_to_group("ball")
    mass = 0.45 # Real FIFA ball 410-450g
    physics_material_override = PhysicsMaterial.new()
    physics_material_override.friction = 0.6
    physics_material_override.bounce = 0.4
    contact_monitor = true
    max_contacts_reported = 4

func _physics_process(delta):
    # Ball friction - slows down naturally
    if linear_velocity.length() > 0.1:
        linear_velocity *= (1.0 - friction * delta)
    else:
        linear_velocity = Vector3.ZERO
    
    # Keep ball on ground
    if global_position.y < 0.22:
        global_position.y = 0.22
        linear_velocity.y = 0

func apply_shoot(dir: Vector3, power: float):
    apply_central_impulse(dir * power)

func _on_body_entered(body):
    if body.is_in_group("players"):
        owner_player = body
