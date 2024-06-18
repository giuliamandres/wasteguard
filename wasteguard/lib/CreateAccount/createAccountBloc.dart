import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wasteguard/CreateAccount/createAccountEvent.dart';
import 'package:wasteguard/CreateAccount/createAccountState.dart';

class CreateAccountBloc extends Bloc<CreateAccountEvent, CreateAccountState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  CreateAccountBloc() : super(CreateAccountInitialState()) {
    on<CreateAccountButtonPressed>((event, emit) async {
      emit(CreateAccountLoading()); // Show loading indicator immediately

      try {
        final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );

        // Wait for user creation to complete
        final user = userCredential.user;
        if (user != null) {
          // Wait for username to be saved to the database
          await _databaseReference
              .child('users')
              .child(user.uid)
              .set({
            'username': event.username,
          });

          emit(CreateAccountSuccess());
        } else {
          emit(CreateAccountFailure(error: 'Failed to create user.'));
        }
      } catch (e) {
        emit(CreateAccountFailure(error: e.toString())); // Use e.toString() for a general exception
      }
    });
  }
}
