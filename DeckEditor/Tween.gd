extends Popup

@onready var tween = $Tween  # Reference to the Tween node

func _ready():
	# Immediately hide the popup (you may want to adjust this if the popup is visible initially)
	self.modulate.a = 0.0
	self.scale = Vector2(0.8, 0.8)  # Start the popup at 80% of its size

	# Play the fade-in and zoom-in animation
	fade_in_and_zoom()

# Function to handle fade-in and zoom-in effect
func fade_in_and_zoom():
	# Fade in the popup (modulate: alpha from 0 to 1)
	tween.tween_property(self, "modulate:a", 1.0, 0.25, Tween.TRANS_SINE, Tween.EASE_OUT)

	# Zoom in (scale from 0.8 to 1)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.25, Tween.TRANS_SINE, Tween.EASE_OUT)
