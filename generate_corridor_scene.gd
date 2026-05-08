@tool
extends EditorScript

func _run():
	print("Generating new_corridor.tscn...")
	
	# Load the script that has the generation logic
	var script = load("res://corridor_integrate.gd")
	if not script:
		printerr("Could not load res://corridor_integrate.gd")
		return
		
	var root = Node3D.new()
	root.name = "Corridor"
	
	# Attach the script so we can call its methods
	root.set_script(script)
	
	# Generate the level geometry, lights, labels, etc.
	root._generate_level()
	
	# Remove the script so the resulting scene is completely static
	# and won't regenerate when you open it
	root.set_script(null)
	
	# Recursively set the owner of every generated node to the root.
	# This is REQUIRED for Godot to save children in a PackedScene.
	_set_owner(root, root)
	
	# Pack the node tree into a PackedScene
	var packed = PackedScene.new()
	var pack_err = packed.pack(root)
	if pack_err != OK:
		printerr("Failed to pack scene. Error code: ", pack_err)
		return
		
	# Save the PackedScene to a .tscn file
	var save_err = ResourceSaver.save(packed, "res://new_corridor.tscn")
	if save_err == OK:
		print("Successfully generated res://new_corridor.tscn!")
		print("You can now open this file in the 3D editor and make your changes.")
	else:
		printerr("Failed to save res://new_corridor.tscn. Error code: ", save_err)

func _set_owner(node: Node, root: Node):
	if node != root:
		node.owner = root
	for child in node.get_children():
		_set_owner(child, root)
