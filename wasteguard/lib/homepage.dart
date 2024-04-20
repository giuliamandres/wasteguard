import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:wasteguard/scanBarcodePage.dart';

class HomePage extends StatelessWidget {

  final String userName = "Giulia";

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello, $userName!'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings))
        ],
      ),
      body: FractionallySizedBox(
        heightFactor: 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              //height: 100,
              child: Card(
                color: Colors.teal.shade100,
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
                    onTap: () {},
                  ),
                ),
              ),
            ),
            Expanded(
              //height: 100,
              child: Card(
                color: Colors.teal.shade100,
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
                    onTap: () {},
                  ),
                ),
              ),
            ),
            Expanded(
              //height: 100,
              child: Card(
                color: Colors.teal.shade100,
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
                    onTap: () {},
                  ),
                ),
              ),
            ),
          ],
        ),
      ),


      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => ScanBarcodePage()));
          if (result != null) {
            print('Scanned barcode: $result');
          }
        },
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }

}