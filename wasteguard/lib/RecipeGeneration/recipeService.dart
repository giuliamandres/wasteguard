import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:wasteguard/RecipeGeneration/recipe.dart';
import 'package:wasteguard/product.dart';

class RecipeService {
  static const apiKey = "AIzaSyA6_mFY1EWqNa8PBsO2DtJ8GR2m0y6T-eE";


  Future<List<Recipe>>? fetchRecipesFromApis(Product product){
    final productName = product.name.split(' ').first;
    final recipes = <Recipe>[];

    final model = GenerativeModel(model: "gemini-1.5-flash-latest", apiKey: apiKey);

    return null;
  }

  Recipe? _parseRecipeFromText(String recipeText){
    List<String> recipes = recipeText.split(RegExp(r'\*\*\d+\.'));
  }
}