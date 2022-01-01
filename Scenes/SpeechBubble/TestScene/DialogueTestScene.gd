extends Node2D

# this is a test scene. the way you'd use this dialogue system in game is that
# you'd put in the characters like on the first 2 lines of _ready and then
# start the dialogue using the start_dialogue_id method.

func _ready():
	DialogueInterface.characters["test1"] = $Character1
	DialogueInterface.characters["test2"] = $Character2
	DialogueInterface.start_dialogue_id("TEST_DIALOGUE")
	DialogueInterface.connect("choice_made",self,"signal_received",["choice_made"])
	DialogueInterface.connect("dialogue_ended",self,"signal_received",["dialogue_ended"])
	DialogueInterface.connect("dialogue_started",self,"signal_received",["dialogue_started"])
	DialogueInterface.connect("sentence_started",self,"signal_received",["sentence_started"])
	DialogueInterface.connect("sentence_ended",self,"signal_received",["sentence_ended"])
	
	
func signal_received(a, b = "b"):
	if b == "b": 
		print(a)
	else:
		print(b)
