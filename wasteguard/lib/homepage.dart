import 'dart:async';
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
import 'package:wasteguard/allTrackedItemsPage.dart';
import 'package:wasteguard/expiringSoonItemsPage.dart';
import 'package:wasteguard/product.dart';
import 'package:wasteguard/scanBarcodePage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wasteguard/scannerProvider.dart';
import 'package:workmanager/workmanager.dart';


class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

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
    try {
      await database.child('products').child(product.id).update({
        'expired': product.expired,
      });
    } catch (error) {
      print("Error updating product in database: $error");
    }
  }

  Future<void> _fetchProducts() async {
    final now = DateTime.now();
    try {
      final snapshot = await database.child('products').get();
      if(snapshot.exists){
        final productList = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _products = productList.entries.map((e) => Product.fromJson(e.value)).toList();
          _isExpiringSoon = _products.any((element) => _isExpiringSoonProduct(element));
        });

      }
      else {
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

  Future<void> _scheduleNotification(Product product) async {
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

      await flutterLocalNotificationsPlugin.show(
          product.name.hashCode,
          '${product.name} is expiring soon!',
          '',
          notificationDetails,
      );
    }
  }

  bool _isExpiringSoonProduct(Product product){
    final now = DateTime.now();
    final expiryThreshold = now.add(const Duration(days: 3));
    return product.expiryDate.isBefore(expiryThreshold) && !product.expired;
  }



  @override
  void dispose() {
    _expiryCheckTimer?.cancel(); // Cancel timer on widget disposal
    super.dispose();
  }

  Future<void> _fetchUsername() async {
    try {
      final userSnapshot = await database.child('users').child(FirebaseAuth.instance.currentUser!.uid).get();

      if(userSnapshot.exists) {
        final userData = userSnapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _username = userData['username'];
        });
      }
    } catch (error) {
      print("Error fetching username: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello, ${_username ?? 'User'}!'),
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
                              Icon(Icons.access_time, size: 50),
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