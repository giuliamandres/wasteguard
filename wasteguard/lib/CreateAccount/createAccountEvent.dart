abstract class CreateAccountEvent {}

class CreateAccountButtonPressed extends CreateAccountEvent {
  final String username;
  final String email;
  final String password;

  CreateAccountButtonPressed({required this.username, required this.email, required this.password});

  @override
  String toString() =>
      'CreateAccountButtonPressed {username: $username, email: $email, password: $password }';
}