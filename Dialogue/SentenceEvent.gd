# this class is used for defining sentence events. a sentence event
# is controls how quickly the text appears and stuff like that
class_name SentenceEvent

enum TYPE {
	SPEED, # changes how quickly the text appears
	SKIP, # makes a number of characters appear right away
	PAUSE, # makes a brief pause
	SOUND, # makes a sound
}
var type : int

# index of the character at which the event triggers 
var index : int

# "value" of the event, its use varies depending on the type
# TYPE.SPEED would use the value to see how fast it should go,
# TYPE.PAUSE would use the value to see how long it has to pause for,
# TYPE.SOUND would play the sound (PATH) stored in the value
var value


