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

# how long until a dough/ingredient is considered raw
@export var rawTime := 0.0
# how long a dough/ingredient needs to be cooked to be ready (full score)
@export var requiredCookingTime := 0.0
# how long a dough/ingredient needs to be cooked to be overcooked (no score)
@export var overcookedTime := 0.0

# easing between perfect dough and smashed dough
@export_exp_easing("attenuation") var doughEasing := 0.0
# easing between full cooking score and overcooked no score
@export_exp_easing("attenuation") var cookingEasing := 0.0
# easing between perfect ingredient and overcooked ingredient
@export_exp_easing("attenuation") var ingredientEasing := 0.0

# penalty for not including a tomato base
@export var noTomatoBasePenalty := 0.0

# penalty for burning the pizza
@export var overcookedPenalty := 0.0
# penalty for burning an ingredient
@export var overcookedIngredientPenalty := 0.0

# how much ingredient cooking score contributes to total score
@export var ingredientCookingScoreWeight := 0.0
