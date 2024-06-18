import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:wasteguard/Login/login.dart';
import 'package:wasteguard/allTrackedItemsPage.dart';
import 'package:wasteguard/expiringSoonItemsPage.dart';
import 'package:wasteguard/notificationManager.dart';
import 'package:wasteguard/product.dart';
import 'package:wasteguard/scanBarcodePage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wasteguard/scannerProvider.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomePage extends StatefulWidget {
  final VoidCallback? onSignOut;
  HomePage({Key? key, this.onSignOut}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> _products = [];
  Timer? _backgroundNotificationTimer;
  Timer? _expiryCheckTimer;
  final database = FirebaseDatabase.instance.ref();
  String? _username;
  bool _isExpiringSoon = false;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();

    Workmanager().initialize(
        callbackDispatcher, // Pass the method reference
        isInDebugMode: true
    );
    Workmanager().registerPeriodicTask(
      "be.tramckrijte.workmanagerExample.iOSBackgroundAppRefresh",
      "notificationTask",
      frequency: Duration(minutes: 2),
    );

    _initializeNotifications();
    _fetchProducts().then((_) {
      _checkAndMarkExpiredItems();
    });

    _fetchUsername();
    _backgroundNotificationTimer = Timer(const Duration(minutes: 1), () {
      for (final product in _products.where(_isExpiringSoonProduct)) {
        _scheduleNotification(product);
      }
    });

    _expiryCheckTimer = Timer.periodic(const Duration(days: 1), (timer) {
      _checkAndMarkExpiredItems();
    });
  }



  Future<void> _checkAndMarkExpiredItems() async {
    setState(() {
      for (var product in _products) {
        if (product.expiryDate.isBefore(DateTime.now()) && !product.expired) {
          product.expired = true;
          _updateProductInDatabase(product);
        }
      }
    });
  }

  Future<void> _updateProductInDatabase(Product product) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    try {
      await database.child('users/$userId/products').child(product.id).update({
        'expired': product.expired,
      });
    } catch (error) {
      print("Error updating product in database: $error");
    }
  }

  Future<void> _fetchProducts() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    try {
      final snapshot = await database.child('users/$userId/products').get();
      if(snapshot.exists){
        final productList = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _products = productList.entries.map((e) => Product.fromJson(e.value)).toList();
          _isExpiringSoon = _products.any((element) => _isExpiringSoonProduct(element));
        });
      }
      else {
        setState(() {
          _products = []; // Clear the list if no products are found
        });
        print("No products found");
      }
    } on FirebaseException catch (e) {
      print("Error fetching products: ${e.message}");
    }

  }

  Future<void> _initializeNotifications() async {
    const DarwinInitializationSettings darwinInitializationSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true
    );

    final InitializationSettings initializationSettings = InitializationSettings(iOS: darwinInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
        Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => AllTrackedItemsPage(products: _products.where((element) => _isExpiringSoonProduct(element)).toList()))
        );
      }
    );

  }

  static Future<void> _scheduleNotification(Product product) async {
    final now = DateTime.now();
    final expiryThreshold = now.add(const Duration(days: 3));

    if(product.expiryDate.isBefore(expiryThreshold) && !product.expired) {
      const notificationDetails = NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
        ),
      );

      final plugin = NotificationsManager().flutterLocalNotificationsPlugin;
      await plugin.show(
          product.name.hashCode,
          '${product.name} is expiring soon!',
          '',
          notificationDetails,
      );
    }
  }

  static bool _isExpiringSoonProduct(Product product){
    final now = DateTime.now();
    final expiryThreshold = now.add(const Duration(days: 3));
    return product.expiryDate.isBefore(expiryThreshold) && !product.expired;
  }

  Future<void> _loadProductsFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? productsJson = prefs.getString('products');
    if (productsJson != null) {
      setState(() {
        _products = (json.decode(productsJson) as List<dynamic>) // Decode the JSON string directly
            .map((item) => Product.fromJson(item)) // Convert each item to a Product object
            .toList();
      });
    } else {
      _fetchProducts().then((_) { // Fetch from Firebase if not in SharedPreferences
        _saveProductsToSharedPreferences(); // Save the fetched products immediately
      });
    }
  }

  Future<void> _saveProductsToSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String productsJson = json.encode(_products.map((product) => product.toJson()).toList()); // Encode each product to JSON individually
    await prefs.setString('products', productsJson);
  }

  static void callbackDispatcher() {
    Workmanager().executeTask((taskName, inputData) async {
      if (taskName == "notificationTask") {
        // Load products from SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? productsJson = prefs.getString('products');

        if (productsJson != null) {
          List<Product> products = (json.decode(productsJson) as List<dynamic>)
              .map((item) => Product.fromJson(item))
              .toList();

          // Check and send notifications
          for (final product in products.where(_isExpiringSoonProduct)) {
            await _scheduleNotification(product);
          }

          // Check and mark expired items
          for (var product in products) {
            if (product.expiryDate.isBefore(DateTime.now()) && !product.expired) {
              product.expired = true;
            }
          }

          // Save updated products back to SharedPreferences
          String updatedProductsJson = json.encode(products.map((product) => product.toJson()).toList());
          await prefs.setString('products', updatedProductsJson);
        }

        return Future.value(true); // Indicate success
      }
      return Future.value(false); // Indicate failure
    });
  }

  @override
  void dispose() {
    _expiryCheckTimer?.cancel(); // Cancel timer on widget disposal
    super.dispose();
  }

  Future<void> _fetchUsername() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final userSnapshot = await database.child('users/$userId').get();

      if (userSnapshot.exists && userSnapshot.value != null) {
        final userData = userSnapshot.value as Map<dynamic, dynamic>;
        if (userData.containsKey('username')) { // Check if 'username' exists
          setState(() {
            _username = userData['username'];
          });
        } else {
          // Handle the case where 'username' is not found
          print("Username not found for user.");
          // You can set a default username or display a message to the user here
        }
      } else {
        // Handle the case where user data is not found
        print("User data not found.");
      }
    } catch (error) {
      print("Error fetching username: $error");
      // Handle errors appropriately (e.g., display an error message)
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();

      if (widget.onSignOut != null) {
        widget.onSignOut!(); // Call the callback
      }
      print("User signed out successfully");
    } catch (error) {
      print("Error during sign out: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello, ${_username ?? 'User'}!'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () async {
                await _signOut();
                Navigator.pop(context);
              },
              icon: Icon(Icons.logout)
          )
        ],
      ),
      body: Stack(
        children: [
          FractionallySizedBox(
            heightFactor: 0.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  //height: 100,
                  child: Card(
                    color: Colors.lightGreen.shade100,
                    child: Center(
                      child: ListTile(
                        title: const Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.access_alarm, size: 50),
                              SizedBox(width: 10),
                              Expanded(child: AutoSizeText('Items Expiring Soon',
                                  style: TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold),
                                    minFontSize: 25.0,
                                    maxFontSize: 40,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis))
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => AllTrackedItemsPage(products: _products.where((element) => _isExpiringSoonProduct(element)).toList())));
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  //height: 100,
                  child: Card(
                    color: Colors.lightGreen.shade100,
                    child: Center(
                      child: ListTile(
                        title: const Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.list, size: 50),
                              SizedBox(width: 10),
                              Text('All Tracked Items', style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => AllTrackedItemsPage(products: _products)));
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  //height: 100,
                  child: Card(
                    color: Colors.lightGreen.shade100,
                    child: Center(
                      child: ListTile(
                        title: const Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.warning_outlined, size: 50),
                              SizedBox(width: 10),
                              Text('Expired Items', style: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => AllTrackedItemsPage(products: _products.where((product) => product.expired).toList())));
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => ScanBarcodePage()));

          if (result == true) {
            Provider.of<ScannerProvider>(context, listen: false).startScanning();
          }
        },
        backgroundColor: Colors.grey.shade300,
        child: const Icon(Icons.qr_code_scanner, color: Colors.green),
      ),

      /*floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => ScanBarcodePage()));
          if (result != null) {
            print('Scanned barcode: $result');
          }
        },
        backgroundColor: Colors.grey.shade300,
        child: const Icon(Icons.qr_code_scanner, color: Colors.green),
      ),*/
    );
  }

}