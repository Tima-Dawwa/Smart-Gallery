import 'package:smartgallery/core/helpers/failure.dart';

abstract class AuthStates {}

class InitialAuthState extends AuthStates {}

class SuccessAuthState extends AuthStates {
  final int userId;
  final String message;

  SuccessAuthState({required this.userId, required this.message});
}

class LoadingAuthState extends AuthStates {}

class FailureAuthState extends AuthStates {
  final Failure failure;
  FailureAuthState({required this.failure});
}
