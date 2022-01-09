extends Node 

signal dialogue_started(dialogue)
signal dialogue_ended(dialogue)
signal sentence_started(sentence)
signal sentence_ended(sentence)
signal choice_made(choice)

# this is an autoload script that handles dialogues, their loading
# and the way they behave


# this is a dictionary of characters (duh) and it's used to see where
# to instantiate the speech bubbles
var characters : Dictionary = {}

var current_dialogue : Dialogue
var current_sentence : Sentence

const speech_bubble_scene = preload("res://Scenes/SpeechBubble/SpeechBubble.tscn")
const choice_selection_scene = preload("res://Scenes/SpeechBubble/ChoiceSelection.tscn")

func start_dialogue_id(dialogue_id : String):
	var dialogue = load_dialogue("res://Dialogues/"+dialogue_id+".json")
	start_dialogue(dialogue)
	
	
func start_dialogue(dialogue : Dialogue):
	var first_sentence = dialogue.sentences[dialogue.first_sentence]
	
	start_sentence(first_sentence)
	
	current_dialogue = dialogue
	emit_signal("dialogue_started",dialogue)
	
	
func end_dialogue():
	emit_signal("dialogue_ended",current_dialogue)
	current_dialogue = null
	
	
func start_sentence_id(sentence_id : String) -> SpeechBubble:
	return start_sentence(current_dialogue.sentences[sentence_id])
	
	
func start_sentence(sentence : Sentence) -> SpeechBubble:
	var speech_bubble = speech_bubble_scene.instance()
	speech_bubble.sentence = sentence
	characters[sentence.character].add_child(speech_bubble)
	current_sentence = sentence
	emit_signal("sentence_started",sentence)
	return speech_bubble
	
	
func prompt_choices(choices : Dictionary): # pops up the choice selection
	var choice_selection = choice_selection_scene.instance()
	for choice_text in choices:
		choice_selection.add_choice([ choice_text, choices[choice_text] ])
	get_tree().current_scene.add_child(choice_selection)
	
	
# parses text and returns "text" : same text without the {} tags, and "events": the events found in it
# example string: "something something{PAUSE:3} [color=red]something[/color] something something"
# the text it returns still contains the bbcode tags
static func parse_events(text : String) -> Dictionary:
	var events = []
	while true:
		var pos1 = text.find("{")
		if pos1 == -1: break
		var pos2 = text.find("}",pos1)
		if pos2 == -1: 
			print("something went wrong with parsing the events, maybe you forgot to close a bracket?")
			break
		var length = pos2-pos1
		var a = text.substr(pos1+1,length-1).split(":")
		text.erase(pos1,length+1)
		var event = SentenceEvent.new()
		event.type = SentenceEvent.TYPE[a[0]]
		event.value = a[1]
		event.index = pos1+1
		events.append(event)
	return {
		"text" : text,
		"events" : events
	}
	
	
static func load_dialogue(file_path : String) -> Dialogue:
	var file := File.new()
	file.open(file_path,file.READ)
	var parse_result := JSON.parse(file.get_as_text())
	var err := parse_result.error
	if err != OK:
		push_error("Couldn't parse at " + str(parse_result.error_line) + ": " + parse_result.error_string)
		return null
	var dict : Dictionary = parse_result.result
	var dialogue = dialogue_from_dictionary(dict) 
	return dialogue
	
	
#static func sentenceevent_from_dictionary(dict : Dictionary) -> SentenceEvent:
#	var event = SentenceEvent.new()
#	event.type = SentenceEvent.TYPE.get(dict["type"])
#	event.index = dict["index"]
#	event.value = dict["value"]
#	return event
	
	
static func sentence_from_dictionary(dict : Dictionary) -> Sentence:
	var sentence = Sentence.new()
	var parsed = parse_events(dict["text"])
	sentence.text = parsed["text"]
	sentence.events = parsed["events"]
	sentence.character = dict["character"]
	sentence.speed = dict["speed"]
	sentence.choices = dict["choices"]
	
#	for event_dict in dict["events"]:
#		var event = sentenceevent_from_dictionary(event_dict)
#		sentence.events.append(event)
	
	return sentence
	
	
static func dialogue_from_dictionary(dict : Dictionary) -> Dialogue:
	var dialogue = Dialogue.new()
	dialogue.first_sentence = dict["first_sentence"]
	
	for sentence_id in dict["sentences"]:
		var sentence = sentence_from_dictionary(dict["sentences"][sentence_id])
		dialogue.sentences[sentence_id] = sentence
		
	return dialogue
