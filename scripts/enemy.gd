extends CharacterBody3D

var health := 100
var speed := 2.0
var gravity := 18.0
var player: Node3D
var body_mesh: MeshInstance3D
var attack_timer := 0.0

func _ready() -> void:
    add_to_group("enemy")
    var col := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.42
    capsule.height = 1.8
    col.shape = capsule
    col.position.y = 0.9
    add_child(col)
    body_mesh = MeshInstance3D.new()
    var mesh := CapsuleMesh.new()
    mesh.radius = 0.42
    mesh.height = 1.8
    body_mesh.mesh = mesh
    body_mesh.position.y = 0.9
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color(0.72, 0.13, 0.10)
    body_mesh.material_override = mat
    add_child(body_mesh)
    var head := MeshInstance3D.new()
    var sm := SphereMesh.new()
    sm.radius = 0.24
    sm.height = 0.48
    head.mesh = sm
    head.position.y = 1.84
    head.material_override = mat
    add_child(head)
    player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
    attack_timer = maxf(0.0, attack_timer - delta)
    if not is_on_floor():
        velocity.y -= gravity * delta
    if is_instance_valid(player):
        var to_player: Vector3 = player.global_position - global_position
        to_player.y = 0
        if to_player.length() < 24.0 and to_player.length() > 1.8:
            var dir := to_player.normalized()
            velocity.x = dir.x * speed
            velocity.z = dir.z * speed
            rotation.y = atan2(-dir.x, -dir.z)
        else:
            velocity.x = move_toward(velocity.x, 0.0, speed * delta)
            velocity.z = move_toward(velocity.z, 0.0, speed * delta)
    move_and_slide()

func take_damage(amount: int) -> void:
    health -= amount
    if health <= 0:
        var world := get_parent()
        if world.has_method("enemy_defeated"):
            world.enemy_defeated()
        queue_free()
