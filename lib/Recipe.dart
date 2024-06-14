// Import necessary packages
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'RecipeDetails.dart'; // For json decoding

// Define Ingredient model
class IngredientDetail {
  final double amount;
  final String unit;
  final String name;
  final String image;

  IngredientDetail({
    required this.amount,
    required this.unit,
    required this.name,
    required this.image,
  });

  factory IngredientDetail.fromJson(Map<String, dynamic> json) {
    return IngredientDetail(
      amount: json['amount'],
      unit: json['unit'],
      name: json['name'],
      image: json['image'],
    );
  }
}

class RecipeDetail {
  final String title;
  final String image;
  final int usedIngredientCount;
  final int missedIngredientCount;
  final List<IngredientDetail> missedIngredients;
  final List<IngredientDetail> usedIngredients;
  final List<IngredientDetail> unusedIngredients;
  final int likes;

  RecipeDetail({
    required this.title,
    required this.image,
    required this.usedIngredientCount,
    required this.missedIngredientCount,
    required this.missedIngredients,
    required this.usedIngredients,
    required this.unusedIngredients,
    required this.likes,
  });

  factory RecipeDetail.fromJson(Map<String, dynamic> json) {
    return RecipeDetail(
      title: json['title'],
      image: json['image'],
      usedIngredientCount: json['usedIngredientCount'],
      missedIngredientCount: json['missedIngredientCount'],
      missedIngredients: (json['missedIngredients'] as List)
          .map((i) => IngredientDetail.fromJson(i))
          .toList(),
      usedIngredients: (json['usedIngredients'] as List)
          .map((i) => IngredientDetail.fromJson(i))
          .toList(),
      unusedIngredients: (json['unusedIngredients'] as List)
          .map((i) => IngredientDetail.fromJson(i))
          .toList(),
      likes: json['likes'],
    );
  }
}


// RecipeSuggestionsPage widget
class RecipeSuggestionsPage extends StatefulWidget {
  final List<String> ingredients;

  RecipeSuggestionsPage({Key? key, required this.ingredients}) : super(key: key);

  @override
  _RecipeSuggestionsPageState createState() => _RecipeSuggestionsPageState();
}

class _RecipeSuggestionsPageState extends State<RecipeSuggestionsPage> {
  late Future<List<RecipeDetail>> _recipeSuggestions;

  Future<List<RecipeDetail>> fetchRecipeSuggestions() async {
    const apiKey = '1373ee595e9d4e9aa3fc95bc9012f41a'; // Your API key
    final ingredients = widget.ingredients.join(',');
    final url = Uri.parse('https://api.spoonacular.com/recipes/findByIngredients?apiKey=$apiKey&ingredients=$ingredients');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> recipeJson = json.decode(response.body);
      return recipeJson.map((json) => RecipeDetail.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  @override
  void initState() {
    super.initState();
    _recipeSuggestions = fetchRecipeSuggestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Suggestions'),
      ),
      body: FutureBuilder<List<RecipeDetail>>(
        future: _recipeSuggestions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (context, index) {
                final recipe = snapshot.data![index];
                return ListTile(
                  leading: Image.network(recipe.image, width: 100, height: 100, fit: BoxFit.cover),
                  title: Text(recipe.title),
                  subtitle: Text("Missed Ingredients: ${recipe.missedIngredients.length}"),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailPage(recipe: recipe),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            // By default, show a loading spinner
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
