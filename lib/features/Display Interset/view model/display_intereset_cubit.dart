import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartgallery/features/Display%20Interset/view%20model/display_interset_service.dart';
import 'package:smartgallery/features/Display%20Interset/view%20model/display_interset_states.dart';


class ClassificationCubit extends Cubit<ClassificationStates> {
  ClassificationCubit(this.classificationService)
    : super(InitialClassificationState());

  final ClassificationService classificationService;

  Future<void> getClassificationTypes() async {
    emit(LoadingClassificationState());

    var response = await classificationService.getClassificationTypes();
    response.fold(
      (failure) {
        emit(ClassificationFailureState(failure: failure));
      },
      (types) {
        print('Classification types loaded: $types');
        emit(ClassificationTypesLoadedState(types: types));
      },
    );
  }

  Future<void> getUserClassificationTypes(int userId) async {
    emit(LoadingClassificationState());

    var response = await classificationService.getUserClassificationTypes(
      userId,
    );
    response.fold(
      (failure) {
        emit(ClassificationFailureState(failure: failure));
      },
      (userTypes) {
        print('User classification types loaded for user $userId: $userTypes');
        emit(UserClassificationTypesLoadedState(userTypes: userTypes));
      },
    );
  }

  Future<void> insertUserClassification({
    required int userId,
    required String classificationType,
  }) async {
    emit(LoadingClassificationState());

    var response = await classificationService.insertUserClassification(
      userId: userId,
      classificationType: classificationType,
    );

    response.fold(
      (failure) {
        emit(ClassificationFailureState(failure: failure));
      },
      (message) {
        print('Classification inserted successfully: $message');
        emit(ClassificationOperationSuccessState(message: message));
        getUserClassificationTypes(userId);
      },
    );
  }

  Future<void> deleteUserClassification({
    required int userId,
    required String classificationType,
  }) async {
    emit(LoadingClassificationState());

    var response = await classificationService.deleteUserClassification(
      userId: userId,
      classificationType: classificationType,
    );

    response.fold(
      (failure) {
        emit(ClassificationFailureState(failure: failure));
      },
      (message) {
        print('Classification deleted successfully: $message');
        emit(ClassificationOperationSuccessState(message: message));
        getUserClassificationTypes(userId);
      },
    );
  }

  void resetToInitial() {
    emit(InitialClassificationState());
  }
}
