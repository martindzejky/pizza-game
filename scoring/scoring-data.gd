extends Resource
class_name ScoringData

# how many ingredients must be on pizza to receive full score for a recipe
@export var requiredIngredients := 0
# how many ingredients must be on pizza to receive full score for a recipe with extra ingredient
@export var requiredExtraIngredients := 0

# easing function for number of ingredients
@export_exp_easing var requiredIngredientsEasing := 0.0
# easing function for number of extra ingredients
@export_exp_easing var requiredExtraIngredientsEasing := 0.0

# how much does ingredient score decrease with each unrequested ingredient
@export var unrequestedIngredientPenalty := 0.0
