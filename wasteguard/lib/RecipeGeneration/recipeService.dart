import 'dart:async';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:wasteguard/RecipeGeneration/recipe.dart';
import 'package:wasteguard/product.dart';

class RecipeService {
  static const apiKey = "AIzaSyA6_mFY1EWqNa8PBsO2DtJ8GR2m0y6T-eE";

  //final recipes = <Recipe>[];
  final List<Recipe> recipes = [];

  Future<List<Recipe>> fetchRecipesFromApis(Product product) async {
    final productName = product.name;


    final model = GenerativeModel(model: "gemini-1.5-flash-latest", apiKey: apiKey);
    final response = await model.generateContent([
      Content.text("Please look into the product $productName. Then generate me 5 recipes which contains the ingredient: $productName. "
          "The recipes should specify the ingredients, the cooking time in minutes and the instructions in this order please"),
    ]);

    List<String>? recipesText = response.text?.split(RegExp(r'\*\*\d+\.'));
    recipesText = recipesText?.sublist(1);

    final parsedRecipes = [];
    for(var recipePart in recipesText!){
      print("EACH RECIPE: $recipePart");
      if(recipePart.isNotEmpty){
        final oneRecipe = _parseRecipeFromSinglePart(recipePart);
        print("ONE RECIPE INFO:\n");
        print(oneRecipe?.title);
        print(oneRecipe?.ingredients);
        print(oneRecipe?.instructions);
        print(oneRecipe?.duration);
        if(oneRecipe != null){
          recipes.add(oneRecipe);
        }
      }
    }
    return recipes;

  }

  Recipe? _parseRecipeFromSinglePart(String recipePart){
    final trimmedPart = recipePart.trim();
    final titleMatch = RegExp(r"^([^*]+)\*\*").firstMatch(trimmedPart);
    print("TITLE MATCH: $titleMatch");
    if (titleMatch != null) {
      final title = titleMatch.group(1)!.trim();
      print("TITLE: $title");
      final ingredients = _parseIngredients(recipePart);
      print("INGREDIENTS: $ingredients");
      final instructions = _parseInstructions(recipePart);
      print("INSTRUCTIONS: $instructions");
      final duration = _parseCookTime(recipePart);
      print("DURATION: $duration minutes");
      return Recipe(
        id: recipes.length,
        title: title,
        url: "", // Placeholder URL (replace with actual URL parsing)
        ingredients: ingredients, // Replace with parsed ingredients
        instructions: instructions, // Replace with parsed instructions
        duration: duration, // Set default duration (adjust as needed)
      );
    }
    return null;
  }

  List<String> _parseIngredients(String recipePart){
    final ingredientsStart = recipePart.indexOf("Ingredients:**\n\n");
    final ingredientsEnd = recipePart.indexOf("Cooking", ingredientsStart);
    List<String> ingredientsList = ingredientsStart != -1 && ingredientsEnd != -1
        ? recipePart.substring(ingredientsStart + "Ingredients:**".length, ingredientsEnd).trim().split("\n")
        : []; // Empty list if not found
    return ingredientsList;
  }

  List<String> _parseInstructions(String recipePart){
    final instructionsStart = recipePart.indexOf("Instructions:**\n\n");
    final List<String> instructionsList = instructionsStart != -1
        ? recipePart.substring(instructionsStart + "Instructions:**".length).trim().split("\n")
        : []; // Empty list if not found
    return instructionsList;
  }

  String _parseCookTime(String recipePart){
    final cookTimeMatch = RegExp(r"\*\*Cooking time:\*\* (\d+)(?:-(\d+))? minutes", caseSensitive: false).firstMatch(recipePart);
    final cookTime = cookTimeMatch?.group(1);
    return cookTime ?? "";
  }


}