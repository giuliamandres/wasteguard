import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:wasteguard/Login/productDetailsPage.dart';
import 'package:wasteguard/homepage.dart';
import 'package:wasteguard/insertProductNotFound.dart';
import 'package:wasteguard/product.dart';
import 'package:wasteguard/scannerProvider.dart';

class ScanBarcodePage extends StatefulWidget {

  @override
  _ScanBarcodePageState createState() => _ScanBarcodePageState();
}

class _ScanBarcodePageState extends State<ScanBarcodePage> with WidgetsBindingObserver{
  String _scannedBarcode = '';
  bool _isScanning = false;
  MobileScannerController? _scannerController;
  StreamSubscription<String>? _barcodeSubscription;

  bool isTesting = false;
  late ScannerProvider _scannerProvider;

  /*@override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeScanner();
  }*/

  @override
  void initState() {
    super.initState();
    _scannerProvider = Provider.of<ScannerProvider>(context, listen: false);
    WidgetsBinding.instance.addObserver(this);

    // Ensure the scanner is started after the first frame to avoid race conditions
    //WidgetsBinding.instance.addPostFrameCallback((_) {
      //_scannerProvider.startScanning();
    //});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      Provider.of<ScannerProvider>(context, listen: false).startScanning();
    }
  }


  void _initializeScanner() {
    _scannerController = MobileScannerController(facing: CameraFacing.back);
    _isScanning = true;
    _scannerController!.barcodes.listen((event) {
      if(event != null && event.barcodes.isNotEmpty){
        _scannedBarcode = event.barcodes.first.displayValue!;
        _stopScanning();
        _getProductInfo(_scannedBarcode);
      }
    });
  }

  Future<void> _getProductInfo(String barcode) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final database = FirebaseDatabase.instance.ref();

    if(isTesting){
      await Future.delayed(const Duration(milliseconds: 500));
      _showProductNotFoundDialog(context, barcode);
    } else {
      final url = Uri.parse("https://world.openfoodfacts.org/api/v0/product/$barcode.json");
      final response = await http.get(url);

      if(response.statusCode == 200) {
        final productData = await compute(jsonDecode, response.body);
        //final productData = jsonDecode(response.body);

        if(productData['product'] != null && productData['status'] == 1){
          final productName = productData['product']['product_name'];
          final productImageUrl = productData['product']['image_url'] ?? "";
          //await Future.delayed(Duration.zero);

          final newProduct = Product(
            id: barcode, // You might want to use a different ID if barcodes aren't unique
            name: productName,
            userId: userId, // Associate with user
            imageUrl: productImageUrl,
            expiryDate: DateTime.now(),
            // ... other properties
          );
          await database.child('users/$userId/products').child(barcode).set(newProduct.toJson());

          if(mounted){
            await Navigator.push(context, MaterialPageRoute(
                builder: (context) => ProductDetailsPage(
                    product: newProduct
                )));
          }
        } else {
          _showProductNotFoundDialog(context, barcode);
        }
      } else {
        print("Error fetching product data: ${response.statusCode}");
        Navigator.pop(context);
      }
    }
  }

  void _showProductNotFoundDialog(BuildContext context, String barcode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Product Not Found"),
        content: Text("The scanned product was not found in our database. Would you like to add it manually?"),
        actions: [
          TextButton(
            child: const Text("No"),
            onPressed: () => Navigator.of(context).pop(), // Close the dialog
          ),
          TextButton(
            child: const Text("Yes"),
            onPressed: () {
              // Navigate to manual product addition page, passing the barcode
              Navigator.of(context).pop(); // Close the dialog
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => InsertProductNotFound(barcode: barcode)
                  )
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose(){
    //final scannerProvider = Provider.of<ScannerProvider>(context, listen: false);
    //scannerProvider.stopScanning();
    //_scannerController?.dispose();
    //_barcodeSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _startScanning() async {
    if (_scannerController == null) {
      _initializeScanner();
    }
    await _scannerController!.start();
    if (mounted) {
      setState(() => _isScanning = true);
    }
  }

  void _stopScanning() async {
    await _scannerController?.stop();
    if(mounted){
      setState(() => _isScanning = false);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack( // Use Stack to overlay the loading indicator
        children: [
          Consumer<ScannerProvider>(
            builder: (context, scannerProvider, _) {
              return MobileScanner(
                controller: scannerProvider.scannerController!,
                onDetect: (capture) async {
                  final code = capture.barcodes.firstOrNull?.rawValue ?? '';
                  if (code.isNotEmpty) {
                    scannerProvider.stopScanning();
                    setState(() => _isScanning = true); // Show loading
                    await _getProductInfo(code);
                    setState(() => _isScanning = false); // Hide loading
                  }
                },
              );
            },
          ),
          if (_isScanning) // Conditionally show the loading indicator
            Container(
              color: Colors.black.withOpacity(0.5), // Semi-transparent background
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

}