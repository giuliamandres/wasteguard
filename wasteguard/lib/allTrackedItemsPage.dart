import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wasteguard/product.dart';
import 'package:wasteguard/productItem.dart';

class AllTrackedItemsPage extends StatelessWidget {
  final List<Product> products;
  
  AllTrackedItemsPage({required this.products});

  Future<void> _deleteProductFromDatabase(Product product) async {
    try {
      final database = FirebaseDatabase.instance;
      final productRef = database.ref().child('products');
      await productRef.child(product.id).remove();
    } catch (error) {
      print("Error deleting product from database: $error");
      throw error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          Stack(
            children: [
              ListView.builder(
                itemBuilder: (context, index) {
                  final Product product = products[index];
                  return Dismissible(
                      key: Key(product.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) async {
                        final removedProduct = products.removeAt(index);

                        try{
                          await _deleteProductFromDatabase(removedProduct);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${product.name} dismissed"),
                            ),
                          );
                        } catch (error) {
                          print("Error deleting product: $error");
                          products.insert(index, removedProduct);
                        }

                      },
                      child: ProductItem(product: product,)
                  );
                },
                itemCount: products.length,
              )
            ],
          )

    );
  }
}