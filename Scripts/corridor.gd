@tool
extends Node3D

const CW = 4.0
const CH = 3.5
const RS = 7.0

func _ready():
	_setup_environment()
	_build_map()

func _setup_environment():
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.02, 0.02, 0.02)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.55, 0.50, 0.45)
	env.ambient_light_energy = 1.6
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.glow_enabled = true
	env.glow_intensity = 0.4
	env.glow_bloom = 0.15
	var we = WorldEnvironment.new()
	we.environment = env
	add_child(we)

# ── Materials ────────────────────────────────────────────────────────────────
func _wall_mat() -> StandardMaterial3D:
	return _mat(Color(0.18, 0.16, 0.15), 0.95, 0.0)

func _floor_mat() -> StandardMaterial3D:
	return _mat(Color(0.12, 0.11, 0.10), 1.0, 0.0)

func _ceil_mat() -> StandardMaterial3D:
	return _mat(Color(0.09, 0.08, 0.08), 1.0, 0.0)

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
# Spawn at (0,0,0) facing -Z
# Main corridor: Z=0 to Z=-45, with wall gaps for side rooms
# Chemical Room: right side at Z=-10
# Storage Room: left side at Z=-28
# Main Lab + Lift: end room at Z=-45 onward

func _build_map():
	var wm = _wall_mat()
	var fm = _floor_mat()
	var cm = _ceil_mat()

	# ── MAIN CORRIDOR: Z=0 to Z=-45 ─────────────────────────────────────────
	_box(Vector3(0, -0.1, -22.5), Vector3(CW, 0.2, 45.0), fm, "MainFloor")
	_box(Vector3(0, CH+0.1, -22.5), Vector3(CW, 0.2, 45.0), cm, "MainCeil")

	# RIGHT WALL — Tight gaps for Chemical (Z=-11.0) and Security (Z=-29.0)
	_box(Vector3(CW/2+0.1, CH/2, -5.125), Vector3(0.2, CH, 10.25), wm, "RWall1")
	_box(Vector3(CW/2+0.1, CH-0.4, -11.0), Vector3(0.2, 0.7, 1.5), wm, "RLintelChem")
	_box(Vector3(CW/2+0.1, CH/2, -20.0), Vector3(0.2, CH, 16.5), wm, "RWall2")
	_box(Vector3(CW/2+0.1, CH-0.4, -29.0), Vector3(0.2, 0.7, 1.5), wm, "RLintelSec")
	_box(Vector3(CW/2+0.1, CH/2, -37.375), Vector3(0.2, CH, 15.25), wm, "RWall3")

	# LEFT WALL — Tight gap for Storage (Z=-27.0)
	_box(Vector3(-CW/2-0.1, CH/2, -13.125), Vector3(0.2, CH, 26.25), wm, "LWall1")
	_box(Vector3(-CW/2-0.1, CH-0.4, -27.0), Vector3(0.2, 0.7, 1.5), wm, "LLintelStor")
	_box(Vector3(-CW/2-0.1, CH/2, -36.375), Vector3(0.2, CH, 17.25), wm, "LWall2")


	# ── CORRIDOR LIGHTS ──────────────────────────────────────────────────────
	_spot(Vector3(0, CH-0.3, -4.0), Color(0.85, 0.75, 0.55), 2.5, 8.0)
	_spot(Vector3(0, CH-0.3, -15.0), Color(0.85, 0.75, 0.55), 2.5, 8.0)
	_spot(Vector3(0, CH-0.3, -28.0), Color(0.6, 0.15, 0.1), 2.5, 8.0) # Red Warning
	_spot(Vector3(0, CH-0.3, -38.0), Color(0.5, 0.08, 0.04), 2.0, 7.0)

# ── ROOM LABELS (TEXT) ───────────────────────────────────────────────────
	_text(Vector3(CW/2 - 0.01, CH-0.8, -11.0), "LAB-2", -90.0)
	_text(Vector3(CW/2 - 0.01, CH-0.8, -29.0), "SECURITY", -90.0)
	_text(Vector3(-CW/2 + 0.01, CH-0.8, -27.0), "STORAGE", 90.0)
	_text(Vector3(0, CH-0.8, -42.0), "MAIN LAB", 0.0)
	
	# ── ROOM SPAWNS ──────────────────────────────────────────────────────────
	_build_spawn_room(Vector3(0, 0, 3.5)) 
	_build_chemical_room(Vector3(CW/2 + RS/2, 0, -10.0))
	_build_storage_room(Vector3(-(CW/2 + RS/2), 0, -28.0))
	_build_security_post(Vector3(CW/2 + RS/2, 0, -28.0))
	_build_main_lab(Vector3(0, 0, -45.0 - RS*0.9))
	
func _build_chemical_room(center: Vector3):
	var wm = _wall_mat()
	var fm = _floor_mat()
	var cm = _ceil_mat()
	var mm = _metal_mat()
	var pm = _paper_mat()
	var x = center.x
	var z = center.z

	# Shell
	_box(Vector3(x, -0.1, z), Vector3(RS, 0.2, RS), fm, "ChemFloor")
	_box(Vector3(x, CH+0.1, z), Vector3(RS, 0.2, RS), cm, "ChemCeil")
	_box(Vector3(x+RS/2, CH/2, z), Vector3(0.2, CH, RS), wm, "ChemWallR")       # right
	_box(Vector3(x, CH/2, z-RS/2), Vector3(RS, CH, 0.2), wm, "ChemWallFront")   # front (-Z)
	_box(Vector3(x, CH/2, z+RS/2), Vector3(RS, CH, 0.2), wm, "ChemWallBack")    # back (+Z)


	# Room light
	_omni(Vector3(x, CH-0.4, z), Color(0.6, 0.85, 0.65), 2.5, 8.0)

	# Shelves with vials
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

	# Lab bench
	_box(Vector3(x, 0.47, z+RS/2-1.5), Vector3(RS-0.8, 0.08, 1.4), mm, "CTable")
	
	# Microscope
	_box(Vector3(x-1.0, 0.55, z+RS/2-1.2), Vector3(0.18, 0.12, 0.18), mm, "CMicBase")
	_box(Vector3(x-1.0, 0.78, z+RS/2-1.2), Vector3(0.06, 0.38, 0.06), mm, "CMicArm")
	_box(Vector3(x-1.0, 0.96, z+RS/2-1.2), Vector3(0.18, 0.06, 0.14), mm, "CMicHead")
	
	# Papers
	_box(Vector3(x+0.5, 0.52, z+RS/2-1.4), Vector3(0.5, 0.015, 0.35), pm, "CPapers")

	# ─── NEW DESIGN ELEMENTS ─────────────────────────────────────────────────

	# 1. Toxic Spill & Overturned Barrel
	var toxic_mat = _glow_item_mat(Color(0.2, 0.9, 0.1))
	toxic_mat.emission_energy_multiplier = 1.0
	_box(Vector3(x-1.5, 0.01, z-1.5), Vector3(1.8, 0.02, 1.2), toxic_mat, "ToxicSpill")
	
	var barrel = _box(Vector3(x-1.2, 0.3, z-1.6), Vector3(0.6, 0.8, 0.6), mm, "Barrel")
	barrel.get_parent().rotation_degrees.z = 90.0

	# 2. Whiteboard (Frantic Notes)
	_box(Vector3(x-RS/2+0.1, CH/2, z+1.5), Vector3(0.1, 1.2, 2.4), pm, "Whiteboard")

	# 3. Ventilation Grate (Secret Path Foreshadowing)
	_box(Vector3(x+RS/2-0.05, 0.6, z+2.0), Vector3(0.1, 0.8, 1.0), mm, "VentGrate")

	# 4. Wash Station
	_box(Vector3(x-RS/2+0.8, 0.45, z+RS/2-0.5), Vector3(1.6, 0.1, 1.0), mm, "SinkCounter")
	_box(Vector3(x-RS/2+0.8, 0.5, z+RS/2-0.5), Vector3(1.2, 0.05, 0.6), fm, "SinkBasin")

	# ─── MISSION ITEMS ───────────────────────────────────────────────────────

	# Mask Item 1 (glowing)
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

	# Shell
	_box(Vector3(x, -0.1, z), Vector3(RS, 0.2, RS), fm, "StorFloor")
	_box(Vector3(x, CH+0.1, z), Vector3(RS, 0.2, RS), cm, "StorCeil")
	_box(Vector3(x-RS/2, CH/2, z), Vector3(0.2, CH, RS), wm, "StorWallL")       # left
	_box(Vector3(x, CH/2, z-RS/2), Vector3(RS, CH, 0.2), wm, "StorWallFront")   # front
	_box(Vector3(x, CH/2, z+RS/2), Vector3(RS, CH, 0.2), wm, "StorWallBack")    # back
	# Right wall = corridor wall (has gap)

	# Room light (red tint - infected zone)
	_omni(Vector3(x, CH-0.4, z), Color(0.4, 0.07, 0.04), 2.0, 8.0)

	# Crates
	for r in range(2):
		for c in range(3):
			_box(Vector3(x-RS/2+0.8+c*1.5, 0.45+r*1.0, z-1.5), Vector3(1.2, 0.9, 1.0), mm, "Crate"+str(r)+str(c))

	# Fallen cage + blood
	_box(Vector3(x, 0.4, z+1.0), Vector3(2.2, 0.8, 1.0), mm, "FallenCage")
	_box(Vector3(x, 0.01, z+0.8), Vector3(2.0, 0.02, 1.4), bm, "SpecBlood1")
	_box(Vector3(x+0.5, 0.01, z+2.0), Vector3(0.5, 0.02, 0.4), bm, "SpecBlood2")
	_box(Vector3(x, 0.01, z+1.8), Vector3(0.3, 0.015, 1.2), bm, "DragMark")

	# Claw scratches
	for sc in range(4):
		_box(Vector3(x-RS/2+0.1, 0.6+sc*0.35, z-1.0+sc*0.5), Vector3(0.03, 0.28, 0.04), bm, "Scratch"+str(sc))

	# Mask Item 3
	_box(Vector3(x-RS/2+0.8, 0.98, z-1.5), Vector3(0.22, 0.22, 0.22), _glow_item_mat(Color(0.2, 0.8, 1.0)), "MaskItem3")
	_omni(Vector3(x-RS/2+0.8, 1.2, z-1.5), Color(0.2, 0.8, 1.0), 1.5, 4.0)

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

	# Shell — open on +Z side (back) where corridor connects
	_box(Vector3(x, -0.1, z), Vector3(mls, 0.2, mls), fm, "MLFloor")
	_box(Vector3(x, CH+0.1, z), Vector3(mls, 0.2, mls), cm, "MLCeil")
	_box(Vector3(x, CH/2, z-mls/2), Vector3(mls, CH, 0.2), wm, "MLWallFar")     # far wall
	_box(Vector3(x-mls/2, CH/2, z), Vector3(0.2, CH, mls), wm, "MLWallL")       # left
	_box(Vector3(x+mls/2, CH/2, z), Vector3(0.2, CH, mls), wm, "MLWallR")       # right
	# Back wall (+Z) with doorway gap
	var half_w = (mls - CW) / 2.0
	_box(Vector3(x-mls/4-CW/4, CH/2, z+mls/2), Vector3(half_w, CH, 0.2), wm, "MLBackA")
	_box(Vector3(x+mls/4+CW/4, CH/2, z+mls/2), Vector3(half_w, CH, 0.2), wm, "MLBackB")
	_box(Vector3(x, CH-0.4, z+mls/2), Vector3(CW+0.2, 0.7, 0.2), wm, "MLLintel")

	# Bridge floor connecting corridor to lab
	_box(Vector3(x, -0.1, z+mls/2+1.0), Vector3(CW, 0.2, 2.0), fm, "BridgeFloor")

	# Lights
	_omni(Vector3(x, CH-0.4, z), Color(0.5, 0.08, 0.04), 3.0, 10.0)
	_omni(Vector3(x-3.0, CH-0.4, z+2.0), Color(0.3, 0.5, 0.25), 2.5, 8.0)

	# Central operating table
	_box(Vector3(x, 0.5, z), Vector3(3.8, 0.1, 1.9), mm, "MLTable")
	for lp in [Vector3(-1.6,0.25,-0.75), Vector3(1.6,0.25,-0.75), Vector3(-1.6,0.25,0.75), Vector3(1.6,0.25,0.75)]:
		_box(Vector3(x+lp.x, lp.y, z+lp.z), Vector3(0.1, 0.5, 0.1), mm, "MLLeg"+str(lp))

	# Overhead surgical light
	_box(Vector3(x, CH-0.2, z), Vector3(1.4, 0.12, 0.55), mm, "SurgRig")
	var sl = StandardMaterial3D.new()
	sl.albedo_color = Color(1.0, 0.98, 0.9)
	sl.emission_enabled = true
	sl.emission = Color(1.0, 0.95, 0.8)
	sl.emission_energy_multiplier = 2.0
	_box(Vector3(x, CH-0.35, z), Vector3(1.1, 0.08, 0.4), sl, "SurgBulb")
	_omni(Vector3(x, CH-0.45, z), Color(0.95, 0.9, 0.8), 4.5, 5.0)

	# Wall monitors
	for m in range(4):
		_box(Vector3(x-mls/2+0.08, 1.8, z-mls/2+1.5+m*1.6), Vector3(0.08, 0.95, 1.4), sm, "MLScr"+str(m))

	# Containment tank
	_box(Vector3(x+mls/2-2.0, 1.3, z-2.0), Vector3(1.0, 2.6, 1.0), gm, "MLTank")
	_box(Vector3(x+mls/2-2.0, 0.1, z-2.0), Vector3(1.1, 0.2, 1.1), mm, "MLTankBase")
	_box(Vector3(x+mls/2-2.0, 2.7, z-2.0), Vector3(1.1, 0.2, 1.1), mm, "MLTankTop")

	# Blood
	_box(Vector3(x+1.0, 0.01, z+1.4), Vector3(1.8, 0.02, 0.8), bm, "MLBlood1")
	_box(Vector3(x-2.0, 0.01, z-1.0), Vector3(0.7, 0.02, 1.1), bm, "MLBlood2")
	_box(Vector3(x, 0.01, z+mls/2-1.0), Vector3(0.4, 0.015, 1.5), bm, "MLDrag")
	_box(Vector3(x+2.5, 0.3, z+2.0), Vector3(1.1, 0.6, 0.75), mm, "MLCart")

	# ── LIFT ─────────────────────────────────────────────────────────────────
	var lz = z - mls/2 + 1.5
	_box(Vector3(x-1.5, CH/2, lz), Vector3(0.15, CH, 2.2), lm, "LiftWL")
	_box(Vector3(x+1.5, CH/2, lz), Vector3(0.15, CH, 2.2), lm, "LiftWR")
	_box(Vector3(x, CH/2, lz-1.0), Vector3(3.0, CH, 0.15), lm, "LiftBack")
	_box(Vector3(x, -0.05, lz), Vector3(3.0, 0.1, 2.2), lm, "LiftFloor")
	_box(Vector3(x, CH+0.05, lz), Vector3(3.0, 0.1, 2.2), lm, "LiftCeil2")
	# Doors (slightly open)
	_box(Vector3(x-0.75, CH/2, lz+1.0), Vector3(1.3, CH, 0.12), lm, "LiftDoorL")
	_box(Vector3(x+0.75, CH/2, lz+1.0), Vector3(1.3, CH, 0.12), lm, "LiftDoorR")
	# Button
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
func _build_security_post(center: Vector3):
	var wm = _wall_mat()
	var fm = _floor_mat()
	var cm = _ceil_mat()
	var mm = _metal_mat()
	var bm = _blood_mat()
	var sm = _screen_mat()
	var x = center.x
	var z = center.z

	# Shell
	_box(Vector3(x, -0.1, z), Vector3(RS, 0.2, RS), fm, "SecFloor")
	_box(Vector3(x, CH+0.1, z), Vector3(RS, 0.2, RS), cm, "SecCeil")
	_box(Vector3(x+RS/2, CH/2, z), Vector3(0.2, CH, RS), wm, "SecWallR")
	_box(Vector3(x, CH/2, z-RS/2), Vector3(RS, CH, 0.2), wm, "SecWallFront")
	_box(Vector3(x, CH/2, z+RS/2), Vector3(RS, CH, 0.2), wm, "SecWallBack")


	# Light (Cold blueish tint for security)
	_omni(Vector3(x, CH-0.4, z), Color(0.4, 0.6, 0.9), 2.0, 8.0)

	# Security Desk & Monitors (Camera Feed)
	_box(Vector3(x+1.0, 0.5, z-1.5), Vector3(3.0, 0.1, 1.2), mm, "SecDesk")
	for m in range(3):
		var screen = _box(Vector3(x+0.5+m*1.0, 1.1, z-1.8), Vector3(0.8, 0.6, 0.05), sm, "CamScreen"+str(m))
		screen.get_parent().rotation_degrees.x = 15.0

	# Dead Guard (Abstract shapes + blood pool)
	_box(Vector3(x+1.5, 0.2, z+1.0), Vector3(1.2, 0.4, 0.6), _metal_mat(), "GuardBody")
	_box(Vector3(x+1.5, 0.01, z+1.0), Vector3(2.0, 0.02, 1.5), bm, "GuardBlood")
	_box(Vector3(x+0.8, 0.01, z+0.5), Vector3(0.5, 0.02, 1.0), bm, "GuardBloodTrail")

	# Keycard Item (Glowing Yellow/Green)
	_box(Vector3(x+0.5, 0.55, z-1.2), Vector3(0.2, 0.05, 0.3), _glow_item_mat(Color(0.8, 1.0, 0.2)), "Keycard")
	_omni(Vector3(x+0.5, 0.8, z-1.2), Color(0.8, 1.0, 0.2), 1.0, 3.0)

func _build_spawn_room(center: Vector3):
	var wm = _wall_mat()
	var fm = _floor_mat()
	var cm = _ceil_mat()
	var x = center.x
	var z = center.z

	# Shell (Smaller starting room)
	_box(Vector3(x, -0.1, z), Vector3(RS, 0.2, RS), fm, "SpawnFloor")
	_box(Vector3(x, CH+0.1, z), Vector3(RS, 0.2, RS), cm, "SpawnCeil")
	_box(Vector3(x-RS/2, CH/2, z), Vector3(0.2, CH, RS), wm, "SpawnWallL")
	_box(Vector3(x+RS/2, CH/2, z), Vector3(0.2, CH, RS), wm, "SpawnWallR")
	_box(Vector3(x, CH/2, z+RS/2), Vector3(RS, CH, 0.2), wm, "SpawnWallBack")
	
	# Front Wall with Gap to Corridor
	_box(Vector3(x-2.0, CH/2, z-RS/2), Vector3(RS/2-1.0, CH, 0.2), wm, "SpawnFrontL")
	_box(Vector3(x+2.0, CH/2, z-RS/2), Vector3(RS/2-1.0, CH, 0.2), wm, "SpawnFrontR")
	_box(Vector3(x, CH-0.4, z-RS/2), Vector3(4.0, 0.7, 0.2), wm, "SpawnLintel")

	# Safe/Neutral Lighting
	_omni(Vector3(x, CH-0.4, z), Color(0.8, 0.8, 0.8), 1.5, 8.0)
	
func _text(pos: Vector3, text: String, rot_y: float):
	var lbl = Label3D.new()
	lbl.text = text
	lbl.position = pos
	lbl.rotation_degrees.y = rot_y
	lbl.pixel_size = 0.004 # Much smaller so it looks painted on
	lbl.modulate = Color(0.7, 0.1, 0.1) # Creepy dark blood red
	lbl.outline_size = 0 # Removes the floating 3D look
	lbl.shaded = true # Makes the text react realistically to your lights!
	lbl.double_sided = false
	lbl.font_size = 100
	add_child(lbl)
