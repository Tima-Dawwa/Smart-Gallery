import 'package:smartgallery/core/helpers/failure.dart';

abstract class ClassificationStates {}

class InitialClassificationState extends ClassificationStates {}

class LoadingClassificationState extends ClassificationStates {}

class ClassificationTypesLoadedState extends ClassificationStates {
  final List<String> types;

  ClassificationTypesLoadedState({required this.types});
}

class UserClassificationTypesLoadedState extends ClassificationStates {
  final List<String> userTypes;

  UserClassificationTypesLoadedState({required this.userTypes});
}

class ClassificationOperationSuccessState extends ClassificationStates {
  final String message;

  ClassificationOperationSuccessState({required this.message});
}

class ClassificationFailureState extends ClassificationStates {
  final Failure failure;

  ClassificationFailureState({required this.failure});
}
