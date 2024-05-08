abstract class CreateAccountEvent {}

class CreateAccountButtonPressed extends CreateAccountEvent {
  final String email;
  final String password;

  CreateAccountButtonPressed({required this.email, required this.password});

  @override
  String toString() =>
      'CreateAccountButtonPressed { email: $email, password: $password }';
}