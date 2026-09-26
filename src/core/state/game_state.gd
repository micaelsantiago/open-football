class_name GameState
extends RefCounted

const PlayerDataClass = preload("res://src/core/player/player_data.gd")
const ClubDataClass = preload("res://src/core/club/club_data.gd")
const FacilityDataClass = preload("res://src/core/facility/facility_data.gd")
const CompetitionDataClass = preload("res://src/core/competition/competition_data.gd")

var save_version: int = 1
var career_name: String = "Carreira Inaugural"
var user_club_id: String = "club-aurora-fc"

# Registros relacionais (id -> instancia de dominio)
var clubs: Dictionary = {}         # id -> ClubData
var players: Dictionary = {}       # id -> PlayerData
var facilities: Dictionary = {}    # id -> FacilityData
var competitions: Dictionary = {}  # id -> CompetitionData

# Calendario e tempo
var current_round: int = 1
var total_rounds: int = 14
var current_season: int = 2026
var default_competition_id: String = "comp-liga-inaugural"

# Semente Mestre de RNG
var master_seed: int = 0
var rng: RandomNumberGenerator

func _init(seed_val: int = 0) -> void:
	if seed_val != 0:
		master_seed = seed_val
	else:
		master_seed = int(Time.get_unix_time_from_system())
	rng = RandomNumberGenerator.new()
	rng.seed = master_seed

func get_player(id: String) -> PlayerData:
	return players.get(id, null)

func get_club(id: String) -> ClubData:
	return clubs.get(id, null)

func get_user_club() -> ClubData:
	return get_club(user_club_id)

func get_facility(id: String) -> FacilityData:
	return facilities.get(id, null)

func get_competition(id: String) -> CompetitionData:
	return competitions.get(id, null)

func get_active_competition() -> CompetitionData:
	if competitions.has(default_competition_id):
		return competitions[default_competition_id]
	if not competitions.is_empty():
		return competitions.values()[0]
	return null

## Cria um gerador RNG deterministico unico para cada confronto baseado na semente da carreira
func create_match_rng(fixture_id: String, round_num: int) -> RandomNumberGenerator:
	var match_rng := RandomNumberGenerator.new()
	var derived_seed = (master_seed + fixture_id.hash() + (round_num * 10007)) & 0x7FFFFFFF
	match_rng.seed = derived_seed
	return match_rng

## Calcula a folha salarial por rodada de um clube somando os salarios de todos os seus atletas
func calculate_club_wage_bill(club_id: String) -> int:
	var club: ClubData = get_club(club_id)
	if club == null:
		return 0
	var total_wages := 0
	for pid in club.squad:
		var p: PlayerData = get_player(pid)
		if p != null:
			total_wages += p.wage_per_round
	return total_wages

## Factory que constroi um GameState completo a partir do banco de dados carregado pelo DataLoader
static func create_from_database(db: Dictionary, selected_user_club: String = "club-aurora-fc", seed_val: int = 12345) -> GameState:
	var state := GameState.new(seed_val)
	state.user_club_id = selected_user_club
	
	if db.has("players"):
		for pid in db["players"]:
			state.players[pid] = PlayerDataClass.from_dict(db["players"][pid])
			
	if db.has("clubs"):
		for cid in db["clubs"]:
			state.clubs[cid] = ClubDataClass.from_dict(db["clubs"][cid])
			
	if db.has("facilities"):
		for fid in db["facilities"]:
			state.facilities[fid] = FacilityDataClass.from_dict(db["facilities"][fid])
			
	if db.has("competitions"):
		for comp_id in db["competitions"]:
			state.competitions[comp_id] = CompetitionDataClass.from_dict(db["competitions"][comp_id])
			
	var active_comp = state.get_active_competition()
	if active_comp != null:
		state.total_rounds = active_comp.season_calendar.size()
		
	return state

func to_dict() -> Dictionary:
	var clubs_dict: Dictionary = {}
	for cid in clubs:
		clubs_dict[cid] = clubs[cid].to_dict()
		
	var players_dict: Dictionary = {}
	for pid in players:
		players_dict[pid] = players[pid].to_dict()
		
	var facilities_dict: Dictionary = {}
	for fid in facilities:
		facilities_dict[fid] = facilities[fid].to_dict()
		
	var comps_dict: Dictionary = {}
	for comp_id in competitions:
		comps_dict[comp_id] = competitions[comp_id].to_dict()
		
	return {
		"save_version": save_version,
		"career_name": career_name,
		"user_club_id": user_club_id,
		"current_round": current_round,
		"total_rounds": total_rounds,
		"current_season": current_season,
		"default_competition_id": default_competition_id,
		"master_seed": master_seed,
		"clubs": clubs_dict,
		"players": players_dict,
		"facilities": facilities_dict,
		"competitions": comps_dict
	}

static func from_dict(dict: Dictionary) -> GameState:
	var seed_val = int(dict.get("master_seed", 0))
	var state := GameState.new(seed_val)
	state.save_version = int(dict.get("save_version", 1))
	state.career_name = str(dict.get("career_name", "Carreira"))
	state.user_club_id = str(dict.get("user_club_id", "club-aurora-fc"))
	state.current_round = int(dict.get("current_round", 1))
	state.total_rounds = int(dict.get("total_rounds", 14))
	state.current_season = int(dict.get("current_season", 2026))
	state.default_competition_id = str(dict.get("default_competition_id", "comp-liga-inaugural"))
	
	if dict.has("clubs"):
		for cid in dict["clubs"]:
			state.clubs[cid] = ClubDataClass.from_dict(dict["clubs"][cid])
			
	if dict.has("players"):
		for pid in dict["players"]:
			state.players[pid] = PlayerDataClass.from_dict(dict["players"][pid])
			
	if dict.has("facilities"):
		for fid in dict["facilities"]:
			state.facilities[fid] = FacilityDataClass.from_dict(dict["facilities"][fid])
			
	if dict.has("competitions"):
		for comp_id in dict["competitions"]:
			state.competitions[comp_id] = CompetitionDataClass.from_dict(dict["competitions"][comp_id])
			
	return state
