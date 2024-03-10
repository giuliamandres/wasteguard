import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wasteguard/loginBloc.dart';
import 'package:wasteguard/loginState.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return Scaffold(
          body: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(70.0, 200.0, 70.0, 100.0),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(child: Text('WasteGuard', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.teal))),
                      SizedBox(width: 5),
                      Icon(Icons.warning_amber_rounded, size: 35.0)
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(7)),
                        child: const TextField(
                          decoration: InputDecoration(labelText: 'Email'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(7)),
                        child: const TextField(
                          decoration: InputDecoration(labelText: 'Password'),
                        ),
                      ),
                      const SizedBox(height: 25),
                      ElevatedButton(onPressed: () {}, child: const Text('Login')),
                      const SizedBox(height: 16),
                      Text.rich(
                          TextSpan(
                              children: [
                                TextSpan(text: 'Create Account', style: TextStyle(color: Colors.teal.shade800, fontWeight: FontWeight.bold)),
                                const WidgetSpan(child: SizedBox(width: 40)),
                                TextSpan(text: 'Forgot Password?', style: TextStyle(color: Colors.teal.shade800, fontWeight: FontWeight.bold))
                              ]
                          )
                      )

                    ],
                  ),
                )
              ]
          ),
        );
      }
    );

  }

}