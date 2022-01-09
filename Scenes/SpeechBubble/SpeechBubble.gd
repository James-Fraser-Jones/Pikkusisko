class_name SpeechBubble
extends Node2D

signal event_over

const min_width := 24.0
const max_width := 240.0
const min_height := 24.0
const max_height := 1000000.0

onready var body : NinePatchRect = $Body
onready var tail : TextureRect = $Tail
onready var label : RichTextLabel = $Body/Text

var text : String = "HELLO!OO!O!O!"

var current_index := 0
var pause_timer := Timer.new()
var speech_timer := Timer.new() 
var sentence : Sentence
var done := false

# THIS IS TEMPORARY. I'M GONNA REMOVE IT ONCE WE GET A REAL FONT
onready var font := body.get_font("") 

func _ready():
	
	add_child(pause_timer)
	pause_timer.one_shot = true
	add_child(speech_timer)
	
	# changing the modulate to black makes it so that you can't use colors,
	# but changing the color using bbcode is one workaround I found out about.
	label.bbcode_text = "[color=black]" + sentence.text + "[/color]" 
	label.visible_characters = 0
	
	adjust_placement()
	start_typing()
	
func start_typing():
	
	# this loop makes the text appear slowly and it also triggers events
	while current_index < label.text.length():
		current_index += 1
		while sentence.events != [] and current_index == sentence.events[0].index:
			trigger_event(sentence.events[0])
			yield(self,"event_over")
			sentence.events.pop_front()
		speech_timer.start(1/sentence.speed)
		label.visible_characters = current_index
		yield(speech_timer,"timeout")
		
	# kind of weird to put this part after the typing in a function called "start_typing"
	# but yeah, this part is for what to do when the typing eends
	done = true
	
	# this part only triggers if there are choices. the other possibilities are that
	# it continues straight to the next sentence, and that the dialogue ends,
	# you can see about those possibilities in the _unhandled_input function 
	if sentence.choices is Dictionary:
		DialogueInterface.prompt_choices(sentence.choices)
		yield(DialogueInterface,"choice_made")
		DialogueInterface.emit_signal("sentence_ended")
		queue_free()

func _unhandled_input(event):
	if event.is_action_pressed("next_sentence"):
		if done: # if sentence has been written out
			if sentence.choices == null:
				queue_free()
				DialogueInterface.end_dialogue()
			elif sentence.choices is String:
				queue_free()
				DialogueInterface.emit_signal("sentence_ended")
				DialogueInterface.start_sentence_id(sentence.choices)
		else: # the sentence hasn't been written out, so it skips to the last character to write it
			current_index = label.text.length()-1
			pause_timer.start(0.01)
		
func trigger_event(event : SentenceEvent):
	match event.type:
		event.TYPE.PAUSE:
			pause_timer.start(float(event.value))
			yield(pause_timer,"timeout")
		event.TYPE.SPEED: sentence.speed = event.value
		event.TYPE.SKIP: current_index += event.value
		event.TYPE.SOUND: pass # TODO - once we add a sound system
		
	# this is mainly used for pauses, don't pay too much attention to it
	emit_signal("event_over") 
	
func adjust_placement():
	var width = font.get_string_size(label.text).x
	if width > max_width:
		width = font.get_wordwrap_string_size(label.text,max_width-16).x 
	
	var height = clamp(
		font.get_wordwrap_string_size(label.text,width).y + 16, 
		min_height-16, max_height-16
	)
	
	# resizes body and places it above tail accordingly
	body.rect_size = Vector2(width+16,height+16)
	body.rect_position.x = -body.rect_size.x / 2
	body.rect_position.y = -body.rect_size.y - tail.rect_size.y + 2
	
	# tries to drive body away from the edge so that it doesn't get out of the screen
	body.rect_global_position.x = lerp(
		body.rect_global_position.x,
		(get_viewport().size.x - body.rect_size.x)/2,
		0.25
	)
	
	# adjusts its position so that it doesn't get too far away from the tail
	body.rect_position.x = clamp(
		body.rect_position.x,
		-body.rect_size.x + 16,
		-16
	)
	
	
	
	
	
