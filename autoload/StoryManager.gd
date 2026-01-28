extends Node

# Define every step of your story here
enum Step { 
	START_CUTSCENE, 
	CHASE_CHILD_B1, 
	MAP_PLACEMENT_TUTORIAL, 
	RECLAIM_TUTORIAL, 
	FIND_B2, 
	CHASE_LIVING_ROOM 
}

var current_step = Step.START_CUTSCENE

# Use signals to tell other nodes when the story moves forward
signal story_updated(new_step)

func advance_story(next_step: Step):
	current_step = next_step
	story_updated.emit(next_step)
	print("Story advanced to: ", Step.keys()[next_step])
