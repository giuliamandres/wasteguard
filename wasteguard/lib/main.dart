import 'package:firebase_core/firebase_core.dart';
import 'package:wasteguard/RecipeGeneration/recipe.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:wasteguard/Login/login.dart';
import 'package:wasteguard/Login/loginBloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

final recipes = <Recipe>[];

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
    return Recipe(
      id: recipes.length,
      title: title,
      url: "", // Placeholder URL (replace with actual URL parsing)
      ingredients: ingredients, // Replace with parsed ingredients
      instructions: instructions, // Replace with parsed instructions
      duration: 0, // Set default duration (adjust as needed)
    );
  }
  return null;
}

List<String> _parseIngredients(String recipePart){
  final ingredientsStart = recipePart.indexOf("Ingredients:**\n\n");
  final ingredientsEnd = recipePart.indexOf("**Prep", ingredientsStart);
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

void main() async {

  const apiKey = "AIzaSyA6_mFY1EWqNa8PBsO2DtJ8GR2m0y6T-eE";
  final model = GenerativeModel(model: "gemini-1.5-flash-latest", apiKey: apiKey);
  final response = await model.generateContent([
  Content.text("Generate me 5 recipes with contains the ingredient: chicken. the recipes should specify the ingredients, the prep time and the instructions in this order please"),
  ]);
  print(response.text);


  List<String>? recipesText = response.text?.split(RegExp(r'\*\*\d+\.'));
  recipesText = recipesText?.sublist(1);

  for(var recipePart in recipesText!){
    print("EACH RECIPE: $recipePart");
    if(recipePart.isNotEmpty){
      final oneRecipe = _parseRecipeFromSinglePart(recipePart);
      print("ONE RECIPE INFO:\n");
      print(oneRecipe?.title);
      print(oneRecipe?.ingredients);
      print(oneRecipe?.instructions);
      if(oneRecipe != null){
        recipes.add(oneRecipe);
      }
    }
  }



  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => LoginBloc(),
        child: LoginScreen(),
      ),
    );
  }
}


