class_name EventBusSingleton
extends Node

static var _instance: EventBusSingleton

# --- Eventos de Economia e Finanças ---
signal balance_changed(new_balance: int, delta: int)
signal wage_paid(total_wages: int)

# --- Eventos de Instalações / Mundo ---
signal facility_selected(facility_id: String)
signal facility_upgrade_started(facility_id: String, target_level: int)
signal facility_upgrade_completed(facility_id: String, new_level: int)

# --- Eventos da Partida ---
signal match_tick_advanced(minute: int)
signal match_goal_scored(goal_event: Dictionary)
signal match_card_shown(card_event: Dictionary)
signal match_ended(result: Dictionary)

# --- Eventos de Calendário e Temporada ---
signal round_started(round_number: int)
signal round_ended(round_number: int)
signal season_ended(champion_club_id: String)

# --- Eventos de UI e Notificações ---
signal toast_requested(message: String, type: String) # "INFO", "SUCCESS", "WARNING", "ERROR"
signal modal_opened(modal_name: String)
signal modal_closed(modal_name: String)

func _init() -> void:
	if _instance == null:
		_instance = self

static func get_instance() -> EventBusSingleton:
	if _instance == null:
		_instance = EventBusSingleton.new()
	return _instance
