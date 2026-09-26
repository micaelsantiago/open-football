class_name CompetitionData
extends RefCounted

var id: String = ""
var name: String = ""
var short_name: String = ""
var country: String = "BR"
var tier: int = 1
var format: String = "ROUND_ROBIN"

var participants: Array = []

var rules: Dictionary = {
	"points_for_win": 3,
	"points_for_draw": 1,
	"points_for_loss": 0,
	"substitutions_allowed": 5,
	"substitutions_windows": 3,
	"tiebreakers": ["POINTS", "WINS", "GOAL_DIFFERENCE", "GOALS_FOR"]
}

var rewards: Dictionary = {
	"champion_prize": 100000,
	"runner_up_prize": 50000,
	"third_place_prize": 25000
}

# Lista de rodadas: [ { "round": 1, "fixtures": [ { "home": id, "away": id, "played": bool, "home_goals": int, "away_goals": int } ] } ]
var season_calendar: Array = []

# Tabela de classificacao: club_id -> { played, won, drawn, lost, goals_for, goals_against, goal_difference, points }
var standings: Dictionary = {}

func init_standings() -> void:
	standings.clear()
	for club_id in participants:
		standings[club_id] = {
			"club_id": club_id,
			"played": 0,
			"won": 0,
			"drawn": 0,
			"lost": 0,
			"goals_for": 0,
			"goals_against": 0,
			"goal_difference": 0,
			"points": 0
		}

func get_fixtures_for_round(round_num: int) -> Array:
	for md in season_calendar:
		if int(md.get("round", 0)) == round_num:
			return md.get("fixtures", [])
	return []

func is_round_completed(round_num: int) -> bool:
	var fixtures = get_fixtures_for_round(round_num)
	if fixtures.is_empty():
		return false
	for fix in fixtures:
		if not fix.get("played", false):
			return false
	return true

func is_season_completed() -> bool:
	if season_calendar.is_empty():
		return false
	for md in season_calendar:
		var fixtures = md.get("fixtures", [])
		for fix in fixtures:
			if not fix.get("played", false):
				return false
	return true

func record_match_result(round_num: int, home_id: String, away_id: String, home_goals: int, away_goals: int) -> void:
	# 1. Atualiza registro no calendario
	var fixtures = get_fixtures_for_round(round_num)
	for fix in fixtures:
		if fix.get("home", "") == home_id and fix.get("away", "") == away_id:
			fix["played"] = true
			fix["home_goals"] = home_goals
			fix["away_goals"] = away_goals
			break
			
	# 2. Garante que os clubes existam na tabela
	if not standings.has(home_id):
		standings[home_id] = {
			"club_id": home_id, "played": 0, "won": 0, "drawn": 0, "lost": 0,
			"goals_for": 0, "goals_against": 0, "goal_difference": 0, "points": 0
		}
	if not standings.has(away_id):
		standings[away_id] = {
			"club_id": away_id, "played": 0, "won": 0, "drawn": 0, "lost": 0,
			"goals_for": 0, "goals_against": 0, "goal_difference": 0, "points": 0
		}
		
	var h: Dictionary = standings[home_id]
	var a: Dictionary = standings[away_id]
	
	h["played"] += 1
	a["played"] += 1
	h["goals_for"] += home_goals
	h["goals_against"] += away_goals
	h["goal_difference"] = h["goals_for"] - h["goals_against"]
	
	a["goals_for"] += away_goals
	a["goals_against"] += home_goals
	a["goal_difference"] = a["goals_for"] - a["goals_against"]
	
	var pts_win: int = rules.get("points_for_win", 3)
	var pts_draw: int = rules.get("points_for_draw", 1)
	var pts_loss: int = rules.get("points_for_loss", 0)
	
	if home_goals > away_goals:
		h["won"] += 1
		h["points"] += pts_win
		a["lost"] += 1
		a["points"] += pts_loss
	elif home_goals == away_goals:
		h["drawn"] += 1
		h["points"] += pts_draw
		a["drawn"] += 1
		a["points"] += pts_draw
	else:
		h["lost"] += 1
		h["points"] += pts_loss
		a["won"] += 1
		a["points"] += pts_win

func get_sorted_standings() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for club_id in standings:
		result.append(standings[club_id].duplicate())
		
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		# 1. Pontos
		if a["points"] != b["points"]:
			return a["points"] > b["points"]
		# 2. Vitorias
		if a["won"] != b["won"]:
			return a["won"] > b["won"]
		# 3. Saldo de gols
		if a["goal_difference"] != b["goal_difference"]:
			return a["goal_difference"] > b["goal_difference"]
		# 4. Gols Pro
		if a["goals_for"] != b["goals_for"]:
			return a["goals_for"] > b["goals_for"]
		# 5. Determinismo alfabetico
		return a["club_id"] < b["club_id"]
	)
	return result

func get_leader_club_id() -> String:
	var sorted_table = get_sorted_standings()
	if sorted_table.is_empty():
		return ""
	return sorted_table[0].get("club_id", "")

static func from_dict(dict: Dictionary) -> CompetitionData:
	var c := CompetitionData.new()
	c.id = str(dict.get("id", ""))
	c.name = str(dict.get("name", ""))
	c.short_name = str(dict.get("short_name", c.name))
	c.country = str(dict.get("country", "BR"))
	c.tier = int(dict.get("tier", 1))
	c.format = str(dict.get("format", "ROUND_ROBIN"))
	
	var part = dict.get("participants", {})
	if typeof(part) == TYPE_DICTIONARY and part.has("clubs"):
		c.participants = Array(part["clubs"], TYPE_STRING, "", null)
	elif typeof(part) == TYPE_ARRAY:
		c.participants = Array(part, TYPE_STRING, "", null)
		
	if dict.has("rules") and typeof(dict["rules"]) == TYPE_DICTIONARY:
		c.rules = dict["rules"].duplicate(true)
		
	if dict.has("rewards") and typeof(dict["rewards"]) == TYPE_DICTIONARY:
		c.rewards = dict["rewards"].duplicate(true)
		
	var cal = dict.get("season_calendar", {})
	if typeof(cal) == TYPE_DICTIONARY and cal.has("match_days"):
		c.season_calendar = []
		for md in cal["match_days"]:
			if typeof(md) == TYPE_DICTIONARY:
				c.season_calendar.append(md.duplicate(true))
	elif typeof(cal) == TYPE_ARRAY:
		c.season_calendar = []
		for md in cal:
			if typeof(md) == TYPE_DICTIONARY:
				c.season_calendar.append(md.duplicate(true))
				
	if dict.has("standings") and typeof(dict["standings"]) == TYPE_DICTIONARY and not dict["standings"].is_empty():
		c.standings = dict["standings"].duplicate(true)
	else:
		c.init_standings()
		
	return c

func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"short_name": short_name,
		"country": country,
		"tier": tier,
		"format": format,
		"participants": {
			"teams_count": participants.size(),
			"clubs": participants
		},
		"rules": rules,
		"rewards": rewards,
		"season_calendar": {
			"match_days": season_calendar
		},
		"standings": standings
	}
