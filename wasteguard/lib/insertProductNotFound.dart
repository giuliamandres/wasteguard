import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:provider/provider.dart';
import 'package:wasteguard/homepage.dart';
import 'package:wasteguard/scannerProvider.dart';

class InsertProductNotFound extends StatefulWidget {
  final String barcode;

  const InsertProductNotFound({Key? key, required this.barcode}) : super(key: key);

  _InsertProductNotFoundState createState() => _InsertProductNotFoundState();
}

class _InsertProductNotFoundState extends State<InsertProductNotFound> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _barcodeController;
  //final _barcodeController = TextEditingController();
  final _productNameController = TextEditingController();
  final _productCategoryController = TextEditingController();
  final _productQuantityController = TextEditingController();
  final _productBrandsController = TextEditingController();
  File? _productImageFile;
  File? _ingredientsImageFile;
  File? _nutritionalValuesImageFile;

  bool isTesting = false;
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source, String imageType) async {
    final imagePicked = await ImagePicker().pickImage(source: source);
    if(imagePicked == null){
      throw Exception("No image available");
    }
    setState(() {
      if (imageType == 'front') {
        _productImageFile = File(imagePicked!.path);
      } else if (imageType == 'ingredients') {
        _ingredientsImageFile = File(imagePicked!.path);
      } else if (imageType == 'nutrition') {
        _nutritionalValuesImageFile = File(imagePicked!.path);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _barcodeController = TextEditingController(text: widget.barcode);
  }

  Future<http.StreamedResponse> _createProductEntry(String barcode, String productName, String category) async {
    var request = http.Request(
      'GET',
      Uri.parse('https://world.openfoodfacts.org/cgi/product_jqm2.pl?code=$barcode&product_name=$productName&categories=$category'),
    );
    
    request.headers.addAll({
      'Authorization': 'Basic ${base64Encode(
          utf8.encode('wasteguard:123456789'))}'
    });
    return await request.send();
  }

  Future<void> _uploadProduct() async {
    setState(() {
      _isUploading = true;
    });
    if(_formKey.currentState!.validate() && isTesting) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully (Mocked)!')),
      );
      Provider.of<ScannerProvider>(context, listen: false).startScanning();
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage()));
    } else {
      if (_formKey.currentState!.validate() &&
          _productImageFile != null &&
          _ingredientsImageFile != null &&
          _nutritionalValuesImageFile != null) {
        try {
          final createProductResponse = await _createProductEntry(_barcodeController.text, _productNameController.text, _productCategoryController.text);
          if(createProductResponse.statusCode == 200){
            await _uploadImage(_productImageFile!, 'front', _barcodeController.text);
            await _uploadImage(_ingredientsImageFile!, 'ingredients', _barcodeController.text);
            await _uploadImage(_nutritionalValuesImageFile!, 'nutrition', _barcodeController.text);

            if(mounted){
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product added successfully!')),
              );
              Provider.of<ScannerProvider>(context, listen: false).startScanning();
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage()));
              //Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage()));
            }
          }
        } catch (error) {
          print('Error: $error');
        } finally {
          setState(() {
            _isUploading = false;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields and select images.')),
        );
      }
    }
  }

  Future<void> _uploadImage(File imageFile, String imageField, String barcode) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://world.openfoodfacts.org/cgi/product_image_upload.pl'),
    );
    request.headers.addAll({
      'Authorization': 'Basic ${base64Encode(utf8.encode('wasteguard:123456789'))}'
    });

    request.fields['code'] = barcode;
    request.fields['imagefield'] = imageField;
    final imageBytes = await imageFile.readAsBytes();

    var multipartFile = http.MultipartFile.fromBytes(
      'imgupload_$imageField',
      imageBytes,
      filename: imageFile.path.split('/').last,
      contentType: MediaType('image', 'jpeg'),
    );
    request.files.add(multipartFile);

    try {
      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print("Image ($imageField) uploaded successfully");
      } else {
        print("Error uploading the $imageField image: ${response.statusCode}");
        print(responseBody);
      }
    } catch (error) {
      throw Exception(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Insert new product')),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: widget.barcode,
                      decoration: InputDecoration(
                        labelText: 'Barcode',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(width: 2.0, color: Colors.black),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        enabledBorder: OutlineInputBorder( // Style for when the field is not focused
                          borderSide: const BorderSide(width: 2.0, color: Colors.black),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder( // Style for when the field is focused
                          borderSide: const BorderSide(width: 2.0, color: Colors.lightGreen), // Example: Teal border on focus
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      readOnly: true,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _productNameController,
                      decoration: InputDecoration(
                        labelText: 'Product Name',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(width: 2.0, color: Colors.black),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        enabledBorder: OutlineInputBorder( // Style for when the field is not focused
                          borderSide: const BorderSide(width: 2.0, color: Colors.black),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder( // Style for when the field is focused
                          borderSide: const BorderSide(width: 2.0, color: Colors.lightGreen), // Example: Teal border on focus
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (value) {
                        if(value == null || value.isEmpty) {
                          return 'Please enter a product name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10,),
                    TextFormField(
                      controller: _productCategoryController,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(width: 2.0, color: Colors.black),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        enabledBorder: OutlineInputBorder( // Style for when the field is not focused
                          borderSide: const BorderSide(width: 2.0, color: Colors.black),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder( // Style for when the field is focused
                          borderSide: const BorderSide(width: 2.0, color: Colors.lightGreen), // Example: Teal border on focus
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      validator: (value) {
                        if(value == null || value.isEmpty) {
                          return 'Please enter a product category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildImagePickerSection('Product', _productImageFile, (source) => _pickImage(source, 'front')),
                    _buildImagePickerSection('Ingredients', _ingredientsImageFile, (source) => _pickImage(source, 'ingredients')),
                    _buildImagePickerSection('Nutritional Values', _nutritionalValuesImageFile, (source) => _pickImage(source, 'nutrition')),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _uploadProduct,
                      child: const Text("Add Product"),
                    )
                  ],
                ),
              ),
            ),
          ),
          if (_isUploading) // Show loading indicator conditionally
            Container(
              color: Colors.black.withOpacity(0.5), // Semi-transparent background
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      )

    );
  }

  Widget _buildImagePickerSection(String title, File? imageFile, Function(ImageSource) onPickImage){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
         ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon( // Use ElevatedButton.icon for label and icon
              onPressed: () => onPickImage(ImageSource.camera),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen.shade200,
                minimumSize: const Size(150, 50), // Make the button wider
                shape: RoundedRectangleBorder( // Add rounded corners
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
              icon: const Icon(Icons.camera_alt, color: Colors.black),
              label: const Text('Camera', style: TextStyle(color: Colors.black)),
            ),
            ElevatedButton.icon(
              onPressed: () => onPickImage(ImageSource.gallery),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen.shade200,
                minimumSize: const Size(150, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
              icon: const Icon(Icons.photo_library, color: Colors.black),
              label: const Text('Gallery', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
        if(imageFile != null) Image.file(imageFile),
        const SizedBox(height: 20),
      ],
    );
  }
}