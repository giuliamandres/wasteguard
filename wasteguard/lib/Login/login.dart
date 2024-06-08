import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wasteguard/CreateAccount/createAccount.dart';
import 'package:wasteguard/Login/loginBloc.dart';
import 'package:wasteguard/Login/loginEvent.dart';
import 'package:wasteguard/Login/loginState.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wasteguard/forgotPassword.dart';
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
          backgroundColor: Colors.grey[200],
          body: Stack(
            children: [
              ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 4.0),
                  child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/foodBackground.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.black.withOpacity(0.4),
              ),
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(70.0, 200.0, 70.0, 100.0),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(child: AutoSizeText("Wasteguard", style: TextStyle(fontSize: 33.0, fontWeight: FontWeight.bold, color: Colors.white), minFontSize:  25.0, maxFontSize: 45, maxLines: 1, overflow: TextOverflow.ellipsis)),
                            SizedBox(width: 5),
                            Icon(Icons.warning_amber_rounded, size: 35.0, color: Colors.white,)
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: TextField(
                                controller: emailController,
                                decoration: InputDecoration(labelText: 'Email', filled: true, fillColor: Colors.white.withOpacity(0.8), border: OutlineInputBorder(
                                  borderSide: BorderSide(width: 2.0, color: Colors.black!),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(width: 2.0, color: Colors.black!),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              child: TextField(
                                controller: passwordController,
                                decoration: InputDecoration(labelText: 'Password', filled: true, fillColor: Colors.white.withOpacity(0.8), border: OutlineInputBorder(
                                  borderSide: BorderSide(width: 2.0, color: Colors.black!),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(width: 2.0, color: Colors.black!),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 25),
                            ElevatedButton(
                                onPressed: () {
                                  BlocProvider.of<LoginBloc>(context).add(
                                      LoginButtonPressed(email: emailController.text, password: passwordController.text)
                                  );
                                  if(state is LoginSuccess) {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(builder: (context) => HomePage()),
                                    );
                                  }
                                  else if(state is LoginFailure) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Failed to login. Please check your credentials.'), duration: Duration(seconds: 2))
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade100,
                                ),
                                child: const Text('Login')),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreateAccountScreen()));
                                    },
                                    child: const Text(
                                      'Create Account',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Colors.white
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => ForgotPassword()));
                                      },
                                      child: const Text(
                                        'Forgot Password?',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                          decorationColor: Colors.white,

                                        ),
                                      ),
                                    ))
                              ],
                            )

                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          )

        );
      }
    );

  }

}