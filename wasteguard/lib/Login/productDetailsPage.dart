import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wasteguard/homepage.dart';
import 'package:wasteguard/product.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productName;
  final String productImageUrl;

  const ProductDetailsPage({
    required this.productName,
    required this.productImageUrl
});

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  DateTime _selectedExpiryDate = DateTime.now();
  String _timeRemaining = '';
  bool _isNavigating = false;

  void _calculateTimeRemaining(){
    final now = DateTime.now();
    final difference = _selectedExpiryDate.difference(now);
    if(difference.inDays > 0){
      final days = difference.inDays;
      _timeRemaining = days == 1 ? "$days day remaining" : "$days days remaining";
    } else if (difference.inHours > 0){
      final hours = difference.inHours;
      _timeRemaining = hours == 1 ? "$hours hour remaining" : "$hours hours remaining";
    } else {
      _timeRemaining = "Expired";
    }
  }

  @override
  void initState(){
    super.initState();
    _calculateTimeRemaining();
  }

  Future<void> saveProductToFirebase(Product product) async {
    final database = FirebaseDatabase.instance;
    final reference = database.ref().child('products').push();
    product.id = reference.key!;
    await reference.set(product.toJson());

  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
        onPopInvoked: (didPop) async {
          if(didPop && !_isNavigating) {
            _isNavigating = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => HomePage()),
                      (route) => route.isFirst
              );
              _isNavigating = false;
            });
          }
        },
        child: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SizedBox(height: 20.0),
                  widget.productImageUrl.isNotEmpty ? Image.network(widget.productImageUrl) : Container(
                    height: 200,
                    child: const Center(
                      child: Text("No product image available"),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    widget.productName,
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Text("Expiry date: ", style: TextStyle(fontSize: 18.0)),
                      Spacer(),
                      Text(DateFormat('y-MM-d').format(_selectedExpiryDate)),
                      IconButton(
                        onPressed: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: _selectedExpiryDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if(selectedDate != null){
                            setState(() {
                              _selectedExpiryDate = selectedDate;
                              _calculateTimeRemaining();
                            });
                          }
                        },
                        icon: Icon(Icons.calendar_today),
                      )
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Text("Time remaining: $_timeRemaining", style: TextStyle(fontSize: 18)),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                      onPressed: () async {
                        final database = FirebaseDatabase.instance;
                        final reference = database.ref().child('products').push();
                        final String id = reference.key!;
                        final product = Product(
                            id: id,
                            name: widget.productName,
                            imageUrl: widget.productImageUrl,
                            expiryDate: _selectedExpiryDate
                        );
                        try{
                          await saveProductToFirebase(product);
                          if(mounted){
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Product saved successfully!'),
                                  action: SnackBarAction(
                                    label: 'OK',
                                    onPressed: () {
                                      _isNavigating = true;
                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => HomePage()), (route) => route.isFirst);
                                        _isNavigating = false;
                                      });
                                    },
                                  ),
                                )
                            );
                          }
                        } catch (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to save product: $error'),
                                action: SnackBarAction(
                                  label: 'OK',
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                                  },
                                ),
                              )
                          );
                        }
                      },
                      child: Text("Save")),
                ],
              ),
            ),
          ),
        ),
    );
  }
}