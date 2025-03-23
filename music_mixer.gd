extends Node

enum Track {NONE, TITLE, LEVEL, KAIZO}

var current_track = Track.NONE

func stop_all():
	current_track = Track.NONE
	$TitleMusic.stop()
	$LevelMusic.stop()
	$KaizoMusic.stop()
	
func play_title():
	if (current_track == Track.TITLE):
		return
	current_track = Track.TITLE
	$KaizoMusic.stop()
	$LevelMusic.stop()
	$TitleMusic.play()
	
func play_level():
	if (current_track == Track.LEVEL):
		return
	current_track = Track.LEVEL
	$TitleMusic.stop()
	$KaizoMusic.stop()
	$LevelMusic.play()
	
func play_kaizo():
	if (current_track == Track.KAIZO):
		return
	current_track = Track.KAIZO
	$TitleMusic.stop()
	$LevelMusic.stop()
	$KaizoMusic.play()
