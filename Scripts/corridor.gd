@tool
extends Node3D

const CORRIDOR_LENGTH = 30.0
const CORRIDOR_WIDTH = 4.0
const CORRIDOR_HEIGHT = 3.5
const ROOM_SIZE = 6.0
const ROOM_DEPTH = 7.0
const NUM_SIDE_ROOMS = 2

func _ready():
	_setup_environment()
	build_corridor()

func _setup_environment():
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.02, 0.02, 0.02)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.6, 0.55, 0.5)
	env.ambient_light_energy = 1.8
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.glow_enabled = true
	env.glow_intensity = 0.4
	env.glow_bloom = 0.15

	var world_env = WorldEnvironment.new()
	world_env.environment = env
	add_child(world_env)

func build_corridor():
	# --- MATERIALS ---
	var wall_mat = StandardMaterial3D.new()
	wall_mat.albedo_color = Color(0.18, 0.16, 0.15)
	wall_mat.roughness = 0.95

	var floor_mat = StandardMaterial3D.new()
	floor_mat.albedo_color = Color(0.13, 0.12, 0.11)
	floor_mat.roughness = 1.0

	var ceiling_mat = StandardMaterial3D.new()
	ceiling_mat.albedo_color = Color(0.10, 0.09, 0.09)
	ceiling_mat.roughness = 1.0

	var door_mat = StandardMaterial3D.new()
	door_mat.albedo_color = Color(0.22, 0.18, 0.14)
	door_mat.roughness = 0.8
	door_mat.metallic = 0.3

	var metal_mat = StandardMaterial3D.new()
	metal_mat.albedo_color = Color(0.35, 0.33, 0.30)
	metal_mat.roughness = 0.4
	metal_mat.metallic = 0.85

	var glass_mat = StandardMaterial3D.new()
	glass_mat.albedo_color = Color(0.4, 0.7, 0.6, 0.25)
	glass_mat.roughness = 0.05
	glass_mat.metallic = 0.0
	glass_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	var paper_mat = StandardMaterial3D.new()
	paper_mat.albedo_color = Color(0.75, 0.72, 0.60)
	paper_mat.roughness = 1.0

	var screen_mat = StandardMaterial3D.new()
	screen_mat.albedo_color = Color(0.05, 0.25, 0.15)
	screen_mat.emission_enabled = true
	screen_mat.emission = Color(0.0, 0.6, 0.3)
	screen_mat.emission_energy_multiplier = 1.2

	var blood_mat = StandardMaterial3D.new()
	blood_mat.albedo_color = Color(0.35, 0.02, 0.02)
	blood_mat.roughness = 0.9

	# --- CORRIDOR FLOOR (seamless — no gap) ---
	_make_box(
		Vector3(0, -0.1, -CORRIDOR_LENGTH / 2),
		Vector3(CORRIDOR_WIDTH, 0.2, CORRIDOR_LENGTH),
		floor_mat, "CorridorFloor"
	)

	# --- CORRIDOR CEILING ---
	_make_box(
		Vector3(0, CORRIDOR_HEIGHT + 0.1, -CORRIDOR_LENGTH / 2),
		Vector3(CORRIDOR_WIDTH, 0.2, CORRIDOR_LENGTH),
		ceiling_mat, "CorridorCeiling"
	)

	# --- CORRIDOR WALLS ---
	_make_box(
		Vector3(-CORRIDOR_WIDTH / 2 - 0.1, CORRIDOR_HEIGHT / 2, -CORRIDOR_LENGTH / 2),
		Vector3(0.2, CORRIDOR_HEIGHT, CORRIDOR_LENGTH),
		wall_mat, "WallLeft"
	)
	_make_box(
		Vector3(CORRIDOR_WIDTH / 2 + 0.1, CORRIDOR_HEIGHT / 2, -CORRIDOR_LENGTH / 2),
		Vector3(0.2, CORRIDOR_HEIGHT, CORRIDOR_LENGTH),
		wall_mat, "WallRight"
	)
	_make_box(
		Vector3(0, CORRIDOR_HEIGHT / 2, 0.1),
		Vector3(CORRIDOR_WIDTH, CORRIDOR_HEIGHT, 0.2),
		wall_mat, "WallBack"
	)

	# --- SIDE ROOMS ---
	var room_z_positions = [-8.0, -20.0]
	var sides = [-1, 1]

	for side in sides:
		for i in range(NUM_SIDE_ROOMS):
			var z = room_z_positions[i]
			var x_offset = side * (CORRIDOR_WIDTH / 2 + ROOM_DEPTH / 2)
			var room_name = ("Left" if side == -1 else "Right") + "Room" + str(i + 1)
			_build_side_room(Vector3(x_offset, 0, z), side, room_name, wall_mat, floor_mat, ceiling_mat, door_mat, metal_mat, glass_mat, paper_mat, screen_mat, blood_mat)

	# --- FLOOR BRIDGE between corridor and end room ---
	_make_box(
		Vector3(0, -0.1, -CORRIDOR_LENGTH - 1.0),
		Vector3(CORRIDOR_WIDTH, 0.2, 2.2),
		floor_mat, "BridgeFloor"
	)

	# --- END ROOM ---
	_build_end_room(Vector3(0, 0, -CORRIDOR_LENGTH - ROOM_SIZE), wall_mat, floor_mat, ceiling_mat, metal_mat, glass_mat, screen_mat, blood_mat)

	# --- CORRIDOR LIGHTS (brighter) ---
	var light_positions = [-4.0, -10.0, -17.0, -24.0]
	for lz in light_positions:
		_make_corridor_light(Vector3(0, CORRIDOR_HEIGHT - 0.3, lz))

	# --- AMBIENT fill light so nothing is pitch black ---
	var ambient = OmniLight3D.new()
	ambient.position = Vector3(0, CORRIDOR_HEIGHT / 2, -CORRIDOR_LENGTH / 2)
	ambient.light_color = Color(0.4, 0.35, 0.3)
	ambient.light_energy = 0.4
	ambient.omni_range = 40.0
	ambient.light_bake_mode = Light3D.BAKE_DISABLED
	add_child(ambient)

func _build_side_room(center: Vector3, side: int, room_name: String,
		wall_mat, floor_mat, ceiling_mat, door_mat, metal_mat, glass_mat, paper_mat, screen_mat, blood_mat):
	var x = center.x
	var z = center.z

	# Floor
	_make_box(Vector3(x, -0.1, z), Vector3(ROOM_DEPTH, 0.2, ROOM_SIZE), floor_mat, room_name + "_Floor")
	# Ceiling
	_make_box(Vector3(x, CORRIDOR_HEIGHT + 0.1, z), Vector3(ROOM_DEPTH, 0.2, ROOM_SIZE), ceiling_mat, room_name + "_Ceiling")
	# Back wall
	_make_box(Vector3(x + side * (ROOM_DEPTH / 2), CORRIDOR_HEIGHT / 2, z),
		Vector3(0.2, CORRIDOR_HEIGHT, ROOM_SIZE), wall_mat, room_name + "_BackWall")
	# Side walls
	_make_box(Vector3(x, CORRIDOR_HEIGHT / 2, z - ROOM_SIZE / 2),
		Vector3(ROOM_DEPTH, CORRIDOR_HEIGHT, 0.2), wall_mat, room_name + "_SideWallA")
	_make_box(Vector3(x, CORRIDOR_HEIGHT / 2, z + ROOM_SIZE / 2),
		Vector3(ROOM_DEPTH, CORRIDOR_HEIGHT, 0.2), wall_mat, room_name + "_SideWallB")

	# Front wall — split for doorway
	_make_box(Vector3(x - side * (ROOM_DEPTH / 2 - 0.1), CORRIDOR_HEIGHT / 2, z - ROOM_SIZE / 2 + 0.8),
		Vector3(0.2, CORRIDOR_HEIGHT, ROOM_SIZE - 4.2), wall_mat, room_name + "_FrontWallA")
	_make_box(Vector3(x - side * (ROOM_DEPTH / 2 - 0.1), CORRIDOR_HEIGHT / 2, z + ROOM_SIZE / 2 - 0.8),
		Vector3(0.2, CORRIDOR_HEIGHT, ROOM_SIZE - 4.2), wall_mat, room_name + "_FrontWallB")
	_make_box(Vector3(x - side * (ROOM_DEPTH / 2 - 0.1), CORRIDOR_HEIGHT - 0.4, z),
		Vector3(0.2, 0.7, 3.6), wall_mat, room_name + "_Lintel")

	# Door — slightly ajar
	var door = _make_box(
		Vector3(x - side * (ROOM_DEPTH / 2 - 0.25), 1.1, z - 1.2),
		Vector3(0.08, 2.2, 1.1), door_mat, room_name + "_Door"
	)
	door.get_parent().rotation_degrees.y = 75.0 * side

	# Room light
	_make_omni_light(Vector3(x, CORRIDOR_HEIGHT - 0.5, z), 6.0, Color(0.5, 0.45, 0.35), 1.4)

	# --- LAB CONTENTS per room ---
	if room_name == "LeftRoom1":
		_furnish_sample_storage(x, z, side, metal_mat, glass_mat, paper_mat)
	elif room_name == "RightRoom1":
		_furnish_monitoring_station(x, z, side, metal_mat, screen_mat, paper_mat)
	elif room_name == "LeftRoom2":
		_furnish_containment_prep(x, z, side, metal_mat, glass_mat, blood_mat)
	elif room_name == "RightRoom2":
		_furnish_equipment_storage(x, z, side, metal_mat, glass_mat)

func _furnish_sample_storage(x, z, side, metal_mat, glass_mat, paper_mat):
	# Shelving unit on back wall
	for shelf in range(3):
		_make_box(Vector3(x + side * 2.8, 0.5 + shelf * 0.7, z),
			Vector3(0.3, 0.08, ROOM_SIZE - 0.4), metal_mat, "SampleShelf" + str(shelf))
		# Vials on each shelf
		for v in range(5):
			var vial = _make_box(Vector3(x + side * 2.6, 0.65 + shelf * 0.7, z - 1.5 + v * 0.7),
				Vector3(0.08, 0.2, 0.08), glass_mat, "Vial_" + str(shelf) + str(v))
	# Lab table
	_make_box(Vector3(x, 0.45, z), Vector3(ROOM_DEPTH - 1.5, 0.08, 1.2), metal_mat, "SampleTable")
	_make_box(Vector3(x - 1.0, 0.22, z), Vector3(0.08, 0.45, 0.08), metal_mat, "TableLegA")
	_make_box(Vector3(x + 1.0, 0.22, z), Vector3(0.08, 0.45, 0.08), metal_mat, "TableLegB")
	# Papers on table
	_make_box(Vector3(x, 0.5, z + 0.2), Vector3(0.6, 0.02, 0.4), paper_mat, "SamplePapers")
	# Microscope-ish shape
	_make_box(Vector3(x - 1.2, 0.6, z - 0.1), Vector3(0.18, 0.28, 0.18), metal_mat, "Microscope_Base")
	_make_box(Vector3(x - 1.2, 0.88, z - 0.1), Vector3(0.06, 0.35, 0.06), metal_mat, "Microscope_Arm")

func _furnish_monitoring_station(x, z, side, metal_mat, screen_mat, paper_mat):
	# Desk along back wall
	_make_box(Vector3(x + side * 2.0, 0.45, z), Vector3(2.8, 0.08, ROOM_SIZE - 0.6), metal_mat, "MonitorDesk")
	# Monitor screens (3 of them)
	for m in range(3):
		_make_box(Vector3(x + side * 2.6, 1.1, z - 1.0 + m * 1.0),
			Vector3(0.06, 0.5, 0.75), screen_mat, "Screen" + str(m))
		# Screen stand
		_make_box(Vector3(x + side * 2.55, 0.6, z - 1.0 + m * 1.0),
			Vector3(0.04, 0.3, 0.04), metal_mat, "ScreenStand" + str(m))
	# Chair
	_make_box(Vector3(x + side * 1.2, 0.4, z), Vector3(0.6, 0.06, 0.6), metal_mat, "ChairSeat")
	_make_box(Vector3(x + side * 1.2, 0.78, z + 0.27), Vector3(0.6, 0.55, 0.06), metal_mat, "ChairBack")
	# Papers scattered
	_make_box(Vector3(x + side * 2.2, 0.5, z - 0.5), Vector3(0.5, 0.015, 0.35), paper_mat, "MonPapers1")
	_make_box(Vector3(x + side * 2.2, 0.5, z + 0.6), Vector3(0.4, 0.015, 0.3), paper_mat, "MonPapers2")

func _furnish_containment_prep(x, z, side, metal_mat, glass_mat, blood_mat):
	# Central examination table
	_make_box(Vector3(x, 0.5, z), Vector3(ROOM_DEPTH - 2.0, 0.1, 2.0), metal_mat, "ExamTable")
	for leg in [Vector3(-1.5, 0.25, -0.8), Vector3(1.5, 0.25, -0.8),
				Vector3(-1.5, 0.25, 0.8), Vector3(1.5, 0.25, 0.8)]:
		_make_box(Vector3(x + leg.x, leg.y, z + leg.z),
			Vector3(0.08, 0.5, 0.08), metal_mat, "ExamLeg" + str(leg))
	# Restraint straps visual (flat dark strips)
	_make_box(Vector3(x, 0.56, z - 0.5), Vector3(ROOM_DEPTH - 2.2, 0.03, 0.12), blood_mat, "Strap1")
	_make_box(Vector3(x, 0.56, z + 0.5), Vector3(ROOM_DEPTH - 2.2, 0.03, 0.12), blood_mat, "Strap2")
	# Blood smear on floor near table
	_make_box(Vector3(x + side * 0.5, 0.01, z + 1.2), Vector3(0.9, 0.02, 0.5), blood_mat, "BloodSmear")
	# IV stand
	_make_box(Vector3(x + side * 1.8, 1.1, z - 0.5), Vector3(0.04, 2.2, 0.04), metal_mat, "IVPole")
	_make_box(Vector3(x + side * 1.8, 2.15, z - 0.5), Vector3(0.5, 0.04, 0.04), metal_mat, "IVCrossbar")
	# Sample containers on shelf
	for shelf in range(2):
		_make_box(Vector3(x + side * 2.8, 0.6 + shelf * 0.8, z + 1.5),
			Vector3(0.2, 0.06, 1.8), metal_mat, "ContainShelf" + str(shelf))
		for j in range(3):
			_make_box(Vector3(x + side * 2.65, 0.75 + shelf * 0.8, z + 0.8 + j * 0.35),
				Vector3(0.12, 0.22, 0.12), glass_mat, "ContainVial" + str(shelf) + str(j))

func _furnish_equipment_storage(x, z, side, metal_mat, glass_mat):
	# Large equipment crates/cabinets
	for c in range(3):
		_make_box(Vector3(x + side * 2.5, 0.7, z - 1.5 + c * 1.5),
			Vector3(1.0, 1.4, 1.1), metal_mat, "Cabinet" + str(c))
		# Cabinet handle
		_make_box(Vector3(x + side * 2.0, 0.75, z - 1.5 + c * 1.5),
			Vector3(0.04, 0.04, 0.25), glass_mat, "Handle" + str(c))
	# Gas cylinders leaning on wall
	for cyl in range(2):
		_make_box(Vector3(x + side * 2.8, 0.6, z + 1.5 - cyl * 0.5),
			Vector3(0.22, 1.2, 0.22), metal_mat, "GasCyl" + str(cyl))
	# Fallen equipment box on floor
	_make_box(Vector3(x, 0.2, z + 1.0), Vector3(1.2, 0.4, 0.8), metal_mat, "FallenBox")

func _build_end_room(center: Vector3, wall_mat, floor_mat, ceiling_mat, metal_mat, glass_mat, screen_mat, blood_mat):
	var x = center.x
	var z = center.z
	var end_size = ROOM_SIZE * 1.8

	_make_box(Vector3(x, -0.1, z), Vector3(end_size, 0.2, end_size), floor_mat, "EndRoom_Floor")
	_make_box(Vector3(x, CORRIDOR_HEIGHT + 0.1, z), Vector3(end_size, 0.2, end_size), ceiling_mat, "EndRoom_Ceiling")
	_make_box(Vector3(x, CORRIDOR_HEIGHT / 2, z - end_size / 2), Vector3(end_size, CORRIDOR_HEIGHT, 0.2), wall_mat, "EndRoom_FarWall")
	_make_box(Vector3(x - end_size / 2, CORRIDOR_HEIGHT / 2, z), Vector3(0.2, CORRIDOR_HEIGHT, end_size), wall_mat, "EndRoom_LeftWall")
	_make_box(Vector3(x + end_size / 2, CORRIDOR_HEIGHT / 2, z), Vector3(0.2, CORRIDOR_HEIGHT, end_size), wall_mat, "EndRoom_RightWall")

	# Central operating table
	_make_box(Vector3(x, 0.5, z), Vector3(3.5, 0.1, 1.8), metal_mat, "OpTable")
	for leg in [Vector3(-1.5, 0.25, -0.7), Vector3(1.5, 0.25, -0.7),
				Vector3(-1.5, 0.25, 0.7), Vector3(1.5, 0.25, 0.7)]:
		_make_box(Vector3(x + leg.x, leg.y, z + leg.z), Vector3(0.1, 0.5, 0.1), metal_mat, "OpLeg" + str(leg))

	# Overhead surgical light rig
	_make_box(Vector3(x, CORRIDOR_HEIGHT - 0.2, z), Vector3(1.2, 0.1, 0.5), metal_mat, "SurgLightRig")
	_make_omni_light(Vector3(x, CORRIDOR_HEIGHT - 0.35, z), 5.0, Color(0.9, 0.88, 0.82), 3.5)

	# Large containment tank (glass tube with subject)
	_make_box(Vector3(x - 3.5, 1.2, z - 2.0), Vector3(0.9, 2.4, 0.9), glass_mat, "ContainTank")
	_make_box(Vector3(x - 3.5, 0.1, z - 2.0), Vector3(1.0, 0.2, 1.0), metal_mat, "TankBase")
	_make_box(Vector3(x - 3.5, 2.5, z - 2.0), Vector3(1.0, 0.2, 1.0), metal_mat, "TankTop")

	# Wall of monitors on far wall
	for m in range(4):
		_make_box(Vector3(x - 3.0 + m * 1.8, 2.0, z - end_size / 2 + 0.1),
			Vector3(1.4, 0.9, 0.08), screen_mat, "EndScreen" + str(m))

	# Blood on floor near table
	_make_box(Vector3(x + 0.8, 0.01, z + 1.2), Vector3(1.5, 0.02, 0.7), blood_mat, "EndBlood1")
	_make_box(Vector3(x - 1.0, 0.01, z - 1.0), Vector3(0.6, 0.02, 0.9), blood_mat, "EndBlood2")

	# Crashed/overturned equipment cart
	_make_box(Vector3(x + 3.0, 0.3, z + 1.5), Vector3(1.0, 0.6, 0.7), metal_mat, "OverturnedCart")

	# End room ambient — sickly green
	_make_omni_light(Vector3(x, CORRIDOR_HEIGHT - 0.5, z + 2.0), 12.0, Color(0.3, 0.6, 0.25), 1.0)

func _make_corridor_light(pos: Vector3):
	var light = SpotLight3D.new()
	light.position = pos
	light.rotation_degrees.x = -90
	light.light_color = Color(0.85, 0.75, 0.55)
	light.light_energy = 2.8
	light.spot_range = 8.0
	light.spot_angle = 45.0
	light.shadow_enabled = true
	light.light_bake_mode = Light3D.BAKE_DISABLED
	add_child(light)

func _make_omni_light(pos: Vector3, radius: float, color: Color, energy: float):
	var light = OmniLight3D.new()
	light.position = pos
	light.light_color = color
	light.light_energy = energy
	light.omni_range = radius
	light.shadow_enabled = true
	light.light_bake_mode = Light3D.BAKE_DISABLED
	add_child(light)

func _make_box(pos: Vector3, size: Vector3, mat: StandardMaterial3D, node_name: String) -> MeshInstance3D:
	var body = StaticBody3D.new()
	body.name = node_name
	body.position = pos

	var mesh_instance = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = size
	mesh_instance.mesh = box
	mesh_instance.material_override = mat

	var col = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = size
	col.shape = shape

	body.add_child(mesh_instance)
	body.add_child(col)
	add_child(body)

	return mesh_instance
