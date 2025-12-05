-- Part 1 for day 5

SELECT COUNT(DISTINCT ingredient.id)
FROM ingredient
         cross join ingredient_range
WHERE ingredient.id <@ ingredient_range.ingredient_range;