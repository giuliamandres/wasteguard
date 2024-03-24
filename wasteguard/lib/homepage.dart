import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class HomePage extends StatelessWidget {

  final String userName = "Giulia";

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello, $userName!'),
        actions: [
          IconButton(onPressed: (){}, icon: const Icon(Icons.settings))
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
                color: Colors.tealAccent[100],
                child: Center(
                  child: ListTile(
                    title: const Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.access_alarm, size: 50),
                          SizedBox(width: 10),
                          Text('Items Expiring Soon', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
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
                color: Colors.tealAccent[100],
                child: Center(
                  child: ListTile(
                    title: const Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.list, size: 50),
                          SizedBox(width: 10),
                          Text('All Tracked Items', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
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
                color: Colors.tealAccent[100],
                child: Center(
                  child: ListTile(
                    title: const Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.access_time, size: 50),
                          SizedBox(width: 10),
                          Text('Expired Items', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
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
        onPressed: (){},
        child: const Icon(Icons.add),
      ),
    );
  }

}