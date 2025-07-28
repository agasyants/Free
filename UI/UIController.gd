extends CanvasLayer

func _ready() -> void:
	var left_parry = $LeftButtons/ParryButton
	var right_parry = $RightButtons/ParryButton
	match Settings.get_setting("parry_layout"):
		"left":
			right_parry.hide()
		"right":
			print(left_parry)
			left_parry.hide()
