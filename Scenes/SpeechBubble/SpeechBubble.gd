extends Node2D

const min_width : float = 48.0
const max_width : float = 240.0
const min_height : float = 48.0
const max_height : float = 1000000.0

onready var body : NinePatchRect = $Body
onready var tail : TextureRect = $Tail
onready var label : RichTextLabel = $Body/Text

# text without the bbcode tags
var raw_text : String

# text with the bbcode tags
var text : String = "HELLO!OO!O!O!"

# array of SentenceEvents
var events : Array

var speed : float = 10.0
var current_index := 0
var pause_timer := Timer.new()
var speech_timer := Timer.new() 

# THIS IS TEMPORARY. I'M GONNA REMOVE IT ONCE WE GET A REAL FONT
onready var font : Font = body.get_font("") 

func bbcode_to_raw_text(bbcode : String):
	var regex_text = "\\[(\\w+)[^\\]]*](.*?)\\[\\/\\1]"
	var regex = RegEx.new()
	regex.compile(regex_text)
	var regex_match : RegExMatch = regex.search(bbcode)
	return regex_match.strings[-1]

func load_sentence(sentence : Sentence):
	text = sentence.text
	speed = sentence.speed
	events = sentence.events
	raw_text = bbcode_to_raw_text(text)

func _ready():
	
	# DEBUG - REMOVE BEFORE COMMITING
	var event = SentenceEvent.new()
	event.type = event.TYPE.SPEED
	event.index = 10
	event.value = 52
	var sentence = Sentence.new()
	sentence.text = "[wave amp=50 freq=2]Hello!!!!!!!!! !!!!!!!!!!!!!! !!!!!!!!!!!![/wave]"
	sentence.speed = 3.0
	sentence.character = "petar"
	sentence.events = [event]
	load_sentence(sentence)
	# /DEBUG
	
	add_child(pause_timer)
	add_child(speech_timer)
	label.bbcode_text = text
	adjust_placement()
	label.visible_characters = 0
	start_typing()
	
func start_typing():
	while current_index < raw_text.length():
		current_index += 1
		while events != [] and current_index >= events[0].index:
			trigger_event(events[0])
			events.pop_front()
		speech_timer.start(1/speed)
		label.visible_characters = current_index
		yield(speech_timer,"timeout")
	
		
func trigger_event(event : SentenceEvent):
	match event.type:
		event.TYPE.PAUSE:
			pause_timer.start(event.value)
			yield(pause_timer,"timeout")
		event.TYPE.SPEED:
			speed = event.value
		event.TYPE.SKIP:
			current_index += event.value
		event.TYPE.SOUND:
			pass # TODO - once we add a sound system
	
func adjust_placement():
	var width = font.get_string_size(raw_text).x+16
	if width > max_width:
		width = font.get_wordwrap_string_size(raw_text,max_width-16).x 
	
	var height = clamp(
		font.get_wordwrap_string_size(raw_text,width).y + 16, 
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
	
	
	
	
	
