class_name ClubData
extends RefCounted

var id: String = ""
var name: String = ""
var short_name: String = ""
var nickname: String = ""
var founded_year: int = 1924
var country: String = "BR"
var city: String = "Serra Alta"
var reputation: int = 50

var colors: Dictionary = {
	"primary": "#1A4B8C",
	"secondary": "#FFFFFF",
	"accent": "#F2B705"
}

var facilities: Dictionary = {
	"stadium_id": "",
	"training_center_id": "",
	"headquarters_id": ""
}

var finances: Dictionary = {
	"balance": 200000,
	"ticket_price": 20,
	"season_tickets": 1000,
	"weekly_sponsor": 7000
}

var squad: Array[String] = []

var tactics_preset: Dictionary = {
	"formation": "4-4-2",
	"mentality": "BALANCED",
	"aggression": "NORMAL",
	"starting_eleven": [],
	"substitutes": []
}

func get_balance() -> int:
	return int(finances.get("balance", 0))

func can_afford(amount: int) -> bool:
	return get_balance() >= amount

func debit(amount: int) -> bool:
	if not can_afford(amount):
		return false
	finances["balance"] = get_balance() - amount
	return true

func credit(amount: int) -> void:
	finances["balance"] = get_balance() + amount

func get_ticket_price() -> int:
	return int(finances.get("ticket_price", 20))

func set_ticket_price(price: int) -> void:
	finances["ticket_price"] = clampi(price, 5, 200)

func get_primary_color() -> Color:
	return Color.from_string(colors.get("primary", "#1A4B8C"), Color.BLUE)

func get_secondary_color() -> Color:
	return Color.from_string(colors.get("secondary", "#FFFFFF"), Color.WHITE)

static func from_dict(dict: Dictionary) -> ClubData:
	var c := ClubData.new()
	c.id = str(dict.get("id", ""))
	c.name = str(dict.get("name", ""))
	c.short_name = str(dict.get("short_name", c.name))
	c.nickname = str(dict.get("nickname", ""))
	c.founded_year = int(dict.get("founded_year", 1924))
	c.country = str(dict.get("country", "BR"))
	c.city = str(dict.get("city", ""))
	c.reputation = int(dict.get("reputation", 50))
	
	if dict.has("colors") and typeof(dict["colors"]) == TYPE_DICTIONARY:
		c.colors = dict["colors"].duplicate(true)
		
	if dict.has("facilities") and typeof(dict["facilities"]) == TYPE_DICTIONARY:
		c.facilities = dict["facilities"].duplicate(true)
		
	if dict.has("finances") and typeof(dict["finances"]) == TYPE_DICTIONARY:
		c.finances = dict["finances"].duplicate(true)
		
	if dict.has("squad") and typeof(dict["squad"]) == TYPE_ARRAY:
		c.squad = Array(dict["squad"], TYPE_STRING, "", null)
		
	if dict.has("tactics_preset") and typeof(dict["tactics_preset"]) == TYPE_DICTIONARY:
		c.tactics_preset = dict["tactics_preset"].duplicate(true)
		
	return c

func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"short_name": short_name,
		"nickname": nickname,
		"founded_year": founded_year,
		"country": country,
		"city": city,
		"reputation": reputation,
		"colors": colors,
		"facilities": facilities,
		"finances": finances,
		"squad": squad,
		"tactics_preset": tactics_preset
	}
