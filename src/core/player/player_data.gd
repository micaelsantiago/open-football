class_name PlayerData
extends RefCounted

var id: String = ""
var name: String = ""
var common_name: String = ""
var birth_year: int = 2005
var nationality: String = "BR"
var preferred_foot: String = "R"
var primary_position: String = "ST"
var secondary_positions: Array[String] = []

var attributes: Dictionary = {
	"technical": {
		"finishing": 50, "passing": 50, "dribbling": 50,
		"crossing": 50, "tackling": 50, "heading": 50
	},
	"physical": {
		"pace": 50, "acceleration": 50, "stamina": 70, "strength": 50
	},
	"mental": {
		"positioning": 50, "vision": 50, "composure": 50, "work_rate": 70
	},
	"goalkeeping": {
		"reflexes": 10, "handling": 10, "aerial": 10
	}
}

var potential_min: int = 65
var potential_max: int = 75

var club_id: String = "free_agent"
var wage_per_round: int = 1000
var rounds_remaining: int = 28
var release_clause: int = 50000

var condition: float = 100.0
var morale: float = 80.0
var injured_rounds_remaining: int = 0
var yellow_cards: int = 0
var is_suspended: bool = false

func is_available() -> bool:
	return injured_rounds_remaining == 0 and not is_suspended

func get_age(current_year: int = 2026) -> int:
	return current_year - birth_year

func get_attribute(category: String, attr_name: String) -> int:
	if attributes.has(category) and attributes[category].has(attr_name):
		return attributes[category][attr_name]
	return 50

func calculate_overall() -> int:
	var tech: Dictionary = attributes.get("technical", {})
	var phys: Dictionary = attributes.get("physical", {})
	var ment: Dictionary = attributes.get("mental", {})
	var gk: Dictionary = attributes.get("goalkeeping", {})
	
	match primary_position:
		"GK":
			return int((gk.get("reflexes", 10) * 0.45) + (gk.get("handling", 10) * 0.3) + (ment.get("positioning", 50) * 0.25))
		"CB":
			return int((tech.get("tackling", 50) * 0.4) + (ment.get("positioning", 50) * 0.25) + (phys.get("strength", 50) * 0.2) + (phys.get("pace", 50) * 0.15))
		"LB", "RB":
			return int((phys.get("pace", 50) * 0.35) + (tech.get("tackling", 50) * 0.25) + (tech.get("crossing", 50) * 0.2) + (phys.get("stamina", 50) * 0.2))
		"DM":
			return int((tech.get("tackling", 50) * 0.35) + (tech.get("passing", 50) * 0.3) + (phys.get("strength", 50) * 0.2) + (ment.get("work_rate", 50) * 0.15))
		"CM":
			return int((tech.get("passing", 50) * 0.4) + (ment.get("vision", 50) * 0.25) + (tech.get("dribbling", 50) * 0.2) + (phys.get("stamina", 50) * 0.15))
		"AM":
			return int((tech.get("passing", 50) * 0.3) + (ment.get("vision", 50) * 0.3) + (tech.get("dribbling", 50) * 0.25) + (tech.get("finishing", 50) * 0.15))
		"LW", "RW":
			return int((phys.get("pace", 50) * 0.4) + (tech.get("dribbling", 50) * 0.3) + (tech.get("crossing", 50) * 0.15) + (tech.get("finishing", 50) * 0.15))
		"ST":
			return int((tech.get("finishing", 50) * 0.45) + (phys.get("pace", 50) * 0.25) + (ment.get("positioning", 50) * 0.15) + (tech.get("heading", 50) * 0.15))
		_:
			return int((tech.get("passing", 50) * 0.4) + (phys.get("pace", 50) * 0.3) + (tech.get("tackling", 50) * 0.3))

## Calcula a forca efetiva para o calculo da partida levando em conta fadiga e moral
func calculate_effective_power(sector: String) -> float:
	if not is_available():
		return 0.0
		
	var base_score: float = 0.0
	var tech: Dictionary = attributes.get("technical", {})
	var phys: Dictionary = attributes.get("physical", {})
	var ment: Dictionary = attributes.get("mental", {})
	var gk: Dictionary = attributes.get("goalkeeping", {})
	
	match sector:
		"ATK":
			base_score = (tech.get("finishing", 50) * 0.45) + (phys.get("pace", 50) * 0.25) + (ment.get("positioning", 50) * 0.2) + (tech.get("heading", 50) * 0.1)
		"MID":
			base_score = (tech.get("passing", 50) * 0.35) + (ment.get("vision", 50) * 0.25) + (phys.get("stamina", 50) * 0.2) + (tech.get("dribbling", 50) * 0.2)
		"DEF":
			base_score = (tech.get("tackling", 50) * 0.45) + (ment.get("positioning", 50) * 0.25) + (phys.get("strength", 50) * 0.15) + (phys.get("pace", 50) * 0.15)
		"GK":
			base_score = (gk.get("reflexes", 10) * 0.5) + (gk.get("handling", 10) * 0.3) + (ment.get("positioning", 50) * 0.2)
			
	var cond_factor: float = clampf(condition / 100.0, 0.5, 1.0)
	var moral_factor: float = 0.9 + (morale / 100.0) * 0.2
	return base_score * cond_factor * moral_factor

static func from_dict(dict: Dictionary) -> PlayerData:
	var p := PlayerData.new()
	p.id = str(dict.get("id", ""))
	p.name = str(dict.get("name", ""))
	p.common_name = str(dict.get("common_name", p.name))
	p.birth_year = int(dict.get("birth_year", 2005))
	p.nationality = str(dict.get("nationality", "BR"))
	p.preferred_foot = str(dict.get("preferred_foot", "R"))
	
	var pos_data = dict.get("positions", {})
	if typeof(pos_data) == TYPE_DICTIONARY:
		p.primary_position = str(pos_data.get("primary", "ST"))
		p.secondary_positions = Array(pos_data.get("secondary", []), TYPE_STRING, "", null)
		
	if dict.has("attributes") and typeof(dict["attributes"]) == TYPE_DICTIONARY:
		p.attributes = dict["attributes"].duplicate(true)
		
	var pot = dict.get("potential", {})
	if typeof(pot) == TYPE_DICTIONARY:
		p.potential_min = int(pot.get("min", 65))
		p.potential_max = int(pot.get("max", 75))
		
	var contract = dict.get("contract", {})
	if typeof(contract) == TYPE_DICTIONARY:
		p.club_id = str(contract.get("club_id", "free_agent"))
		p.wage_per_round = int(contract.get("wage_per_round", 1000))
		p.rounds_remaining = int(contract.get("rounds_remaining", 28))
		p.release_clause = int(contract.get("release_clause", 50000))
		
	var status = dict.get("status", {})
	if typeof(status) == TYPE_DICTIONARY:
		p.condition = float(status.get("condition", 100.0))
		p.morale = float(status.get("morale", 80.0))
		p.injured_rounds_remaining = int(status.get("injured_rounds_remaining", 0))
		p.yellow_cards = int(status.get("yellow_cards", 0))
		p.is_suspended = bool(status.get("is_suspended", false))
		
	return p

func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"common_name": common_name,
		"birth_year": birth_year,
		"nationality": nationality,
		"preferred_foot": preferred_foot,
		"positions": {
			"primary": primary_position,
			"secondary": secondary_positions
		},
		"attributes": attributes,
		"potential": {
			"min": potential_min,
			"max": potential_max
		},
		"contract": {
			"club_id": club_id,
			"wage_per_round": wage_per_round,
			"rounds_remaining": rounds_remaining,
			"release_clause": release_clause
		},
		"status": {
			"condition": condition,
			"morale": morale,
			"injured_rounds_remaining": injured_rounds_remaining,
			"yellow_cards": yellow_cards,
			"is_suspended": is_suspended
		}
	}
