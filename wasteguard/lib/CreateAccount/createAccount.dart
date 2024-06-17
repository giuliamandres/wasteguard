import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wasteguard/CreateAccount/createAccountEvent.dart';

import 'createAccountBloc.dart';
import 'createAccountState.dart';

class CreateAccountScreen extends StatefulWidget {
  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // For form validation

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateAccountBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Account'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey, // Assign the form key
              child: Column(
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true, // Hide password characters
                  ),
                  const SizedBox(height: 25),
                  BlocBuilder<CreateAccountBloc, CreateAccountState>(
                    builder: (context, state) {
                      if (state is CreateAccountLoading) {
                        return const CircularProgressIndicator(); // Show loading indicator
                      }
                      return ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) { // Validate form before submitting
                            BlocProvider.of<CreateAccountBloc>(context).add(
                              CreateAccountButtonPressed(
                                username: _usernameController.text,
                                email: _emailController.text,
                                password: _passwordController.text,
                              ),
                            );
                          }
                        },
                        child: const Text('Create Account'),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  BlocListener<CreateAccountBloc, CreateAccountState>(
                    listener: (context, state) {
                      if (state is CreateAccountSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Account successfully created!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        // Handle successful account creation (e.g., navigate to homepage)
                        Navigator.of(context).pop(); // Close CreateAccountScreen
                      } else if (state is CreateAccountFailure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to create account: ${state.error}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: const SizedBox(), // Required child, can be empty
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
