import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wasteguard/RecipeGeneration/recipe.dart';

class RecipePage extends StatefulWidget {

  final Future<List<Recipe>>? recipesList;

  const RecipePage({Key? key, required this.recipesList}) : super(key: key);
  
  @override
  State<RecipePage> createState() => _RecipePageState();
  
}

class _RecipePageState extends State<RecipePage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipes'),
      ),
      body: _buildRecipeList(context),
    );
  }
  
  Widget _buildRecipeList(BuildContext context){
    return FutureBuilder<List<Recipe>>(
        future: widget.recipesList, 
        builder: (context, snapshot) {
          if(snapshot.hasData) {
            final recipes = snapshot.data;
            return ListView.builder(
                itemCount: recipes?.length, 
                itemBuilder: (context, index) {
                  final recipe = recipes?[index];
                  return _buildRecipeCard(context, recipe!);
                },
            );
          } else if(snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return const Center(child: CircularProgressIndicator());
        },
    );
  }
  
  Widget _buildRecipeCard(BuildContext context, Recipe recipe){
    return GestureDetector(
      onTap: () => _showRecipeDetails(recipe),
      child: Card(
        child: ListTile(
          title: Text(recipe.title),
          subtitle: Text('Cooking Time: ${recipe.duration} minutes'),
        ),
      ),
    );
  }
  
  void _showRecipeDetails(Recipe recipe) {
    showDialog(
        context: context, 
        builder: (context) => AlertDialog(
          title: Text(recipe.title),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text('Ingredients: \n'),
                ...recipe.ingredients.map((ingredient) => Text(ingredient)).toList(),
                Text('Cooking Time: ${recipe.duration} minutes'),
                Text('Instructions: \n'),
                ...recipe.instructions.map((instruction) => Text(instruction)).toList(),
              ],
            ),
          ),
        )
    );
  }
}