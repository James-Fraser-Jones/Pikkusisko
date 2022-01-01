extends CanvasLayer

export var choice_container_path : NodePath


func add_choice(choice : Array): # index 0 is the text, index 1 is the sentence it leads to
	var choice_button = Button.new()
	choice_button.text = choice[0]
	choice_button.connect("pressed",self,"choice_pressed",[choice])
	get_node(choice_container_path).add_child(choice_button)

func choice_pressed(choice : Array):
	var next_sentence = DialogueInterface.current_dialogue.sentences[choice[1]]
	DialogueInterface.emit_signal("choice_made")
	DialogueInterface.start_sentence(next_sentence)
	queue_free()
