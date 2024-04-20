import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wasteguard/Login/loginBloc.dart';
import 'package:wasteguard/Login/loginEvent.dart';
import 'package:wasteguard/Login/loginState.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wasteguard/homepage.dart';


class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(70.0, 200.0, 70.0, 100.0),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: AutoSizeText("WasteGuard", style: TextStyle(fontSize: 33.0, fontWeight: FontWeight.bold, color: Colors.teal), minFontSize:  25.0, maxFontSize: 45, maxLines: 1, overflow: TextOverflow.ellipsis)),
                        SizedBox(width: 5),
                        Icon(Icons.warning_amber_rounded, size: 35.0)
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(7)),
                          child: TextField(
                            controller: emailController,
                            decoration: const InputDecoration(labelText: 'Email'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(7)),
                          child: TextField(
                            controller: passwordController,
                            decoration: const InputDecoration(labelText: 'Password'),
                          ),
                        ),
                        const SizedBox(height: 25),
                        ElevatedButton(onPressed: () {
                          BlocProvider.of<LoginBloc>(context).add(
                              LoginButtonPressed(email: emailController.text, password: passwordController.text)
                          );
                          if(state is LoginSuccess) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => const HomePage()),
                            );
                          }
                          else if(state is LoginFailure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to login. Please check your credentials.'), duration: Duration(seconds: 2))
                            );
                          }
                        },
                            child: const Text('Login')),
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
          )

        );
      }
    );

  }

}