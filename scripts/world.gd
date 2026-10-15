extends Node3D

const PLAYER_SCRIPT = preload("res://scripts/player.gd")
const ENEMY_SCRIPT = preload("res://scripts/enemy.gd")
var player: CharacterBody3D
var hud: CanvasLayer
var enemies_left := 0
var status_label: Label

func _ready() -> void:
    _make_environment()
    _make_ground()
    _make_world_props()
    _spawn_player()
    _spawn_enemies()
    _make_hud()

func _make_environment() -> void:
    var env := WorldEnvironment.new()
    var e := Environment.new()
    e.background_mode = Environment.BG_SKY
    e.sky = Sky.new()
    e.sky.sky_material = ProceduralSkyMaterial.new()
    e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    e.ambient_light_color = Color(0.72, 0.78, 0.88)
    e.ambient_light_energy = 0.7
    e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    env.environment = e
    add_child(env)
    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48, -25, 0)
    sun.light_energy = 1.25
    sun.shadow_enabled = true
    add_child(sun)

func _mat(color: Color, roughness := 0.9) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = roughness
    return m

func _box(parent: Node3D, pos: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
    var mesh := MeshInstance3D.new()
    var shape := BoxMesh.new()
    shape.size = size
    mesh.mesh = shape
    mesh.position = pos
    mesh.material_override = _mat(color)
    parent.add_child(mesh)
    return mesh

func _make_ground() -> void:
    var body := StaticBody3D.new()
    body.name = "Ground"
    add_child(body)
    var mesh := MeshInstance3D.new()
    var plane := PlaneMesh.new()
    plane.size = Vector2(180, 180)
    mesh.mesh = plane
    mesh.material_override = _mat(Color(0.24, 0.39, 0.21))
    mesh.rotation.x = 0
    body.add_child(mesh)
    var col := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = Vector3(180, 1, 180)
    col.shape = shape
    col.position.y = -0.5
    body.add_child(col)

func _make_world_props() -> void:
    # A central dirt road and small buildings make a readable first prototype.
    _box(self, Vector3(0, 0.015, -18), Vector3(8, 0.03, 95), Color(0.42, 0.35, 0.25))
    _box(self, Vector3(-12, 0.02, -15), Vector3(12, 0.04, 3), Color(0.47, 0.39, 0.28))
    _box(self, Vector3(13, 0.02, 2), Vector3(10, 0.04, 3), Color(0.47, 0.39, 0.28))
    var rng := RandomNumberGenerator.new()
    rng.seed = 91472
    for i in range(12):
        var x := rng.randf_range(-32, 32)
        var z := rng.randf_range(-42, 35)
        if abs(x) < 8 and z < 20:
            x += 13
        var w := rng.randf_range(4.0, 7.0)
        var d := rng.randf_range(4.0, 7.0)
        var h := rng.randf_range(2.7, 4.3)
        var building := StaticBody3D.new()
        building.name = "Building_%02d" % i
        building.position = Vector3(x, h / 2.0, z)
        add_child(building)
        _box(building, Vector3.ZERO, Vector3(w, h, d), [Color(0.64,0.54,0.4), Color(0.52,0.56,0.57), Color(0.66,0.62,0.49)][i % 3])
        var cs := CollisionShape3D.new()
        var bs := BoxShape3D.new()
        bs.size = Vector3(w, h, d)
        cs.shape = bs
        building.add_child(cs)
        _box(building, Vector3(0, h/2.0 + 0.18, 0), Vector3(w+0.4, 0.35, d+0.4), Color(0.25,0.21,0.19))
    for i in range(50):
        var x := rng.randf_range(-75, 75)
        var z := rng.randf_range(-75, 75)
        if abs(x) < 10 and z < 35:
            continue
        _make_tree(Vector3(x, 0, z), rng.randf_range(0.75, 1.25))

func _make_tree(pos: Vector3, scale_factor: float) -> void:
    var trunk := MeshInstance3D.new()
    var cyl := CylinderMesh.new()
    cyl.top_radius = 0.18 * scale_factor
    cyl.bottom_radius = 0.28 * scale_factor
    cyl.height = 2.1 * scale_factor
    trunk.mesh = cyl
    trunk.position = pos + Vector3(0, 1.05 * scale_factor, 0)
    trunk.material_override = _mat(Color(0.30, 0.19, 0.10))
    add_child(trunk)
    var crown := MeshInstance3D.new()
    var cone := SphereMesh.new()
    cone.radius = 1.05 * scale_factor
    cone.height = 2.2 * scale_factor
    crown.mesh = cone
    crown.position = pos + Vector3(0, 2.45 * scale_factor, 0)
    crown.material_override = _mat(Color(0.13, 0.31, 0.15))
    add_child(crown)

func _spawn_player() -> void:
    player = CharacterBody3D.new()
    player.name = "Player"
    player.set_script(PLAYER_SCRIPT)
    player.position = Vector3(0, 1.2, 8)
    add_child(player)

func _spawn_enemies() -> void:
    var points := [Vector3(-7,1, -10), Vector3(8,1,-22), Vector3(18,1,8), Vector3(-20,1,12), Vector3(4,1,-38), Vector3(28,1,-15)]
    for i in range(points.size()):
        var enemy := CharacterBody3D.new()
        enemy.name = "Enemy_%02d" % i
        enemy.set_script(ENEMY_SCRIPT)
        enemy.position = points[i]
        add_child(enemy)
    enemies_left = points.size()

func _make_hud() -> void:
    hud = CanvasLayer.new()
    hud.name = "MobileHUD"
    add_child(hud)
    var root := Control.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.mouse_filter = Control.MOUSE_FILTER_IGNORE
    hud.add_child(root)
    status_label = Label.new()
    status_label.position = Vector2(22, 18)
    status_label.add_theme_font_size_override("font_size", 24)
    status_label.add_theme_color_override("font_color", Color.WHITE)
    status_label.text = "SONI: OPEN WORLD  |  Душманон: %d" % enemies_left
    root.add_child(status_label)
    var help := Label.new()
    help.anchor_left = 0.0
    help.anchor_top = 1.0
    help.anchor_bottom = 1.0
    help.offset_left = 22
    help.offset_top = -48
    help.offset_bottom = -14
    help.text = "Чап: ҳаракат  •  Рост: камера  •  FIRE: тир  •  JUMP: ҷаҳидан"
    help.add_theme_color_override("font_color", Color.WHITE)
    help.add_theme_font_size_override("font_size", 16)
    root.add_child(help)
    var touch := Control.new()
    touch.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    touch.mouse_filter = Control.MOUSE_FILTER_STOP
    touch.set_script(preload("res://scripts/touch_hud.gd"))
    root.add_child(touch)
    touch.player_path = NodePath("../../../Player")
    touch.fire_callback = Callable(self, "_fire_from_hud")
    touch.jump_callback = Callable(player, "request_jump")

func _fire_from_hud() -> void:
    if is_instance_valid(player):
        player.fire_weapon()

func enemy_defeated() -> void:
    enemies_left = max(0, enemies_left - 1)
    if is_instance_valid(status_label):
        status_label.text = "SONI: OPEN WORLD  |  Душманон: %d" % enemies_left
        if enemies_left == 0:
            status_label.text = "ҒАЛАБА! Ҳамаи душманон мағлуб шуданд."
