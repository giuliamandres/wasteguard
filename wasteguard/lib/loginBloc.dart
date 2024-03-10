import 'package:bloc/bloc.dart';
import 'package:wasteguard/login.dart';
import 'package:wasteguard/loginEvent.dart';
import 'package:wasteguard/loginState.dart';


class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitialState());

  Stream<LoginState> mapEventToState(LoginEvent event) async* {
    if(event is LoginButtonPressed) {
      yield LoginLoading();

      try{
        await Future.delayed(Duration(seconds: 2));

        yield LoginSuccess();
      }catch(error) {
        yield LoginFailure(error: 'An error occurred during login');
      }
    }
  }
}
