extends Node 

signal dialogue_started(dialogue)
signal dialogue_ended(dialogue)
signal sentence_started(sentence)
signal sentence_ended(sentence)

# this is an autoload script that handles dialogues, their loading
# and the way they behave


# this is a dictionary of characters (duh) and it's used to see where
# to instantiate the speech bubbles
var characters : Dictionary = {}
var current_dialogue : Dialogue

const speech_bubble_scene = preload("res://Scenes/SpeechBubble/SpeechBubble.tscn")


func start_dialogue(dialogue : Dialogue):
	emit_signal("dialogue_started",dialogue)
	current_dialogue = dialogue
	for sentence in dialogue.sentences:
		var speech_bubble = speech_bubble_scene.instance()
		speech_bubble.load_sentence(sentence)
		characters[sentence.character].add_child(speech_bubble)

func end_dialogue():
	emit_signal("dialogue_ended",current_dialogue)
	current_dialogue = null

func load_dialogue(file_path : String) -> Dialogue:
	var file := File.new()
	file.open(file_path,file.READ)
	var parseresult := JSON.parse(file.get_as_text())
	var err := parseresult.error
	if err != OK:
		push_error("Couldn't parse at " + str(parseresult.error_line) + ": " + parseresult.error_string)
		return null
		
	var dict : Dictionary = parseresult.result
	var dialogue = dialogue_from_dictionary(dict) 
	return dialogue
	pass


# you probably won't have to use these below

#
static func sentenceevent_from_dictionary(dict : Dictionary) -> SentenceEvent:
	var event = SentenceEvent.new()
	event.type = dict["type"]
	event.index = dict["index"]
	event.value = dict["value"]
	return event
		
static func sentence_from_dictionary(dict : Dictionary) -> Sentence:
	var sentence = Sentence.new()
	sentence.text = dict["text"]
	sentence.character = dict["character"]
	sentence.speed = dict["speed"]
	
	for event_dict in dict["events"]:
		var event = sentenceevent_from_dictionary(event_dict)
		sentence.events.append(event)
	
	return sentence
	
static func dialogue_from_dictionary(dict : Dictionary) -> Dialogue:
	var dialogue = Dialogue.new()
	
	for sentence_dict in dict["sentences"]:
		var sentence = sentence_from_dictionary(sentence_dict)
		dialogue.sentences.append(sentence)
		
	return dialogue

