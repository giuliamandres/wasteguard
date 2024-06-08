import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:wasteguard/Login/productDetailsPage.dart';
import 'package:wasteguard/homepage.dart';

class ScanBarcodePage extends StatefulWidget {
  
  @override
  _ScanBarcodePageState createState() => _ScanBarcodePageState();
}

class _ScanBarcodePageState extends State<ScanBarcodePage>{
  String _scannedBarcode = '';
  bool _isScanning = false;
  final MobileScannerController _scannerController = MobileScannerController(autoStart: true);

  @override
  void initState(){
    super.initState();
    _scannerController.barcodes.listen((event) {
      if(event != null && event.barcodes.isNotEmpty){
        _scannedBarcode = event.barcodes.first.displayValue!;
        _stopScanning();
        _getProductInfo(_scannedBarcode);
      }
    });
  }

  Future<void> _getProductInfo(String barcode) async {
    final url = Uri.parse("https://world.openfoodfacts.org/api/v0/product/$barcode.json");
    final response = await http.get(url);
    if(response.statusCode == 200) {
      final productData = jsonDecode(response.body);

      if(productData != null){
        final productName = productData['product']['product_name'];
        final productImageUrl = productData['product']['image_url'] ?? "";
        await Navigator.push(context, MaterialPageRoute(
            builder: (context) => ProductDetailsPage(
                productName: productName,
                productImageUrl: productImageUrl
            )
        ));
      } else {
        _showProductNotFoundDialog(context, barcode);
      }
    } else {
      print("Error fetching product data: ${response.statusCode}");
      Navigator.pop(context);
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
                      builder: (context) => HomePage()
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
    _scannerController.dispose();
    super.dispose();
  }

  void _startScanning() async {
    await _scannerController.start();
    setState(() => _isScanning = true);
  }

  void _stopScanning() async {
    await _scannerController.stop();
    setState(() => _isScanning = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: (barcode) {
              if(barcode != null){
                final code = barcode.raw;
              }
            },
          ),
          Builder(builder: (context) => _isScanning ? Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(child: CircularProgressIndicator()),
          ) : Container(),
          )
        ],
      ),
    );
  }

  
}