import algorithm, strscans, strutils, sets, tables

const NoAllergen = ""

type
  Allergens = HashSet[string]
  Ingredients = HashSet[string]
  Food = tuple[ingredients: Ingredients; allergens: Allergens]

#---------------------------------------------------------------------------------------------------

func firstValue[T](s: HashSet[T]): T =
  ## Return the first value of a HashSet (and the only one of a singleton).
  for value in s:
    return value

#---------------------------------------------------------------------------------------------------

func getIngredientAllergen(foods: seq[Food]): Table[string, string] =
  ## Build the mapping of ingredient to allergen.
  ## Return when each allergen is associated to a single allergen.

  # Initialize the mapping of ingredient to allergen.
  for food in foods:
    for ingredient in food.ingredients:
      result[ingredient] = NoAllergen

  # Build the mapping of allergen to possible ingredients.
  var allergenIngredients: Table[string, Ingredients]
  for (iset, aset) in foods:
    for allergen in aset:
      if allergen in allergenIngredients:
        allergenIngredients[allergen] = allergenIngredients[allergen] * iset
      else:
        allergenIngredients[allergen] = iset

  # Process singletons until each allergen is associated to an ingredient.
  var mappingTerminated = false
  while not mappingTerminated:

    # Search singletons.
    mappingTerminated = true
    var ing, all = ""
    for allergen in allergenIngredients.keys:
      let ingredients = allergenIngredients[allergen]
      if ingredients.card == 1:
        all = allergen
        ing = ingredients.firstValue()

        # Remove "ing" from other sets.
        if result[ing] == NoAllergen:
          # Ingredient not yet assigned to an allergen.
          mappingTerminated = false
          result[ing] = all
          for allergen in allergenIngredients.keys:
            if allergen != all:
              allergenIngredients[allergen].excl(ing)


#———————————————————————————————————————————————————————————————————————————————————————————————————

# Read the data and build the foods description.
var foods: seq[Food]
for line in "data".lines:
  var part1, part2: string
  if line.scanf("$+ (contains $+)$.", part1, part2):
    foods.add((part1.splitWhitespace().toHashSet, part2.split(", ").toHashSet))

# Map ingredients to allergen or NoAllergen.
let ingredientAllergen = foods.getIngredientAllergen()

# Find safe and dangerous ingredients.
var safeIngredients: seq[string]
var dangerousIngredients: seq[string]

for ingredient, allergen in ingredientAllergen.pairs:
  if allergen == NoAllergen:
    safeIngredients.add(ingredient)
  else:
    dangerousIngredients.add(ingredient)

# Count number of times safe ingredients appear in foods.
var count = 0
for ing in safeIngredients:
  for food in foods:
    if ing in food.ingredients:
      inc count

echo "Part 1: ", count

# List the dangerous ingredients sorted alphabetically by their allergen name.
echo "Part 2: ", dangerousIngredients.sortedByIt(ingredientAllergen[it]).join(",")
