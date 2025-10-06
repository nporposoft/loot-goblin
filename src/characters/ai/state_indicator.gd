class_name StateIndicator
extends Label

const SUSPICIOUS_COLOR: Color = Color(1, 1, 0) # Yellow
const ALERT_COLOR: Color = Color(1, 0, 0) # Red

var ai_controller: AggressiveAI = null


func _ready():
	ai_controller.state_changed.connect(_handle_state_change)


func _handle_state_change(new_state: AggressiveAI.State) -> void:
	# TODO: handle death
	match new_state:
		AggressiveAI.State.SUSPICIOUS:
			text = "?"
			self.modulate = SUSPICIOUS_COLOR
			visible = true
		AggressiveAI.State.ATTACKING:
			text = "!"
			self.modulate = ALERT_COLOR
			visible = true
		AggressiveAI.State.LOOKING:
			text = "?"
			self.modulate = ALERT_COLOR
			visible = true
		AggressiveAI.State.SEARCHING:
			text = "?"
			self.modulate = ALERT_COLOR
			visible = true
		_:
			visible = false
