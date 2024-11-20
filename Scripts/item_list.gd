extends Node2D

var items: Array[Collectible] = []

@export var followSpeed: float = 10

func _process(delta):
	if visible:
		for i in items.size():
			## todo: if im being picky... try this to improve follow
			## if lerped point intersects circle, move it along the ray intersecting circle center and lerped point until its outside da circle
			## Also offset follow position a bit so they dont overlap...?
			var targetPos: Vector2 = global_position if i == 0 else items[i-1].position
			items[i].position = items[i].position.lerp(targetPos, delta * followSpeed)
	
func add_item(item: Collectible, removePoints = false):
	# This is annoying, but in case we want to show following guys, but granting points immediately
	# todo: remove if we remove "grant points immediately" option
	if removePoints:
		item.pointValue = 0
	items.append(item)
	
func get_total_points() -> int:
	var sum: int = 0
	for i in items:
		sum += i.pointValue
	return sum
