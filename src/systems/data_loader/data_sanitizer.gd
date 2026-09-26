class_name DataSanitizer
extends RefCounted

## Valida e normaliza dados de atletas
static func sanitize_player(raw: Dictionary) -> Dictionary:
	var clean := raw.duplicate(true)
	
	if not clean.has("id") or str(clean["id"]).strip_edges().is_empty():
		clean["id"] = "player-fallback-%d" % Time.get_ticks_usec()
		
	if not clean.has("name") or str(clean["name"]).strip_edges().is_empty():
		clean["name"] = "Jogador Sem Nome"
		
	if not clean.has("common_name"):
		clean["common_name"] = clean["name"]
		
	clean["birth_year"] = int(clean.get("birth_year", 2005))
	clean["nationality"] = str(clean.get("nationality", "BR"))
	
	var pref_foot: String = str(clean.get("preferred_foot", "R")).to_upper()
	if pref_foot not in ["R", "L", "BOTH"]:
		pref_foot = "R"
	clean["preferred_foot"] = pref_foot
	
	# Posições
	if not clean.has("positions") or typeof(clean["positions"]) != TYPE_DICTIONARY:
		clean["positions"] = {"primary": "CM", "secondary": []}
	else:
		var pos_dict: Dictionary = clean["positions"]
		if not pos_dict.has("primary") or str(pos_dict["primary"]).is_empty():
			pos_dict["primary"] = "CM"
		if not pos_dict.has("secondary") or typeof(pos_dict["secondary"]) != TYPE_ARRAY:
			pos_dict["secondary"] = []
			
	# Atributos (Clamping rigoroso 1 a 99)
	if not clean.has("attributes") or typeof(clean["attributes"]) != TYPE_DICTIONARY:
		clean["attributes"] = _generate_fallback_attributes()
	else:
		var attrs: Dictionary = clean["attributes"]
		for category in attrs:
			if typeof(attrs[category]) == TYPE_DICTIONARY:
				for attr_name in attrs[category]:
					var val: int = int(attrs[category][attr_name])
					attrs[category][attr_name] = clampi(val, 1, 99)
					
	# Contrato
	if not clean.has("contract") or typeof(clean["contract"]) != TYPE_DICTIONARY:
		clean["contract"] = {
			"club_id": "free_agent",
			"wage_per_round": 1000,
			"rounds_remaining": 28,
			"release_clause": 50000
		}
		
	# Status
	if not clean.has("status") or typeof(clean["status"]) != TYPE_DICTIONARY:
		clean["status"] = {
			"condition": 100.0,
			"morale": 80.0,
			"injured_rounds_remaining": 0,
			"yellow_cards": 0,
			"is_suspended": false
		}
		
	return clean

## Valida e normaliza dados de clubes
static func sanitize_club(raw: Dictionary) -> Dictionary:
	var clean := raw.duplicate(true)
	
	if not clean.has("id") or str(clean["id"]).strip_edges().is_empty():
		clean["id"] = "club-fallback-%d" % Time.get_ticks_usec()
		
	clean["name"] = str(clean.get("name", "Clube Sem Nome"))
	clean["short_name"] = str(clean.get("short_name", clean["name"].left(10)))
	clean["reputation"] = clampi(int(clean.get("reputation", 50)), 1, 100)
	
	# Cores
	if not clean.has("colors") or typeof(clean["colors"]) != TYPE_DICTIONARY:
		clean["colors"] = {"primary": "#1A4B8C", "secondary": "#FFFFFF", "accent": "#F2B705"}
		
	# Finanças
	if not clean.has("finances") or typeof(clean["finances"]) != TYPE_DICTIONARY:
		clean["finances"] = {
			"balance": 200000,
			"ticket_price": 20,
			"season_tickets": 1000,
			"weekly_sponsor": 7000
		}
		
	# Squad
	if not clean.has("squad") or typeof(clean["squad"]) != TYPE_ARRAY:
		clean["squad"] = []
		
	return clean

## Valida instalações
static func sanitize_facility(raw: Dictionary) -> Dictionary:
	var clean := raw.duplicate(true)
	if not clean.has("id"):
		clean["id"] = "facility-fallback-%d" % Time.get_ticks_usec()
	clean["type"] = str(clean.get("type", "STADIUM"))
	clean["current_level"] = maxi(1, int(clean.get("current_level", 1)))
	if not clean.has("levels") or typeof(clean["levels"]) != TYPE_ARRAY:
		clean["levels"] = []
	return clean

static func _generate_fallback_attributes() -> Dictionary:
	return {
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
