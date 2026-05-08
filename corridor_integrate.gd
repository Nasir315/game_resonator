@tool
extends Node3D

const CW = 4.0
const CH = 3.5
const RS = 7.0

@export var rebuild_map_in_editor: bool = false:
	set(value):
		rebuild_map_in_editor = false
		if Engine.is_editor_hint():
			_generate_level()

func _ready():
	if not Engine.is_editor_hint():
		_generate_level()

func _generate_level():
	for child in get_children():
		if child.name != "Player" and child.name != "Camera3D":
			child.free() 
			
	_setup_environment()
	_build_map()

func _setup_environment():
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.01, 0.01, 0.01)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.4, 0.45, 0.5)
	env.ambient_light_energy = 1.2
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.glow_enabled = true
	env.glow_intensity = 0.5
	env.glow_bloom = 0.2
	var we = WorldEnvironment.new()
	we.environment = env
	add_child(we)

# ── Materials ────────────────────────────────────────────────────────────────
func _wall_mat() -> StandardMaterial3D:
	return _mat(Color("282828"), 0.95, 0.1)

func _floor_mat() -> StandardMaterial3D:
	return _mat(Color("1a1a1a"), 0.8, 0.4)

func _ceil_mat() -> StandardMaterial3D:
	return _mat(Color("111111"), 1.0, 0.0)

func _metal_mat() -> StandardMaterial3D:
	return _mat(Color(0.35, 0.33, 0.30), 0.4, 0.85)

func _door_mat() -> StandardMaterial3D:
	return _mat(Color(0.22, 0.18, 0.14), 0.8, 0.3)

func _blood_mat() -> StandardMaterial3D:
	return _mat(Color(0.38, 0.02, 0.02), 0.9, 0.0)

func _paper_mat() -> StandardMaterial3D:
	return _mat(Color(0.75, 0.72, 0.60), 1.0, 0.0)

func _glass_mat() -> StandardMaterial3D:
	var m = StandardMaterial3D.new()
	m.albedo_color = Color(0.4, 0.7, 0.6, 0.25)
	m.roughness = 0.05
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return m

func _screen_mat() -> StandardMaterial3D:
	var m = StandardMaterial3D.new()
	m.albedo_color = Color(0.05, 0.25, 0.15)
	m.emission_enabled = true
	m.emission = Color(0.0, 0.6, 0.3)
	m.emission_energy_multiplier = 1.2
	return m

func _lift_mat() -> StandardMaterial3D:
	return _mat(Color(0.30, 0.28, 0.26), 0.3, 0.9)

func _mat(col: Color, rough: float, metal: float) -> StandardMaterial3D:
	var m = StandardMaterial3D.new()
	m.albedo_color = col
	m.roughness = rough
	m.metallic = metal
	return m

func _glow_item_mat(color: Color) -> StandardMaterial3D:
	var m = StandardMaterial3D.new()
	m.albedo_color = color
	m.emission_enabled = true
	m.emission = color
	m.emission_energy_multiplier = 4.0
	return m

# ── Map Layout ───────────────────────────────────────────────────────────────
func _build_map():
	var wm = _wall_mat()
	var fm = _floor_mat()
	var cm = _ceil_mat()

	# ── MAIN CORRIDOR ───────────────────────────────────────────────────────
	_box(Vector3(0, -0.1, -32.5), Vector3(CW, 0.2, 65.0), fm, "MainFloor")
	_box(Vector3(0, CH+0.1, -32.5), Vector3(CW, 0.2, 65.0), cm, "MainCeil")

	# RIGHT WALL 
	_box(Vector3(CW/2+0.1, CH/2, -7.125), Vector3(0.2, CH, 14.25), wm, "RWall1")
	_box(Vector3(CW/2+0.1, CH-0.4, -15.0), Vector3(0.2, 0.7, 1.5), wm, "RLintelChem")
	_box(Vector3(CW/2+0.1, CH/2, -31.875), Vector3(0.2, CH, 32.25), wm, "RWall2")
	_box(Vector3(CW/2+0.1, CH-0.4, -50.0), Vector3(0.2, 0.7, CW), wm, "RLintelSecBranch")
	_box(Vector3(CW/2+0.1, CH/2, -58.5), Vector3(0.2, CH, 13.0), wm, "RWall3")

	# LEFT WALL 
	_box(Vector3(-CW/2-0.1, CH/2, -16.5), Vector3(0.2, CH, 33.0), wm, "LWall1")
	_box(Vector3(-CW/2-0.1, CH-0.4, -35.0), Vector3(0.2, 0.7, CW), wm, "LLintelStorBranch")
	_box(Vector3(-CW/2-0.1, CH/2, -51.0), Vector3(0.2, CH, 28.0), wm, "LWall2")

	# ── STORAGE BRANCH ───────────────────────────────────────────────────────
	_box(Vector3(-8.0, -0.1, -35.0), Vector3(12.0, 0.2, CW), fm, "StorBranchFloor")
	_box(Vector3(-8.0, CH+0.1, -35.0), Vector3(12.0, 0.2, CW), cm, "StorBranchCeil")
	_box(Vector3(-8.0, CH/2, -37.1), Vector3(12.0, CH, 0.2), wm, "StorBranchWallN")
	_box(Vector3(-8.0, CH/2, -32.9), Vector3(12.0, CH, 0.2), wm, "StorBranchWallS")

	# ── SECURITY BRANCH ──────────────────────────────────────────────────────
	_box(Vector3(8.0, -0.1, -50.0), Vector3(12.0, 0.2, CW), fm, "SecBranchFloor")
	_box(Vector3(8.0, CH+0.1, -50.0), Vector3(12.0, 0.2, CW), cm, "SecBranchCeil")
	_box(Vector3(8.0, CH/2, -52.1), Vector3(12.0, CH, 0.2), wm, "SecBranchWallN")
	_box(Vector3(8.0, CH/2, -47.9), Vector3(12.0, CH, 0.2), wm, "SecBranchWallS")

	# ── RIGHT-TURN DETOUR TO MAIN LAB ────────────────────────────────────────
	_box(Vector3(0, -0.1, -65.0), Vector3(CW, 0.2, CW), fm, "Corner1Floor")
	_box(Vector3(0, CH+0.1, -65.0), Vector3(CW, 0.2, CW), cm, "Corner1Ceil")
	_box(Vector3(0, CH/2, -67.1), Vector3(CW, CH, 0.2), wm, "Corner1WallFar") 
	_box(Vector3(-2.1, CH/2, -65.0), Vector3(0.2, CH, CW), wm, "Corner1WallLeft")

	_box(Vector3(12.5, -0.1, -65.0), Vector3(21.0, 0.2, CW), fm, "HorizFloor")
	_box(Vector3(12.5, CH+0.1, -65.0), Vector3(21.0, 0.2, CW), cm, "HorizCeil")
	_box(Vector3(12.5, CH/2, -62.9), Vector3(21.0, CH, 0.2), wm, "HorizWallSouth")
	_box(Vector3(12.5, CH/2, -67.1), Vector3(21.0, CH, 0.2), wm, "HorizWallNorth")

	_box(Vector3(25.0, -0.1, -65.0), Vector3(CW, 0.2, CW), fm, "Corner2Floor")
	_box(Vector3(25.0, CH+0.1, -65.0), Vector3(CW, 0.2, CW), cm, "Corner2Ceil")
	_box(Vector3(27.1, CH/2, -65.0), Vector3(0.2, CH, CW), wm, "Corner2WallRight")
	_box(Vector3(25.0, CH/2, -62.9), Vector3(CW, CH, 0.2), wm, "Corner2WallBack") 

	_box(Vector3(25.0, -0.1, -72.0), Vector3(CW, 0.2, 10.0), fm, "VertFloor")
	_box(Vector3(25.0, CH+0.1, -72.0), Vector3(CW, 0.2, 10.0), cm, "VertCeil")
	_box(Vector3(22.9, CH/2, -72.0), Vector3(0.2, CH, 10.0), wm, "VertWallL")
	_box(Vector3(27.1, CH/2, -72.0), Vector3(0.2, CH, 10.0), wm, "VertWallR")

	# ── CORRIDOR DECORATION & LIGHTING ───────────────────────────────────────
	_decorate_z_corridor(0, -65.0, 0)
	_decorate_z_corridor(-65.0, -72.0, 25.0)
	_decorate_x_corridor(0.0, 25.0, -65.0) # Decorates the plain L-shape detour!
	
	_spot(Vector3(12.5, CH-0.3, -65.0), Color(0.85, 0.95, 1.0), 2.0, 10.0) 
	_spot(Vector3(-8.0, CH-0.3, -35.0), Color(0.6, 0.15, 0.1), 2.0, 10.0) 
	_spot(Vector3(8.0, CH-0.3, -50.0), Color(0.4, 0.6, 0.9), 2.0, 10.0) 

# ── ROOM LABELS (TEXT FIXED) ─────────────────────────────────────────────
	
	# Pulled LAB-2 slightly forward (1.88 instead of 1.98) so it escapes the concrete
	_text(Vector3(1.88, CH-0.6, -15.0), "LAB-2", -90.0)
	
	_text(Vector3(-1.98, CH-0.6, -35.0), "<- STORAGE", 90.0)
	_text(Vector3(1.98, CH-0.6, -50.0), "SECURITY ->", -90.0)
	
	# Branch end doors
	_text(Vector3(-13.98, CH-0.6, -35.0), "STORAGE", 90.0)
	_text(Vector3(13.98, CH-0.6, -50.0), "SECURITY", -90.0)
	
	# Pulled Main Lab slightly forward (-76.88 instead of -76.98)
	_text(Vector3(25.0, CH-0.6, -76.88), "MAIN LAB", 0.0)

	# ── ROOM SPAWNS ──────────────────────────────────────────────────────────
	_build_spawn_room(Vector3(0, 0, 3.5)) 
	_build_chemical_room(Vector3(CW/2 + RS/2, 0, -15.0))
	_build_storage_room(Vector3(-17.5, 0, -35.0))
	_build_security_post(Vector3(17.5, 0, -50.0))
	_build_main_lab(Vector3(25.0, 0, -77.0 - RS*0.9))

# ── Themetic Corridor Detailers ───────────────────────────────────────────────
func _decorate_z_corridor(start_z: float, end_z: float, x: float):
	var length = abs(start_z - end_z)
	var center_z = (start_z + end_z) / 2.0
	var mm = _metal_mat()
	var bm = StandardMaterial3D.new()
	bm.albedo_color = Color(0.6, 0.05, 0.05) 
	var led_mat = StandardMaterial3D.new()
	led_mat.emission_enabled = true
	led_mat.emission = Color(0.85, 0.95, 1.0) 
	led_mat.emission_energy_multiplier = 2.5
	
	for i in range(int(length / 8.0)):
		var lz = max(start_z, end_z) - (i * 8.0) - 4.0
		_box(Vector3(x, CH - 0.05, lz), Vector3(1.2, 0.1, 0.3), led_mat, "LED_Fixture")
		_spot(Vector3(x, CH - 0.2, lz), Color(0.85, 0.95, 1.0), 2.5, 12.0)

	_box(Vector3(x - CW/2 + 0.25, CH - 0.25, center_z), Vector3(0.15, 0.15, length), mm, "PipeL")
	_box(Vector3(x + CW/2 - 0.25, CH - 0.25, center_z), Vector3(0.15, 0.15, length), mm, "PipeR")

	for i in range(int(length / 12.0)):
		var pz = max(start_z, end_z) - (i * 12.0) - 6.0
		_box(Vector3(x - CW/2 + 0.1, 1.5, pz), Vector3(0.2, 1.0, 0.8), mm, "Panel")
		_box(Vector3(x + CW/2 - 0.1, 1.2, pz - 2.0), Vector3(0.2, 0.6, 0.3), bm, "Extinguisher")

func _decorate_x_corridor(start_x: float, end_x: float, z: float):
	var length = abs(start_x - end_x)
	var center_x = (start_x + end_x) / 2.0
	var mm = _metal_mat()
	var led_mat = StandardMaterial3D.new()
	led_mat.emission_enabled = true
	led_mat.emission = Color(0.85, 0.95, 1.0) 
	led_mat.emission_energy_multiplier = 2.5
	
	for i in range(int(length / 8.0)):
		var lx = min(start_x, end_x) + (i * 8.0) + 4.0
		_box(Vector3(lx, CH - 0.05, z), Vector3(0.3, 0.1, 1.2), led_mat, "LED_Fixture_X")
		_spot(Vector3(lx, CH - 0.2, z), Color(0.85, 0.95, 1.0), 2.5, 12.0)

	_box(Vector3(center_x, CH - 0.25, z - CW/2 + 0.25), Vector3(length, 0.15, 0.15), mm, "PipeN")
	_box(Vector3(center_x, CH - 0.25, z + CW/2 - 0.25), Vector3(length, 0.15, 0.15), mm, "PipeS")
	
	for i in range(int(length / 12.0)):
		var px = min(start_x, end_x) + (i * 12.0) + 6.0
		_box(Vector3(px, 1.5, z - CW/2 + 0.1), Vector3(0.8, 1.0, 0.2), mm, "PanelX")

# ── Rooms (Fully Sealed Enclosures) ──────────────────────────────────────────
func _build_chemical_room(center: Vector3):
	var wm = _wall_mat()
	var fm = _floor_mat()
	var cm = _ceil_mat()
	var mm = _metal_mat()
	var pm = _paper_mat()
	var x = center.x
	var z = center.z

	_box(Vector3(x, -0.1, z), Vector3(RS, 0.2, RS), fm, "ChemFloor")
	_box(Vector3(x, CH+0.1, z), Vector3(RS, 0.2, RS), cm, "ChemCeil")
	
	# Fixed Walls - Perfectly seals the 7x7 room while leaving a 1.5 door gap on the Left
	_box(Vector3(x+RS/2, CH/2, z), Vector3(0.2, CH, RS), wm, "ChemWallR")       
	_box(Vector3(x, CH/2, z-RS/2), Vector3(RS, CH, 0.2), wm, "ChemWallFront")   
	_box(Vector3(x, CH/2, z+RS/2), Vector3(RS, CH, 0.2), wm, "ChemWallBack")  
	_box(Vector3(x-RS/2, CH/2, z-2.125), Vector3(0.2, CH, 2.75), wm, "ChemWallL1")
	_box(Vector3(x-RS/2, CH/2, z+2.125), Vector3(0.2, CH, 2.75), wm, "ChemWallL2")
	_box(Vector3(x-RS/2, CH-0.4, z), Vector3(0.2, 0.7, 1.5), wm, "ChemLintel")

	_omni(Vector3(x, CH-0.4, z), Color(0.6, 0.85, 0.65), 2.5, 8.0)

	for shelf in range(3):
		_box(Vector3(x+RS/2-0.3, 0.5+shelf*0.75, z), Vector3(0.25, 0.07, RS-0.5), mm, "CShelf"+str(shelf))
		for v in range(5):
			var vcol = Color(randf_range(0.2,0.9), randf_range(0.2,0.9), randf_range(0.3,1.0), 0.7)
			var vm = StandardMaterial3D.new()
			vm.albedo_color = vcol
			vm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			vm.emission_enabled = true
			vm.emission = vcol * 0.5
			vm.emission_energy_multiplier = 0.8
			_box(Vector3(x+RS/2-0.5, 0.65+shelf*0.75, z-1.5+v*0.7), Vector3(0.1, 0.24, 0.1), vm, "CVial"+str(shelf)+str(v))

	_box(Vector3(x, 0.47, z+RS/2-1.5), Vector3(RS-0.8, 0.08, 1.4), mm, "CTable")
	_box(Vector3(x-1.0, 0.55, z+RS/2-1.2), Vector3(0.18, 0.12, 0.18), mm, "CMicBase")
	_box(Vector3(x-1.0, 0.78, z+RS/2-1.2), Vector3(0.06, 0.38, 0.06), mm, "CMicArm")
	_box(Vector3(x-1.0, 0.96, z+RS/2-1.2), Vector3(0.18, 0.06, 0.14), mm, "CMicHead")
	_box(Vector3(x+0.5, 0.52, z+RS/2-1.4), Vector3(0.5, 0.015, 0.35), pm, "CPapers")

	var toxic_mat = _glow_item_mat(Color(0.2, 0.9, 0.1))
	toxic_mat.emission_energy_multiplier = 1.0
	_box(Vector3(x-1.5, 0.01, z-1.5), Vector3(1.8, 0.02, 1.2), toxic_mat, "ToxicSpill")
	var barrel = _box(Vector3(x-1.2, 0.3, z-1.6), Vector3(0.6, 0.8, 0.6), mm, "Barrel")
	barrel.get_parent().rotation_degrees.z = 90.0

	# Whiteboard moved to the back wall so it no longer blocks the entrance!
	_box(Vector3(x, CH/2, z+RS/2-0.1), Vector3(2.4, 1.2, 0.1), pm, "Whiteboard")
	
	_box(Vector3(x+RS/2-0.05, 0.6, z+2.0), Vector3(0.1, 0.8, 1.0), mm, "VentGrate")
	_box(Vector3(x-RS/2+0.8, 0.45, z+RS/2-0.5), Vector3(1.6, 0.1, 1.0), mm, "SinkCounter")
	_box(Vector3(x-RS/2+0.8, 0.5, z+RS/2-0.5), Vector3(1.2, 0.05, 0.6), fm, "SinkBasin")

	_box(Vector3(x+1.5, 0.65, z+RS/2-1.5), Vector3(0.22, 0.22, 0.22), _glow_item_mat(Color(0.2, 0.8, 1.0)), "MaskItem1")
	_omni(Vector3(x+1.5, 0.9, z+RS/2-1.5), Color(0.2, 0.8, 1.0), 1.5, 4.0)

func _build_storage_room(center: Vector3):
	var wm = _wall_mat()
	var fm = _floor_mat()
	var cm = _ceil_mat()
	var mm = _metal_mat()
	var bm = _blood_mat()
	var x = center.x
	var z = center.z

	_box(Vector3(x, -0.1, z), Vector3(RS, 0.2, RS), fm, "StorFloor")
	_box(Vector3(x, CH+0.1, z), Vector3(RS, 0.2, RS), cm, "StorCeil")
	
	# Fixed Walls - Seals the gaps to prevent falling off!
	_box(Vector3(x-RS/2, CH/2, z), Vector3(0.2, CH, RS), wm, "StorWallL")
	_box(Vector3(x, CH/2, z-RS/2), Vector3(RS, CH, 0.2), wm, "StorWallFront")
	_box(Vector3(x, CH/2, z+RS/2), Vector3(RS, CH, 0.2), wm, "StorWallBack")
	_box(Vector3(x+RS/2, CH/2, z-2.125), Vector3(0.2, CH, 2.75), wm, "StorWallR1")
	_box(Vector3(x+RS/2, CH/2, z+2.125), Vector3(0.2, CH, 2.75), wm, "StorWallR2")
	_box(Vector3(x+RS/2, CH-0.4, z), Vector3(0.2, 0.7, 1.5), wm, "StorLintel")

	_omni(Vector3(x, CH-0.4, z), Color(0.4, 0.07, 0.04), 2.0, 8.0)

	for r in range(2):
		for c in range(3):
			_box(Vector3(x-RS/2+0.8+c*1.5, 0.45+r*1.0, z-1.5), Vector3(1.2, 0.9, 1.0), mm, "Crate"+str(r)+str(c))

	_box(Vector3(x, 0.4, z+1.0), Vector3(2.2, 0.8, 1.0), mm, "FallenCage")
	_box(Vector3(x, 0.01, z+0.8), Vector3(2.0, 0.02, 1.4), bm, "SpecBlood1")
	_box(Vector3(x+0.5, 0.01, z+2.0), Vector3(0.5, 0.02, 0.4), bm, "SpecBlood2")
	_box(Vector3(x, 0.01, z+1.8), Vector3(0.3, 0.015, 1.2), bm, "DragMark")

	for sc in range(4):
		_box(Vector3(x-RS/2+0.1, 0.6+sc*0.35, z-1.0+sc*0.5), Vector3(0.03, 0.28, 0.04), bm, "Scratch"+str(sc))

	_box(Vector3(x-RS/2+0.8, 0.98, z-1.5), Vector3(0.22, 0.22, 0.22), _glow_item_mat(Color(0.2, 0.8, 1.0)), "MaskItem3")
	_omni(Vector3(x-RS/2+0.8, 1.2, z-1.5), Color(0.2, 0.8, 1.0), 1.5, 4.0)

func _build_security_post(center: Vector3):
	var wm = _wall_mat()
	var fm = _floor_mat()
	var cm = _ceil_mat()
	var mm = _metal_mat()
	var bm = _blood_mat()
	var sm = _screen_mat()
	var x = center.x
	var z = center.z

	_box(Vector3(x, -0.1, z), Vector3(RS, 0.2, RS), fm, "SecFloor")
	_box(Vector3(x, CH+0.1, z), Vector3(RS, 0.2, RS), cm, "SecCeil")
	
	# Fixed Walls - Seals the gaps to prevent falling off!
	_box(Vector3(x+RS/2, CH/2, z), Vector3(0.2, CH, RS), wm, "SecWallR")
	_box(Vector3(x, CH/2, z-RS/2), Vector3(RS, CH, 0.2), wm, "SecWallFront")
	_box(Vector3(x, CH/2, z+RS/2), Vector3(RS, CH, 0.2), wm, "SecWallBack")
	_box(Vector3(x-RS/2, CH/2, z-2.125), Vector3(0.2, CH, 2.75), wm, "SecWallL1")
	_box(Vector3(x-RS/2, CH/2, z+2.125), Vector3(0.2, CH, 2.75), wm, "SecWallL2")
	_box(Vector3(x-RS/2, CH-0.4, z), Vector3(0.2, 0.7, 1.5), wm, "SecLintel")

	_omni(Vector3(x, CH-0.4, z), Color(0.4, 0.6, 0.9), 2.0, 8.0)

	_box(Vector3(x+1.0, 0.5, z-1.5), Vector3(3.0, 0.1, 1.2), mm, "SecDesk")
	for m in range(3):
		var screen = _box(Vector3(x+0.5+m*1.0, 1.1, z-1.8), Vector3(0.8, 0.6, 0.05), sm, "CamScreen"+str(m))
		screen.get_parent().rotation_degrees.x = 15.0

	_box(Vector3(x+1.5, 0.2, z+1.0), Vector3(1.2, 0.4, 0.6), _metal_mat(), "GuardBody")
	_box(Vector3(x+1.5, 0.01, z+1.0), Vector3(2.0, 0.02, 1.5), bm, "GuardBlood")
	_box(Vector3(x+0.8, 0.01, z+0.5), Vector3(0.5, 0.02, 1.0), bm, "GuardBloodTrail")

	_box(Vector3(x+0.5, 0.55, z-1.2), Vector3(0.2, 0.05, 0.3), _glow_item_mat(Color(0.8, 1.0, 0.2)), "Keycard")
	_omni(Vector3(x+0.5, 0.8, z-1.2), Color(0.8, 1.0, 0.2), 1.0, 3.0)

func _build_spawn_room(center: Vector3):
	var wm = _wall_mat()
	var fm = _floor_mat()
	var cm = _ceil_mat()
	var x = center.x
	var z = center.z

	_box(Vector3(x, -0.1, z), Vector3(RS, 0.2, RS), fm, "SpawnFloor")
	_box(Vector3(x, CH+0.1, z), Vector3(RS, 0.2, RS), cm, "SpawnCeil")
	_box(Vector3(x-RS/2, CH/2, z), Vector3(0.2, CH, RS), wm, "SpawnWallL")
	_box(Vector3(x+RS/2, CH/2, z), Vector3(0.2, CH, RS), wm, "SpawnWallR")
	_box(Vector3(x, CH/2, z+RS/2), Vector3(RS, CH, 0.2), wm, "SpawnWallBack")
	
	_box(Vector3(x-2.0, CH/2, z-RS/2), Vector3(RS/2-1.0, CH, 0.2), wm, "SpawnFrontL")
	_box(Vector3(x+2.0, CH/2, z-RS/2), Vector3(RS/2-1.0, CH, 0.2), wm, "SpawnFrontR")
	_box(Vector3(x, CH-0.4, z-RS/2), Vector3(4.0, 0.7, 0.2), wm, "SpawnLintel")

	_omni(Vector3(x, CH-0.4, z), Color(0.8, 0.8, 0.8), 1.5, 8.0)

func _build_main_lab(center: Vector3):
	var wm = _wall_mat()
	var fm = _floor_mat()
	var cm = _ceil_mat()
	var mm = _metal_mat()
	var bm = _blood_mat()
	var gm = _glass_mat()
	var sm = _screen_mat()
	var lm = _lift_mat()
	var mls = RS * 1.8
	var x = center.x
	var z = center.z

	_box(Vector3(x, -0.1, z), Vector3(mls, 0.2, mls), fm, "MLFloor")
	_box(Vector3(x, CH+0.1, z), Vector3(mls, 0.2, mls), cm, "MLCeil")
	_box(Vector3(x, CH/2, z-mls/2), Vector3(mls, CH, 0.2), wm, "MLWallFar")     
	_box(Vector3(x-mls/2, CH/2, z), Vector3(0.2, CH, mls), wm, "MLWallL")       
	_box(Vector3(x+mls/2, CH/2, z), Vector3(0.2, CH, mls), wm, "MLWallR")       

	var half_w = (mls - CW) / 2.0
	_box(Vector3(x-mls/4-CW/4, CH/2, z+mls/2), Vector3(half_w, CH, 0.2), wm, "MLBackA")
	_box(Vector3(x+mls/4+CW/4, CH/2, z+mls/2), Vector3(half_w, CH, 0.2), wm, "MLBackB")
	_box(Vector3(x, CH-0.4, z+mls/2), Vector3(CW+0.2, 0.7, 0.2), wm, "MLLintel")

	_omni(Vector3(x, CH-0.4, z), Color(0.3, 0.05, 0.02), 4.0, 15.0)
	_omni(Vector3(x+mls/2-2.0, 1.3, z-2.0), Color(0.2, 0.8, 0.4), 2.5, 5.0) 

	_box(Vector3(x, 0.5, z), Vector3(3.8, 0.1, 1.9), mm, "MLTable")
	for lp in [Vector3(-1.6,0.25,-0.75), Vector3(1.6,0.25,-0.75), Vector3(-1.6,0.25,0.75), Vector3(1.6,0.25,0.75)]:
		_box(Vector3(x+lp.x, lp.y, z+lp.z), Vector3(0.1, 0.5, 0.1), mm, "MLLeg"+str(lp))

	_box(Vector3(x, CH-0.2, z), Vector3(1.4, 0.12, 0.55), mm, "SurgRig")
	var sl = StandardMaterial3D.new()
	sl.albedo_color = Color(1.0, 0.98, 0.9)
	sl.emission_enabled = true
	sl.emission = Color(1.0, 0.95, 0.8)
	sl.emission_energy_multiplier = 2.0
	_box(Vector3(x, CH-0.35, z), Vector3(1.1, 0.08, 0.4), sl, "SurgBulb")
	
	var surg_light = SpotLight3D.new()
	surg_light.position = Vector3(x, CH-0.5, z)
	surg_light.rotation_degrees.x = -90
	surg_light.light_color = Color(0.9, 0.95, 1.0)
	surg_light.light_energy = 8.0
	surg_light.spot_range = 8.0
	surg_light.spot_angle = 35.0
	surg_light.shadow_enabled = true
	add_child(surg_light)

	for m in range(4):
		_box(Vector3(x-mls/2+0.08, 1.8, z-mls/2+1.5+m*1.6), Vector3(0.08, 0.95, 1.4), sm, "MLScr"+str(m))

	_box(Vector3(x+mls/2-2.0, 1.3, z-2.0), Vector3(1.0, 2.6, 1.0), gm, "MLTank")
	_box(Vector3(x+mls/2-2.0, 0.1, z-2.0), Vector3(1.1, 0.2, 1.1), mm, "MLTankBase")
	_box(Vector3(x+mls/2-2.0, 2.7, z-2.0), Vector3(1.1, 0.2, 1.1), mm, "MLTankTop")

	_box(Vector3(x+1.0, 0.01, z+1.4), Vector3(1.8, 0.02, 0.8), bm, "MLBlood1")
	_box(Vector3(x-2.0, 0.01, z-1.0), Vector3(0.7, 0.02, 1.1), bm, "MLBlood2")
	_box(Vector3(x, 0.01, z+mls/2-1.0), Vector3(0.4, 0.015, 1.5), bm, "MLDrag")
	_box(Vector3(x+2.5, 0.3, z+2.0), Vector3(1.1, 0.6, 0.75), mm, "MLCart")

	var lz = z - mls/2 + 1.5
	_box(Vector3(x-1.5, CH/2, lz), Vector3(0.15, CH, 2.2), lm, "LiftWL")
	_box(Vector3(x+1.5, CH/2, lz), Vector3(0.15, CH, 2.2), lm, "LiftWR")
	_box(Vector3(x, CH/2, lz-1.0), Vector3(3.0, CH, 0.15), lm, "LiftBack")
	_box(Vector3(x, -0.05, lz), Vector3(3.0, 0.1, 2.2), lm, "LiftFloor")
	_box(Vector3(x, CH+0.05, lz), Vector3(3.0, 0.1, 2.2), lm, "LiftCeil2")
	
	_box(Vector3(x-0.75, CH/2, lz+1.0), Vector3(1.3, CH, 0.12), lm, "LiftDoorL")
	_box(Vector3(x+0.75, CH/2, lz+1.0), Vector3(1.3, CH, 0.12), lm, "LiftDoorR")
	
	var btn = StandardMaterial3D.new()
	btn.albedo_color = Color(0.8, 0.6, 0.1)
	btn.emission_enabled = true
	btn.emission = Color(1.0, 0.7, 0.0)
	btn.emission_energy_multiplier = 2.0
	_box(Vector3(x+1.35, 1.0, lz+0.8), Vector3(0.06, 0.4, 0.2), mm, "LiftPanel")
	_box(Vector3(x+1.32, 1.0, lz+0.8), Vector3(0.04, 0.08, 0.08), btn, "LiftBtn")
	_omni(Vector3(x+1.35, 1.1, lz+0.8), Color(1.0, 0.7, 0.0), 0.8, 2.0)
	_omni(Vector3(x, CH-0.25, lz+1.0), Color(0.1, 0.8, 0.3), 1.0, 2.0)

# ── Helpers ──────────────────────────────────────────────────────────────────
func _box(pos: Vector3, size: Vector3, mat: StandardMaterial3D, id: String) -> MeshInstance3D:
	var body = StaticBody3D.new()
	body.name = id if id != "" else "box"
	body.position = pos
	var mi = MeshInstance3D.new()
	var bm = BoxMesh.new()
	bm.size = size
	mi.mesh = bm
	mi.material_override = mat
	var col = CollisionShape3D.new()
	var bs = BoxShape3D.new()
	bs.size = size
	col.shape = bs
	body.add_child(mi)
	body.add_child(col)
	add_child(body)
	return mi

func _omni(pos: Vector3, color: Color, energy: float, r: float):
	var l = OmniLight3D.new()
	l.position = pos
	l.light_color = color
	l.light_energy = energy
	l.omni_range = r
	l.shadow_enabled = true
	l.light_bake_mode = Light3D.BAKE_DISABLED
	add_child(l)
	return l

func _spot(pos: Vector3, color: Color, energy: float, r: float):
	var l = SpotLight3D.new()
	l.position = pos
	l.rotation_degrees.x = -90
	l.light_color = color
	l.light_energy = energy
	l.spot_range = r
	l.spot_angle = 45.0
	l.shadow_enabled = true
	l.light_bake_mode = Light3D.BAKE_DISABLED
	add_child(l)
	return l

func _text(pos: Vector3, text: String, rot_y: float):
	var lbl = Label3D.new()
	lbl.text = text
	lbl.position = pos
	lbl.rotation_degrees.y = rot_y
	lbl.pixel_size = 0.003  # Shrunk it down slightly so it fits nicely
	lbl.modulate = Color(0.7, 0.1, 0.1)
	lbl.outline_size = 0    # No outline, makes it look flat against the wall
	lbl.shaded = true       # Makes the text react to the dark lighting perfectly!
	lbl.font_size = 100
	add_child(lbl)
