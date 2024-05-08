import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wasteguard/CreateAccount/createAccountEvent.dart';
import 'package:wasteguard/CreateAccount/createAccountState.dart';

class CreateAccountBloc extends Bloc<CreateAccountEvent, CreateAccountState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  CreateAccountBloc() : super(CreateAccountInitialState()) {
    on<CreateAccountButtonPressed>((event, emit) async {
      emit(CreateAccountLoading());
      try {
        final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(email: event.email, password: event.password);
        emit(CreateAccountSuccess());
      } on FirebaseAuthException catch (e) {
        emit(CreateAccountFailure(error: e.message ?? "An unknown error occurred."));
      } catch (e) {
        emit(CreateAccountFailure(error: "An unknown error occurred."));
      }
    });
  }




}