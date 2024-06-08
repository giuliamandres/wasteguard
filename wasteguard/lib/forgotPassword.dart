import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget{
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Password Reset'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your registered email',
                ),
                validator: (value) {
                  if(value == null || value.isEmpty){
                    return 'Please enter your email';
                  }
                  if(!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                  onPressed: () async {
                    if(_formKey.currentState!.validate()) {
                      try {
                        await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password reset email sent!')),
                        );
                        Navigator.of(context).pop();
                      } on FirebaseAuthException catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error.message ?? 'Error sending email'))
                        );
                      }
                    }
                  },
                  child: const Text('Reset Password')
              )
            ],
          ),
        ),
      ),
    );
  }
}