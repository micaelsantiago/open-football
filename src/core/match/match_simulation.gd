class_name MatchSimulation
extends RefCounted

const MatchEventClass = preload("res://src/core/match/match_event.gd")
const ClubDataClass = preload("res://src/core/club/club_data.gd")
const PlayerDataClass = preload("res://src/core/player/player_data.gd")

const TOTAL_TICKS: int = 30 # 30 blocos de 3 minutos = 90 minutos
const MINUTES_PER_TICK: int = 3

var home_club: RefCounted
var away_club: RefCounted
var home_players: Array = [] # Array de PlayerData
var away_players: Array = [] # Array de PlayerData
var rng: RandomNumberGenerator

var home_mentality: String = "BALANCED" # "DEFENSIVE", "BALANCED", "OFFENSIVE"
var away_mentality: String = "BALANCED"
var home_bonus: float = 1.08 # +8% de forca para o mandante

# Cache de forcas setoriais base
var home_mid_power: float = 0.0
var home_atk_power: float = 0.0
var home_def_power: float = 0.0
var away_mid_power: float = 0.0
var away_atk_power: float = 0.0
var away_def_power: float = 0.0

# Cache de agrupamentos de atletas
var home_shooters: Array = []
var away_shooters: Array = []
var home_gk: RefCounted = null
var away_gk: RefCounted = null
var home_defenders_mids: Array = []
var away_defenders_mids: Array = []

# Estado da partida
var current_tick: int = 0
var current_minute: int = 0
var is_finished: bool = false

var home_score: int = 0
var away_score: int = 0
var home_shots: int = 0
var home_shots_on_target: int = 0
var away_shots: int = 0
var away_shots_on_target: int = 0
var home_possession_ticks: int = 0
var away_possession_ticks: int = 0

var home_yellow_cards: Dictionary = {} # player_id -> int
var away_yellow_cards: Dictionary = {}
var home_red_cards: Array = []
var away_red_cards: Array = []

var events: Array = []

func _init(p_home_club: RefCounted, p_away_club: RefCounted, p_home_players: Array = [], p_away_players: Array = [], p_rng: RandomNumberGenerator = null) -> void:
	home_club = p_home_club
	away_club = p_away_club
	home_players = p_home_players.duplicate()
	away_players = p_away_players.duplicate()
	
	if p_rng != null:
		rng = p_rng
	else:
		rng = RandomNumberGenerator.new()
		rng.randomize()
		
	if home_club != null and home_club.get("tactics_preset") != null:
		home_mentality = str(home_club.tactics_preset.get("mentality", "BALANCED"))
	if away_club != null and away_club.get("tactics_preset") != null:
		away_mentality = str(away_club.tactics_preset.get("mentality", "BALANCED"))
		
	_recalculate_cached_data()

func _recalculate_cached_data() -> void:
	home_mid_power = calculate_team_sector_power(home_players, "MID")
	home_atk_power = calculate_team_sector_power(home_players, "ATK")
	home_def_power = calculate_team_sector_power(home_players, "DEF")
	away_mid_power = calculate_team_sector_power(away_players, "MID")
	away_atk_power = calculate_team_sector_power(away_players, "ATK")
	away_def_power = calculate_team_sector_power(away_players, "DEF")
	
	home_shooters = _build_shooters_pool(home_players)
	away_shooters = _build_shooters_pool(away_players)
	home_gk = _find_goalkeeper(home_players)
	away_gk = _find_goalkeeper(away_players)
	home_defenders_mids = _build_defenders_pool(home_players)
	away_defenders_mids = _build_defenders_pool(away_players)

func _build_shooters_pool(players: Array) -> Array:
	var pool := []
	for p in players:
		if not p.is_available():
			continue
		var pos = str(p.primary_position)
		if pos in ["ST", "LW", "RW"]:
			pool.append(p)
			pool.append(p)
		elif pos in ["AM", "CM"]:
			pool.append(p)
	if pool.is_empty():
		return [players[0]] if not players.is_empty() else []
	return pool

func _find_goalkeeper(players: Array) -> RefCounted:
	for p in players:
		if str(p.primary_position) == "GK" and p.is_available():
			return p
	return players[0] if not players.is_empty() else null

func _build_defenders_pool(players: Array) -> Array:
	var pool := []
	for p in players:
		if not p.is_available():
			continue
		var pos = str(p.primary_position)
		if pos in ["CB", "LB", "RB", "DM", "CM"]:
			pool.append(p)
	if pool.is_empty():
		return [players[0]] if not players.is_empty() else []
	return pool

func set_home_mentality(mentality: String) -> void:
	home_mentality = mentality

func set_away_mentality(mentality: String) -> void:
	away_mentality = mentality

func get_mentality_multipliers(mentality: String) -> Dictionary:
	match mentality:
		"DEFENSIVE":
			return { "ATK": 0.82, "MID": 0.95, "DEF": 1.20 }
		"OFFENSIVE":
			return { "ATK": 1.20, "MID": 1.05, "DEF": 0.82 }
		_: # BALANCED
			return { "ATK": 1.0, "MID": 1.0, "DEF": 1.0 }

func calculate_team_sector_power(players: Array, sector: String) -> float:
	var total_power := 0.0
	var count := 0
	
	for p in players:
		if not p.is_available():
			continue
		var pos = str(p.primary_position)
		var matches_sector := false
		match sector:
			"GK":
				matches_sector = (pos == "GK")
			"DEF":
				matches_sector = pos in ["CB", "LB", "RB"]
			"MID":
				matches_sector = pos in ["DM", "CM", "AM"]
			"ATK":
				matches_sector = pos in ["LW", "RW", "ST"]
				
		if matches_sector:
			total_power += p.calculate_effective_power(sector)
			count += 1
			
	if count == 0:
		# Fallback se nao houver atletas definidos para a posicao
		return 150.0
	return total_power

func get_home_name() -> String:
	return str(home_club.name) if home_club != null else "Mandante"

func get_away_name() -> String:
	return str(away_club.name) if away_club != null else "Visitante"

func get_home_id() -> String:
	return str(home_club.id) if home_club != null else "home"

func get_away_id() -> String:
	return str(away_club.id) if away_club != null else "away"

## Executa um unico tick de 3 minutos e retorna a lista de novos eventos gerados
func tick() -> Array:
	if is_finished or current_tick >= TOTAL_TICKS:
		return []
		
	current_tick += 1
	current_minute = current_tick * MINUTES_PER_TICK
	var tick_events: Array = []
	
	if current_tick == 1:
		var kickoff_evt = MatchEventClass.create(
			0, MatchEventClass.Type.KICKOFF, "HOME", get_home_id(),
			"0' Apito inicial! Começa o espetáculo do futebol!",
			0, 0
		)
		events.append(kickoff_evt)
		tick_events.append(kickoff_evt)
		
	var home_mult = get_mentality_multipliers(home_mentality)
	var away_mult = get_mentality_multipliers(away_mentality)
	
	var home_pen = maxf(0.5, 1.0 - float(home_red_cards.size()) * 0.15)
	var away_pen = maxf(0.5, 1.0 - float(away_red_cards.size()) * 0.15)
	
	# Forcas setoriais
	var h_mid = home_mid_power * float(home_mult["MID"]) * home_bonus * home_pen
	var a_mid = away_mid_power * float(away_mult["MID"]) * away_pen
	
	# 1. Disputa de posse de bola
	var total_mid = maxf(1.0, h_mid + a_mid)
	var home_prob = clampf(h_mid / total_mid, 0.20, 0.80)
	
	var home_has_ball = (rng.randf() < home_prob)
	if home_has_ball:
		home_possession_ticks += 1
	else:
		away_possession_ticks += 1
		
	# 2. Chance de finalizacao
	var atk_power: float
	var def_power: float
	var attacking_team: String
	var defending_team: String
	var attacking_club_id: String
	var attacking_club_name: String
	var defending_club_name: String
	var attacking_shooters: Array
	var defending_gk: RefCounted
	var defending_mids: Array
	
	if home_has_ball:
		atk_power = home_atk_power * float(home_mult["ATK"]) * home_bonus * home_pen
		def_power = away_def_power * float(away_mult["DEF"]) * away_pen
		attacking_team = "HOME"
		defending_team = "AWAY"
		attacking_club_id = get_home_id()
		attacking_club_name = get_home_name()
		defending_club_name = get_away_name()
		attacking_shooters = home_shooters
		defending_gk = away_gk
		defending_mids = away_defenders_mids
	else:
		atk_power = away_atk_power * float(away_mult["ATK"]) * away_pen
		def_power = home_def_power * float(home_mult["DEF"]) * home_bonus * home_pen
		attacking_team = "AWAY"
		defending_team = "HOME"
		attacking_club_id = get_away_id()
		attacking_club_name = get_away_name()
		defending_club_name = get_home_name()
		attacking_shooters = away_shooters
		defending_gk = home_gk
		defending_mids = home_defenders_mids
		
	var chance_ratio = atk_power / maxf(1.0, atk_power + def_power)
	var chance_prob = clampf(0.27 * (chance_ratio / 0.5), 0.12, 0.44)
	
	if rng.randf() < chance_prob:
		# Lance de perigo / Finalizacao
		if attacking_team == "HOME":
			home_shots += 1
		else:
			away_shots += 1
			
		var shooter = attacking_shooters[rng.randi_range(0, attacking_shooters.size() - 1)] if not attacking_shooters.is_empty() else null
		var shooter_name = shooter.common_name if shooter != null else "Atacante"
		var shooter_id = shooter.id if shooter != null else ""
		var shooter_finishing = shooter.get_attribute("technical", "finishing") if shooter != null else 55
		
		var gk = defending_gk
		var gk_reflexes = gk.get_attribute("goalkeeping", "reflexes") if gk != null else 50
		
		# Cansaco no segundo tempo aumenta levemente as chances de gol
		var time_boost = 1.08 if current_tick > 15 else 1.0
		var duel_prob = (float(shooter_finishing) / (float(shooter_finishing) + float(gk_reflexes) * 1.55)) * time_boost
		duel_prob = clampf(duel_prob, 0.18, 0.44)
		
		var shot_roll = rng.randf()
		if shot_roll < duel_prob:
			# GOL!
			if attacking_team == "HOME":
				home_score += 1
				home_shots_on_target += 1
			else:
				away_score += 1
				away_shots_on_target += 1
				
			var goal_desc = "%d' GOOOOOL DO %s! %s finaliza com maestria e balança a rede adversária!" % [current_minute, attacking_club_name.to_upper(), shooter_name]
			var goal_evt = MatchEventClass.create(
				current_minute, MatchEventClass.Type.GOAL, attacking_team, attacking_club_id,
				goal_desc, home_score, away_score, shooter_id, shooter_name
			)
			events.append(goal_evt)
			tick_events.append(goal_evt)
		elif shot_roll < duel_prob + 0.35:
			# Defesa do goleiro
			if attacking_team == "HOME":
				home_shots_on_target += 1
			else:
				away_shots_on_target += 1
			var gk_name = gk.common_name if gk != null else "Goleiro"
			var save_desc = "%d' Grande defesa de %s! Espalma para escanteio após chute forte de %s." % [current_minute, gk_name, shooter_name]
			var save_evt = MatchEventClass.create(
				current_minute, MatchEventClass.Type.SAVE, defending_team, "",
				save_desc, home_score, away_score, shooter_id, shooter_name
			)
			events.append(save_evt)
			tick_events.append(save_evt)
		elif shot_roll < duel_prob + 0.44:
			# Na trave!
			var wood_desc = "%d' NO POSTE! Chute explosivo de %s carimba a trave de %s!" % [current_minute, shooter_name, defending_club_name]
			var wood_evt = MatchEventClass.create(
				current_minute, MatchEventClass.Type.WOODWORK, attacking_team, attacking_club_id,
				wood_desc, home_score, away_score, shooter_id, shooter_name
			)
			events.append(wood_evt)
			tick_events.append(wood_evt)
		else:
			# Chute para fora
			var miss_desc = "%d' %s recebe em boa condição mas chuta por cima da meta!" % [current_minute, shooter_name]
			var miss_evt = MatchEventClass.create(
				current_minute, MatchEventClass.Type.MISS, attacking_team, attacking_club_id,
				miss_desc, home_score, away_score, shooter_id, shooter_name
			)
			events.append(miss_evt)
			tick_events.append(miss_evt)
			
	# 3. Falta e cartao (probabilidade moderada de ~5%)
	if rng.randf() < 0.05:
		var foul_team = defending_team
		var card_roll = rng.randf()
		if card_roll < 0.25:
			var carded_player = defending_mids[rng.randi_range(0, defending_mids.size() - 1)] if not defending_mids.is_empty() else null
			if carded_player != null:
				var c_id = carded_player.id
				var c_name = carded_player.common_name
				var card_dict = home_yellow_cards if foul_team == "HOME" else away_yellow_cards
				var current_cards = int(card_dict.get(c_id, 0)) + 1
				card_dict[c_id] = current_cards
				
				if current_cards >= 2:
					# Segundo amarelo -> Vermelho
					if foul_team == "HOME":
						home_red_cards.append(c_id)
					else:
						away_red_cards.append(c_id)
					var red_desc = "%d' Segundo amarelo e CARTÃO VERMELHO! %s é expulso de campo!" % [current_minute, c_name]
					var red_evt = MatchEventClass.create(
						current_minute, MatchEventClass.Type.RED_CARD, foul_team, "",
						red_desc, home_score, away_score, c_id, c_name
					)
					events.append(red_evt)
					tick_events.append(red_evt)
				else:
					var yel_desc = "%d' Cartão amarelo para %s por entrada temerária." % [current_minute, c_name]
					var yel_evt = MatchEventClass.create(
						current_minute, MatchEventClass.Type.YELLOW_CARD, foul_team, "",
						yel_desc, home_score, away_score, c_id, c_name
					)
					events.append(yel_evt)
					tick_events.append(yel_evt)
					
	# Eventos de intervalo e fim de jogo
	if current_tick == 15:
		var ht_evt = MatchEventClass.create(
			45, MatchEventClass.Type.HALF_TIME, "HOME", get_home_id(),
			"45' Intervalo de jogo! Placar parcial: %s %d x %d %s" % [get_home_name(), home_score, away_score, get_away_name()],
			home_score, away_score
		)
		events.append(ht_evt)
		tick_events.append(ht_evt)
	elif current_tick == TOTAL_TICKS:
		is_finished = true
		var ft_evt = MatchEventClass.create(
			90, MatchEventClass.Type.FULL_TIME, "HOME", get_home_id(),
			"90' Fim de partida! Resultado final: %s %d x %d %s" % [get_home_name(), home_score, away_score, get_away_name()],
			home_score, away_score
		)
		events.append(ft_evt)
		tick_events.append(ft_evt)
		
	return tick_events

func pick_shooter(players: Array) -> RefCounted:
	var pool = []
	for p in players:
		if not p.is_available():
			continue
		var pos = str(p.primary_position)
		if pos in ["ST", "LW", "RW"]:
			pool.append(p)
			pool.append(p) # Maior peso para atacantes
		elif pos in ["AM", "CM"]:
			pool.append(p)
	if pool.is_empty():
		return players[0] if not players.is_empty() else null
	return pool[rng.randi_range(0, pool.size() - 1)]

func pick_goalkeeper(players: Array) -> RefCounted:
	for p in players:
		if str(p.primary_position) == "GK" and p.is_available():
			return p
	return players[0] if not players.is_empty() else null

func pick_defender_or_mid(players: Array) -> RefCounted:
	var pool = []
	for p in players:
		if not p.is_available():
			continue
		var pos = str(p.primary_position)
		if pos in ["CB", "LB", "RB", "DM", "CM"]:
			pool.append(p)
	if pool.is_empty():
		return players[0] if not players.is_empty() else null
	return pool[rng.randi_range(0, pool.size() - 1)]

func get_possession_percentages() -> Dictionary:
	var total = home_possession_ticks + away_possession_ticks
	if total == 0:
		return { "home": 50, "away": 50 }
	var home_pct = int(round(float(home_possession_ticks) / float(total) * 100.0))
	return { "home": home_pct, "away": 100 - home_pct }

## Simula os 30 ticks da partida instantaneamente em modo headless (< 0.1 ms)
func simulate_full_match() -> Dictionary:
	while not is_finished and current_tick < TOTAL_TICKS:
		tick()
		
	var poss = get_possession_percentages()
	return {
		"home_club_id": get_home_id(),
		"away_club_id": get_away_id(),
		"home_name": get_home_name(),
		"away_name": get_away_name(),
		"home_score": home_score,
		"away_score": away_score,
		"home_shots": home_shots,
		"home_shots_on_target": home_shots_on_target,
		"away_shots": away_shots,
		"away_shots_on_target": away_shots_on_target,
		"home_possession": poss["home"],
		"away_possession": poss["away"],
		"events_count": events.size(),
		"events": events
	}

## Metodo utilitario estatico para simular um jogo a partir do GameState e IDs dos clubes
static func run_instant(game_state: RefCounted, home_id: String, away_id: String, fixture_id: String = "", round_num: int = 1) -> Dictionary:
	var home_c = game_state.get_club(home_id)
	var away_c = game_state.get_club(away_id)
	
	var h_players = []
	if home_c != null:
		for pid in home_c.squad:
			var p = game_state.get_player(pid)
			if p != null:
				h_players.append(p)
				
	var a_players = []
	if away_c != null:
		for pid in away_c.squad:
			var p = game_state.get_player(pid)
			if p != null:
				a_players.append(p)
				
	var match_rng: RandomNumberGenerator
	if not fixture_id.is_empty():
		match_rng = game_state.create_match_rng(fixture_id, round_num)
	else:
		match_rng = game_state.create_match_rng("%s_vs_%s" % [home_id, away_id], round_num)
		
	var sim = MatchSimulation.new(home_c, away_c, h_players, a_players, match_rng)
	return sim.simulate_full_match()
