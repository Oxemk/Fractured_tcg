extends Node

func save_data(path: String, data: Dictionary) -> void:
	DataUtils.save_data(path, data)

func load_data(path: String) -> Dictionary:
	return DataUtils.load_data(path)
