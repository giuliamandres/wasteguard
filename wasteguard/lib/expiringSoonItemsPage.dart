import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wasteguard/product.dart';
import 'package:wasteguard/productItem.dart';

class ExpiringSoonItemsPage extends StatelessWidget {
  final List<Product> products;

  ExpiringSoonItemsPage({required this.products});

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
    final now = DateTime.now();
    final threshold = now.add(const Duration(days: 2));

    final expiringSoonProducts = products.where((product) {
      return !product.expired && product.expiryDate.isBefore(threshold);
    }).toList();

    return Scaffold(
        appBar: AppBar(title: const Text("Expiring Soon")),
        body: expiringSoonProducts.isEmpty ?
          const Center(child: Text("No items expiring soon."))
          : ListView.builder(
            itemBuilder: (context, index) {
              final Product product = expiringSoonProducts[index];
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
    );
  }
}