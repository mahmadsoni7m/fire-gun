extends Control

var player_path: NodePath
var fire_callback: Callable
var jump_callback: Callable
var player: Node
var joystick_center := Vector2(112, 0)
var joystick_origin := Vector2.ZERO
var joystick_knob := Vector2.ZERO
var active_move_touch := -1
var active_look_touch := -1
var look_last := Vector2.ZERO
var move_vector := Vector2.ZERO
var fire_rect := Rect2()
var jump_rect := Rect2()
var font: Font

func _ready() -> void:
    player = get_node_or_null(player_path)
    set_process_input(true)
    queue_redraw()

func _input(event: InputEvent) -> void:
    var screen := get_viewport_rect().size
    fire_rect = Rect2(Vector2(screen.x - 126, screen.y - 128), Vector2(94, 94))
    jump_rect = Rect2(Vector2(screen.x - 236, screen.y - 100), Vector2(76, 66))
    if event is InputEventScreenTouch:
        if event.pressed:
            if fire_rect.has_point(event.position):
                if fire_callback.is_valid():
                    fire_callback.call()
                get_viewport().set_input_as_handled()
            elif jump_rect.has_point(event.position):
                if jump_callback.is_valid():
                    jump_callback.call()
                get_viewport().set_input_as_handled()
            elif event.position.x < screen.x * 0.42 and active_move_touch == -1:
                active_move_touch = event.index
                joystick_origin = event.position
                joystick_knob = event.position
                _update_move(event.position)
                queue_redraw()
            elif event.position.x >= screen.x * 0.42 and active_look_touch == -1:
                active_look_touch = event.index
                look_last = event.position
        else:
            if event.index == active_move_touch:
                active_move_touch = -1
                move_vector = Vector2.ZERO
                if is_instance_valid(player):
                    player.set_mobile_move(move_vector)
                queue_redraw()
            if event.index == active_look_touch:
                active_look_touch = -1
    elif event is InputEventScreenDrag:
        if event.index == active_move_touch:
            joystick_knob = event.position
            _update_move(event.position)
            queue_redraw()
        elif event.index == active_look_touch and is_instance_valid(player):
            player.add_look_delta(event.relative)
    elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and is_instance_valid(player):
        player.add_look_delta(event.relative)
    elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        if fire_callback.is_valid():
            fire_callback.call()

func _update_move(pos: Vector2) -> void:
    var delta := pos - joystick_origin
    move_vector = Vector2(delta.x, delta.y).limit_length(70.0) / 70.0
    if is_instance_valid(player):
        player.set_mobile_move(move_vector)

func _draw() -> void:
    var screen := get_viewport_rect().size
    var base := Vector2(112, screen.y - 112)
    var knob := base
    if active_move_touch != -1:
        base = joystick_origin
        knob = joystick_knob
    draw_circle(base, 57, Color(0.05, 0.07, 0.09, 0.35))
    draw_arc(base, 57, 0, TAU, 48, Color(1,1,1,0.55), 3.0)
    draw_circle(knob, 25, Color(0.85,0.88,0.92,0.48))
    draw_circle(Vector2(screen.x - 80, screen.y - 80), 46, Color(0.78,0.12,0.08,0.70))
    draw_arc(Vector2(screen.x - 80, screen.y - 80), 46, 0, TAU, 48, Color(1,1,1,0.8), 3.0)
    draw_string(ThemeDB.fallback_font, Vector2(screen.x - 108, screen.y - 72), "FIRE", HORIZONTAL_ALIGNMENT_CENTER, 56, 19, Color.WHITE)
    draw_circle(Vector2(screen.x - 198, screen.y - 66), 34, Color(0.12,0.35,0.75,0.68))
    draw_arc(Vector2(screen.x - 198, screen.y - 66), 34, 0, TAU, 40, Color(1,1,1,0.8), 2.0)
    draw_string(ThemeDB.fallback_font, Vector2(screen.x - 223, screen.y - 60), "JUMP", HORIZONTAL_ALIGNMENT_CENTER, 50, 13, Color.WHITE)
