import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wasteguard/RecipeGeneration/recipe.dart';
import 'package:wasteguard/RecipeGeneration/recipePage.dart';
import 'package:wasteguard/RecipeGeneration/recipeService.dart';
import 'package:wasteguard/product.dart';

class ProductItem extends StatelessWidget {
  final Product product;

  const ProductItem({required this.product});

  int get daysRemaining => Duration(milliseconds: DateTime.now().millisecondsSinceEpoch - product.expiryDate.millisecondsSinceEpoch).inDays.abs();

  @override
  Widget build(BuildContext context) {
    String? imageUrl = product.imageUrl;

    if(imageUrl.isEmpty || imageUrl == ""){
      imageUrl = 'assets/placeholder.png';
    }
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          imageUrl.startsWith('assets/') ?
              CircleAvatar(backgroundImage: AssetImage(imageUrl)) :
              CircleAvatar(
                backgroundImage: NetworkImage(imageUrl),
              ),
          SizedBox(width: 16.0),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              Text(
                product.expired
                ? "Expired"
                : "Expires in $daysRemaining day${daysRemaining > 1 ? 's' : ''}",
                style: TextStyle(fontSize: 16.0, color: Colors.grey),
              ),
            ],
          )),
          IconButton(
            onPressed: () async {
              final recipeService = RecipeService();
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Center(child: CircularProgressIndicator())
              );
              try {
                final recipes = await recipeService.fetchRecipesFromApis(product);
                Navigator.pop(context);

                if(recipes != null){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => RecipePage(recipesList: Future.value(recipes))));
                } else {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('An error occurred while fetching recipes. Please try again later.'),
                    ),
                  );
                }
              } catch(error) {
                Navigator.pop(context); // Close the dialog
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('An error occurred: $error'),
                    ),
                );
              }



            },
            icon: const Icon(Icons.restaurant_outlined),
          )
        ],
      )
    );
  }


}