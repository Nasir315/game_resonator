@tool
extends EditorScript

func _run():
	var root = get_scene()
	if not root:
		print("ERROR: Open a 3D scene first!")
		return
		
	print("Generating Level...")
	
	# Example of how you have to add things now:
	var floor_mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(10, 0.2, 10)
	floor_mesh.mesh = box
	
	# You MUST add it to the scene root, and set the owner so it saves!
	root.add_child(floor_mesh)
	floor_mesh.owner = root
	
	print("Level Generated!")
