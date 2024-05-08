abstract class CreateAccountState {}

class CreateAccountInitialState extends CreateAccountState {}

class CreateAccountLoading extends CreateAccountState {}

class CreateAccountSuccess extends CreateAccountState {}

class CreateAccountFailure extends CreateAccountState {
  final String error;

  CreateAccountFailure({required this.error});

  @override
  String toString() => 'CreateAccountFailure { error: $error }';
}