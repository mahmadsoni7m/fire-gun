extends CharacterBody3D

const SPEED := 6.0
const SPRINT_SPEED := 9.0
const JUMP_VELOCITY := 5.2
const SENSITIVITY := 0.006
var gravity: float = 18.0
var camera_pivot: Node3D
var camera: Camera3D
var body_mesh: MeshInstance3D
var yaw := 0.0
var pitch := -0.22
var mobile_move := Vector2.ZERO
var look_delta := Vector2.ZERO
var jump_requested := false
var fire_cooldown := 0.0
var health := 100

func _ready() -> void:
    _build_character()
    _build_camera()
    add_to_group("player")

func _build_character() -> void:
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
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(0.12, 0.32, 0.75)
    body_mesh.material_override = material
    add_child(body_mesh)
    var head := MeshInstance3D.new()
    var sphere := SphereMesh.new()
    sphere.radius = 0.25
    sphere.height = 0.5
    head.mesh = sphere
    head.position = Vector3(0, 1.85, 0)
    var hm := StandardMaterial3D.new()
    hm.albedo_color = Color(0.78, 0.61, 0.45)
    head.material_override = hm
    add_child(head)
    var gun := MeshInstance3D.new()
    var gunmesh := BoxMesh.new()
    gunmesh.size = Vector3(0.16, 0.16, 0.85)
    gun.mesh = gunmesh
    gun.position = Vector3(0.42, 1.25, -0.45)
    var gm := StandardMaterial3D.new()
    gm.albedo_color = Color(0.09, 0.10, 0.11)
    gun.material_override = gm
    add_child(gun)

func _build_camera() -> void:
    camera_pivot = Node3D.new()
    camera_pivot.position = Vector3(0, 1.55, 0)
    add_child(camera_pivot)
    camera = Camera3D.new()
    camera.position = Vector3(0, 1.1, 5.5)
    camera.current = true
    camera.fov = 72
    camera_pivot.add_child(camera)
    camera_pivot.rotation.x = pitch

func _physics_process(delta: float) -> void:
    fire_cooldown = maxf(0.0, fire_cooldown - delta)
    if not is_on_floor():
        velocity.y -= gravity * delta
    if (Input.is_action_just_pressed("jump") or jump_requested) and is_on_floor():
        velocity.y = JUMP_VELOCITY
    jump_requested = false
    var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    if mobile_move.length() > 0.12:
        input_dir = mobile_move
    var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    if direction.length() > 0.01:
        velocity.x = direction.x * SPEED
        velocity.z = direction.z * SPEED
        rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), delta * 10.0)
    else:
        velocity.x = move_toward(velocity.x, 0.0, SPEED * 5.0 * delta)
        velocity.z = move_toward(velocity.z, 0.0, SPEED * 5.0 * delta)
    if look_delta.length() > 0.0:
        yaw -= look_delta.x * SENSITIVITY
        pitch = clampf(pitch - look_delta.y * SENSITIVITY, -0.75, 0.28)
        look_delta = Vector2.ZERO
        rotation.y = yaw
        camera_pivot.rotation.x = pitch
    move_and_slide()

func request_jump() -> void:
    jump_requested = true

func set_mobile_move(value: Vector2) -> void:
    mobile_move = value.limit_length(1.0)

func add_look_delta(value: Vector2) -> void:
    look_delta += value

func fire_weapon() -> void:
    if fire_cooldown > 0.0:
        return
    fire_cooldown = 0.22
    var from := camera.global_position
    var direction := -camera.global_transform.basis.z
    var query := PhysicsRayQueryParameters3D.create(from, from + direction * 65.0)
    query.exclude = [get_rid()]
    var hit := get_world_3d().direct_space_state.intersect_ray(query)
    if hit and hit.collider and hit.collider.is_in_group("enemy"):
        hit.collider.take_damage(34)
