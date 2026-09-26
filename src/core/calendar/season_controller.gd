class_name SeasonController
extends RefCounted

const GameStateClass = preload("res://src/core/state/game_state.gd")
const ClubDataClass = preload("res://src/core/club/club_data.gd")
const FacilityDataClass = preload("res://src/core/facility/facility_data.gd")
const PlayerDataClass = preload("res://src/core/player/player_data.gd")
const CompetitionDataClass = preload("res://src/core/competition/competition_data.gd")

enum RoundPhase {
	PRE_MATCH = 0,
	MATCH_DAY = 1,
	FINANCES = 2,
	FACILITY_TICK = 3,
	RECOVERY = 4,
	SEASON_OVER = 5
}

signal phase_changed(new_phase: RoundPhase, round_num: int)
signal match_day_ready(round_num: int, fixtures: Array)
signal finances_processed(round_num: int, summary: Dictionary)
signal facilities_completed(completed_facilities: Array)
signal round_advanced(new_round: int)
signal season_completed(winner_club_id: String)

var game_state: GameState
var current_phase: RoundPhase = RoundPhase.PRE_MATCH

func _init(state: GameState) -> void:
	game_state = state
	current_phase = RoundPhase.PRE_MATCH

func get_current_round() -> int:
	return game_state.current_round

func get_total_rounds() -> int:
	return game_state.total_rounds

func is_season_finished() -> bool:
	return current_phase == RoundPhase.SEASON_OVER or game_state.current_round > game_state.total_rounds

## 1. Transicao para o dia de jogo (MATCH_DAY)
func advance_to_match_day() -> Array:
	if current_phase != RoundPhase.PRE_MATCH:
		push_warning("advance_to_match_day chamado fora da fase PRE_MATCH")
		return []
		
	current_phase = RoundPhase.MATCH_DAY
	phase_changed.emit(current_phase, game_state.current_round)
	
	var comp = game_state.get_active_competition()
	var fixtures = []
	if comp != null:
		fixtures = comp.get_fixtures_for_round(game_state.current_round)
		
	match_day_ready.emit(game_state.current_round, fixtures)
	return fixtures

## 2. Processa os resultados de todas as partidas da rodada
func record_round_results(results: Array[Dictionary]) -> void:
	if current_phase != RoundPhase.MATCH_DAY:
		push_warning("record_round_results chamado fora da fase MATCH_DAY")
		
	var comp = game_state.get_active_competition()
	if comp != null:
		for res in results:
			var home_id: String = str(res.get("home", ""))
			var away_id: String = str(res.get("away", ""))
			var home_goals: int = int(res.get("home_goals", 0))
			var away_goals: int = int(res.get("away_goals", 0))
			comp.record_match_result(game_state.current_round, home_id, away_id, home_goals, away_goals)
			
	current_phase = RoundPhase.FINANCES
	phase_changed.emit(current_phase, game_state.current_round)

## 3. Calcula bilheteria, salarios semanais e custos de manutencao
func process_finances() -> Dictionary:
	if current_phase != RoundPhase.FINANCES:
		push_warning("process_finances chamado fora da fase FINANCES")
		
	var financial_summary: Dictionary = {}
	var comp = game_state.get_active_competition()
	var round_fixtures = comp.get_fixtures_for_round(game_state.current_round) if comp != null else []
	
	# Mapeia quem jogou em casa nesta rodada
	var home_clubs: Dictionary = {}
	for fix in round_fixtures:
		home_clubs[fix.get("home", "")] = fix.get("away", "")
		
	for club_id in game_state.clubs:
		var club: ClubData = game_state.get_club(club_id)
		if club == null:
			continue
			
		var sponsor: int = int(club.finances.get("weekly_sponsor", 5000))
		var wages: int = game_state.calculate_club_wage_bill(club_id)
		var maintenance: int = 0
		var gate_receipts: int = 0
		var attendance: int = 0
		
		# Calcula manutencao de predios do clube
		for fid in game_state.facilities:
			var fac: FacilityData = game_state.facilities[fid]
			if fac.club_id == club_id:
				maintenance += fac.get_maintenance_cost()
				
		# Se jogou em casa, gera bilheteria
		if home_clubs.has(club_id):
			var stadium_id: String = str(club.facilities.get("stadium_id", ""))
			var stadium: FacilityData = game_state.get_facility(stadium_id)
			var cap: int = stadium.get_current_capacity() if stadium != null else 3000
			
			var ticket_p: int = club.get_ticket_price()
			var price_factor: float = 1.0
			if ticket_p <= 20:
				price_factor = 1.0 + (20.0 - ticket_p) * 0.02
			else:
				price_factor = maxf(0.2, 1.0 - (ticket_p - 20.0) * 0.025)
				
			var rep_factor: float = clampf(float(club.reputation) / 100.0, 0.3, 1.0)
			var demand: float = float(cap) * rep_factor * price_factor
			attendance = clampi(int(demand), int(cap * 0.1), cap)
			gate_receipts = attendance * ticket_p
			
		var net: int = (sponsor + gate_receipts) - (wages + maintenance)
		club.credit(net)
		
		financial_summary[club_id] = {
			"sponsor": sponsor,
			"gate_receipts": gate_receipts,
			"attendance": attendance,
			"wages": wages,
			"maintenance": maintenance,
			"net": net,
			"new_balance": club.get_balance()
		}
		
	finances_processed.emit(game_state.current_round, financial_summary)
	current_phase = RoundPhase.FACILITY_TICK
	phase_changed.emit(current_phase, game_state.current_round)
	return financial_summary

## 4. Avanca as obras em andamento
func process_facility_tick() -> Array:
	if current_phase != RoundPhase.FACILITY_TICK:
		push_warning("process_facility_tick chamado fora da fase FACILITY_TICK")
		
	var completed: Array = []
	for fid in game_state.facilities:
		var fac: FacilityData = game_state.facilities[fid]
		if fac.is_under_construction:
			var was_completed = fac.tick_construction()
			if was_completed:
				completed.append(fac)
				
	facilities_completed.emit(completed)
	current_phase = RoundPhase.RECOVERY
	phase_changed.emit(current_phase, game_state.current_round)
	return completed

## 5. Recuperacao fisica dos atletas e avanco para a proxima rodada
func process_recovery_and_advancement() -> Dictionary:
	if current_phase != RoundPhase.RECOVERY:
		push_warning("process_recovery_and_advancement chamado fora da fase RECOVERY")
		
	for pid in game_state.players:
		var p: PlayerData = game_state.players[pid]
		# Recuperacao de fadiga
		p.condition = clampf(p.condition + 25.0, 0.0, 100.0)
		
		# Recuperacao de lesoes
		if p.injured_rounds_remaining > 0:
			p.injured_rounds_remaining -= 1
			
		# Suspensao
		if p.is_suspended:
			p.is_suspended = false
			p.yellow_cards = 0
			
	# Avanco do contador de rodada
	game_state.current_round += 1
	
	if game_state.current_round > game_state.total_rounds:
		current_phase = RoundPhase.SEASON_OVER
		phase_changed.emit(current_phase, game_state.current_round)
		var comp = game_state.get_active_competition()
		var winner_id = comp.get_leader_club_id() if comp != null else ""
		season_completed.emit(winner_id)
		return { "status": "SEASON_OVER", "winner": winner_id }
	else:
		current_phase = RoundPhase.PRE_MATCH
		phase_changed.emit(current_phase, game_state.current_round)
		round_advanced.emit(game_state.current_round)
		return { "status": "ROUND_ADVANCED", "next_round": game_state.current_round }

## Helper utilitario para simular uma rodada inteira em operacao rapida / testes
func simulate_full_round(fixtures_results: Array[Dictionary] = []) -> Dictionary:
	var fixtures = advance_to_match_day()
	
	var results_to_apply: Array[Dictionary] = []
	if not fixtures_results.is_empty():
		results_to_apply = fixtures_results
	else:
		# Se nao foram passados resultados explicitos, gera placares simples usando RNG deterministico
		for fix in fixtures:
			var h_id = str(fix.get("home", ""))
			var a_id = str(fix.get("away", ""))
			var match_rng = game_state.create_match_rng("%s_vs_%s" % [h_id, a_id], game_state.current_round)
			var h_g = match_rng.randi_range(0, 3)
			var a_g = match_rng.randi_range(0, 2)
			results_to_apply.append({
				"home": h_id,
				"away": a_id,
				"home_goals": h_g,
				"away_goals": a_g
			})
			
	record_round_results(results_to_apply)
	var finances = process_finances()
	var completed_facs = process_facility_tick()
	var adv = process_recovery_and_advancement()
	
	return {
		"results": results_to_apply,
		"finances": finances,
		"completed_facilities": completed_facs,
		"advancement": adv
	}
