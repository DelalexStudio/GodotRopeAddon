extends Marker3D

var rope_origin = preload("res://addons/delalex_ropenode/rope.tscn")

@export_subgroup('Rope Length')
@export_range(1,100) var rope_length: int = 15 ## Общая длина веревки
@export_range(0.2,100.0) var rope_segment_length: float = 0.5 ## Длина одного сегмента
@export_range(0.0,1.0) var softness: float = 0.0 ## Насколько веревка тянется?

@export_subgroup('Segment Geometry')
@export_range(1,100) var segment_radial_faces: int = 12 ## Кол-во горизонтальных фейсов
@export_range(0.0,100.0) var segment_radius: float = 0.3 ## Радиус веревки

@export_subgroup('Rope Materials')
@export var segment_material: StandardMaterial3D = StandardMaterial3D.new()
@export var segment_physics_material: PhysicsMaterial = PhysicsMaterial.new()

@export_subgroup('Rope Connections')
@export var NodeA: NodePath
@export var NodeB: NodePath

var NodePathEmpty: NodePath
var rope_last_segment: Object = null
var rope_last_segment_pin: Object = null
var last_build_y: int = 0

func _ready():
	if Engine.is_editor_hint():
		build()

func build():
	for i in rope_length:
		build_rope_segment()
	if not NodeB == NodePathEmpty:
		rope_last_segment_pin.node_a = rope_last_segment
		rope_last_segment_pin.node_b = get_node(NodeB)

func build_rope_segment():
	var segment_rigid = RigidBody3D.new()
	var segment_mesh = MeshInstance3D.new()
	var segment_collider = CollisionShape3D.new()
	var pin = PinJoint3D.new()
	var pin_bottom = PinJoint3D.new()
	
	# SET UP RIGID BODY SEGMENT
	segment_rigid.physics_material_override = segment_physics_material
	
	# SET UP MESH
	segment_mesh.mesh = CylinderMesh.new()
	segment_mesh.material_override = segment_material
	segment_mesh.mesh.rings = 1
	segment_mesh.mesh.height = rope_segment_length
	segment_mesh.mesh.top_radius = segment_radius
	segment_mesh.mesh.bottom_radius = segment_radius
	segment_mesh.mesh.radial_segments = segment_radial_faces
	
	# SET UP COLLIDER
	segment_collider.shape = CylinderShape3D.new()
	segment_collider.shape.radius = segment_radius
	segment_collider.shape.height = rope_segment_length
	
	# SET UP PIN JOINT
	#pin.params/bias
	
	# ADD EVERYTHING
	get_tree().get_root().call_deferred("add_child", segment_rigid)
	segment_rigid.position.y = last_build_y
	last_build_y -= rope_segment_length
	segment_rigid.add_child(segment_mesh)
	segment_mesh.add_child(pin_bottom)
	segment_rigid.add_child(pin)
	segment_rigid.add_child(segment_collider)
	await get_tree().create_timer(0.5).timeout
	
	# CONFIGURE
	pin_bottom.position.y -= rope_segment_length/2
	pin.position.y += rope_segment_length/2
	
	if rope_last_segment == null:
		if not NodeA == NodePathEmpty:
			pin.node_a = NodeA
		else:
			var origin = rope_origin.instantiate()
			add_child(origin)
			pin.node_a = origin.get_path()
		pin.node_b = segment_rigid.get_path()
	else:
		rope_last_segment_pin.node_a = rope_last_segment.get_path()
		rope_last_segment_pin.node_b = segment_rigid.get_path()

	
	rope_last_segment = segment_rigid
	rope_last_segment_pin = pin_bottom
