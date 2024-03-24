import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'loginEvent.dart';
import 'loginState.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  LoginBloc() : super(LoginInitialState()) {
    on<LoginButtonPressed>((event, emit) async {
      emit(LoginLoading());
      try {
        final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        emit(LoginSuccess());
      } on FirebaseAuthException catch (e) {
        emit(LoginFailure(error: e.message ?? "An unknown error occurred."));
      } catch (e) {
        emit(LoginFailure(error: "An unknown error occurred."));
      }
    });
  }
}
