class_name TowerShapes extends RefCounted

var shape_dictionary : Dictionary[int, Array] = {
	2 : [
		[Vector2i(0, -1), Vector2i(0, 0)] #Gemini
	],
	3 : [
		[Vector2i(0, -1), Vector2i(0, 0), Vector2i(0, 1)], #Orion
		[Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1)] #Ursa Minor
	],
	4 : [
		 
	],
	5 : [
		
	],
	6 : [
		
	],
	7 : [
		#Durin's Door
		[Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(-1, 1), Vector2i(1, 1)]

	],
	8 : [
		
	],
	9 : [
		#Ursa Major
		[Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1)]

],
}
