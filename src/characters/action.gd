extends Object

# Action is used by controllers to interact with characters.
# Specifically -- player controller can pass to the player character,
# AI controller can pass to AI characters, etc.
class_name Action

enum InteractionType {
	NONE,
	TRIGGER, # doors, buttons, etc.
}

var move_input: Vector2 = Vector2.ZERO
var aim_direction: Vector2 = Vector2.ZERO

var interact_target: Interactable = null
var interact_type: InteractionType = InteractionType.NONE

