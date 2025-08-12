import 'package:smartgallery/core/helpers/failure.dart';

abstract class IntersetsStates {}

class InitialIntersetsStates extends IntersetsStates {}

class LoadingIntersetsStates extends IntersetsStates {}

class IntersetsLoadedState extends IntersetsStates {
  final List<String> types;

  IntersetsLoadedState({required this.types});
}

class UserClassificationTypesLoadedState extends IntersetsStates {
  final List<String> userTypes;

  UserClassificationTypesLoadedState({required this.userTypes});
}

// New combined state for loading both data sets at once
class AllDataLoadedState extends IntersetsStates {
  final List<String> allTypes;
  final List<String> userTypes;

  AllDataLoadedState({required this.allTypes, required this.userTypes});
}

class ClassificationOperationSuccessState extends IntersetsStates {
  final String message;

  ClassificationOperationSuccessState({required this.message});
}

class ClassificationFailureState extends IntersetsStates {
  final Failure failure;

  ClassificationFailureState({required this.failure});
}
