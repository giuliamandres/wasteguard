import 'package:flutter/cupertino.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerProvider extends ChangeNotifier {
  MobileScannerController? _scannerController;
  bool _isScanning = false;

  MobileScannerController? get scannerController => _scannerController;
  bool get isScanning => _isScanning;

  // Initialize the scanner controller only once
  ScannerProvider() {
    _scannerController = MobileScannerController();
  }

  @override
  void dispose() {
    stopScanning();
    _scannerController?.dispose(); // Dispose of the controller as well
    super.dispose();
  }

  // Change startScanning to not be async
  void startScanning() {
    if (_isScanning) return;

    _isScanning = true;

    try {
      _scannerController!.start().then((_) {
        notifyListeners();
      });
    } on MobileScannerException catch (e) {
      print("Error starting scanner: $e");
    }
  }

  Future<void> stopScanning() async {
    try {
      await _scannerController?.stop();
    } catch (e) {
      print("Error stopping scanner: $e");
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }
}
