class_name DiscData
extends Resource

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC
}

@export var disc_name = "Lost disc"
@export var rarity = Rarity.COMMON
@export var value = 5


func get_rarity_name() -> String:
	match rarity:
		Rarity.COMMON:
			return "Common"
		Rarity.UNCOMMON:
			return "Uncommon"
		Rarity.RARE:
			return "Rare"
		Rarity.EPIC:
			return "Epic"

	return "Unknown"


func get_rarity_color() -> Color:
	match rarity:
		Rarity.COMMON:
			return Color("#dddddd")
		Rarity.UNCOMMON:
			return Color("#66dd77")
		Rarity.RARE:
			return Color("#66aaff")
		Rarity.EPIC:
			return Color("#cc77ff")

	return Color.WHITE
