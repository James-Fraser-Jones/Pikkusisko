# this class defines how one speech bubble looks and behaves 
class_name Sentence

# this is the text that will be displayed, it uses bbcode for formatting
# for a brief introduction to bbcode, check out 
# docs.godotengine.org/en/stable/tutorials/gui/bbcode_in_richtextlabel.html
var text : String

# this is the starting speed of the sentence, note that it may be
# changed halfway through if a sentence event changes it
var speed : float

# this is an array of SentenceEvents, check out the SentenceEvent class
# to see what it's used for.
var events : Array


# this is used to define which character is speaking
var character : String

# either a dictionary of choices, a string or null
# if it's null, end dialogue
# if it just has a string, immediately 
# if it's a dictionary of choices, prompt the player to choose between them
var choices

# example choices:
# choices = {
#   "choice1" : "nextsentenceID1"
#   "choice2" : "nextsentenceID2"
# } 
# in the example above, if the player chooses choice1, it will land them into
# the sentence with the id of nextsentenceID1 and so on
#






