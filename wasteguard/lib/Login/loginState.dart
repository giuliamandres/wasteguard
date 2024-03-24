abstract class LoginState{
  LoginState();
}

class LoginInitialState extends LoginState{}

class LoginSuccess extends LoginState{}

class LoginLoading extends LoginState{}

class LoginFailure extends LoginState{
  final String error;
  LoginFailure({
    required this.error
  });

  @override
  String toString() => 'LoginFailure { error: $error }';
}