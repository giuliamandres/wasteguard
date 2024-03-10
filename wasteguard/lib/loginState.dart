abstract class LoginState{
  const LoginState();
}

class LoginInitialState extends LoginState{}

class LoginSuccess extends LoginState{}

class LoginLoading extends LoginState{}

class LoginFailure extends LoginState{
  final String error;
  const LoginFailure({
    required this.error
  });

  @override
  String toString() => 'LoginFailure { error: $error }';
}