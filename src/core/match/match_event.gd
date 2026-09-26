class_name MatchEvent
extends RefCounted

enum Type {
	KICKOFF = 0,
	POSSESSION_TICK = 1,
	ATTACK_OPPORTUNITY = 2,
	GOAL = 3,
	SAVE = 4,
	WOODWORK = 5,
	MISS = 6,
	FOUL = 7,
	YELLOW_CARD = 8,
	RED_CARD = 9,
	INJURY = 10,
	SUBSTITUTION = 11,
	HALF_TIME = 12,
	FULL_TIME = 13
}

var minute: int = 0
var type: Type = Type.POSSESSION_TICK
var team: String = ""       # "HOME" ou "AWAY"
var club_id: String = ""
var player_id: String = ""
var player_name: String = ""
var home_score: int = 0
var away_score: int = 0
var description: String = ""

static func create(
	p_minute: int,
	p_type: Type,
	p_team: String,
	p_club_id: String,
	p_desc: String,
	p_home_score: int = 0,
	p_away_score: int = 0,
	p_player_id: String = "",
	p_player_name: String = ""
) -> MatchEvent:
	var evt := MatchEvent.new()
	evt.minute = p_minute
	evt.type = p_type
	evt.team = p_team
	evt.club_id = p_club_id
	evt.description = p_desc
	evt.home_score = p_home_score
	evt.away_score = p_away_score
	evt.player_id = p_player_id
	evt.player_name = p_player_name
	return evt

func to_dict() -> Dictionary:
	return {
		"minute": minute,
		"type": type,
		"team": team,
		"club_id": club_id,
		"player_id": player_id,
		"player_name": player_name,
		"home_score": home_score,
		"away_score": away_score,
		"description": description
	}
