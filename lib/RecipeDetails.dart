// RecipeDetails.dart
import 'package:flutter/material.dart';
import 'Recipe.dart';
// Replace with actual file name where Recipe model is defined

class RecipeDetailPage extends StatelessWidget {
  final RecipeDetail recipe;

  RecipeDetailPage({Key? key, required this.recipe}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Image.network(recipe.image),
            Text('Used Ingredients (${recipe.usedIngredientCount}):'),
            for (var ingredient in recipe.usedIngredients)
              ListTile(
                leading: Image.network(ingredient.image, width: 50, height: 50),
                title: Text(ingredient.name),
                subtitle: Text('${ingredient.amount} ${ingredient.unit}'),
              ),
            Text('Missed Ingredients (${recipe.missedIngredientCount}):'),
            for (var ingredient in recipe.missedIngredients)
              ListTile(
                leading: Image.network(ingredient.image, width: 50, height: 50),
                title: Text(ingredient.name),
                subtitle: Text('${ingredient.amount} ${ingredient.unit}'),
              ),
            if (recipe.unusedIngredients.isNotEmpty)
              Text('Unused Ingredients:'),
            for (var ingredient in recipe.unusedIngredients)
              ListTile(
                leading: Image.network(ingredient.image, width: 50, height: 50),
                title: Text(ingredient.name),
              ),
            Text('Likes: ${recipe.likes}'),
          ],
        ),
      ),
    );
  }
}

