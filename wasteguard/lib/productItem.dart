import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wasteguard/product.dart';

class ProductItem extends StatelessWidget {
  final Product product;

  const ProductItem({required this.product});

  int get daysRemaining => Duration(milliseconds: DateTime.now().millisecondsSinceEpoch - product.expiryDate.millisecondsSinceEpoch).inDays.abs();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(product.imageUrl),
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
                "Expires in $daysRemaining day${daysRemaining > 1 ? 's' : ''}",
                style: TextStyle(fontSize: 16.0, color: Colors.grey),
              )
            ],
          ))
        ],
      )
    );
  }


}