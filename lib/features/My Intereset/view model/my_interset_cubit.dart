import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartgallery/core/helpers/failure.dart';
import 'package:smartgallery/features/My%20Intereset/view%20model/my_interset_services.dart';
import 'package:smartgallery/features/My%20Intereset/view%20model/my_interset_states.dart';

class IntersetCubit extends Cubit<IntersetsStates> {
  IntersetCubit(this.classificationService) : super(InitialIntersetsStates());

  final IntersetService classificationService;

  // Combined method to load both classification types and user types
  Future<void> loadAllData(int userId) async {
    emit(LoadingIntersetsStates());

    try {
      // Load both classification types and user types concurrently
      final results = await Future.wait([
        classificationService.getClassificationTypes(),
        classificationService.getUserClassificationTypes(userId),
      ]);

      final classificationResult = results[0];
      final userTypesResult = results[1];

      // Check if both calls succeeded
      if (classificationResult.isRight() && userTypesResult.isRight()) {
        final types = classificationResult.getOrElse(() => <String>[]);
        final userTypes = userTypesResult.getOrElse(() => <String>[]);

        print('All data loaded - Types: $types, User Types: $userTypes');
        emit(AllDataLoadedState(allTypes: types, userTypes: userTypes));
      } else {
        // Handle failures
        final failure = classificationResult.fold(
          (failure) => failure,
          (success) =>
              userTypesResult.fold((failure) => failure, (success) => null),
        );

        if (failure != null) {
          emit(ClassificationFailureState(failure: failure));
        }
      }
    } catch (e) {
      emit(
        ClassificationFailureState(
          failure: Failure(errMessage: 'Failed to load data: $e'),
        ),
      );
    }
  }

  Future<void> getClassificationTypes() async {
    emit(LoadingIntersetsStates());

    var response = await classificationService.getClassificationTypes();
    response.fold(
      (failure) {
        emit(ClassificationFailureState(failure: failure));
      },
      (types) {
        print('Classification types loaded: $types');
        emit(IntersetsLoadedState(types: types));
      },
    );
  }

  Future<void> getUserClassificationTypes(int userId) async {
    emit(LoadingIntersetsStates());

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
    // Don't emit loading state for individual operations
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
        // Optionally refresh user types without showing loading
        _refreshUserTypes(userId);
      },
    );
  }

  Future<void> deleteUserClassification({
    required int userId,
    required String classificationType,
  }) async {
    // Don't emit loading state for individual operations
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
        // Optionally refresh user types without showing loading
        _refreshUserTypes(userId);
      },
    );
  }

  // Private method to refresh user types without showing loading state
  Future<void> _refreshUserTypes(int userId) async {
    var response = await classificationService.getUserClassificationTypes(
      userId,
    );
    response.fold(
      (failure) {
        // Silently handle failure or emit specific state
        print('Failed to refresh user types: ${failure.errMessage}');
      },
      (userTypes) {
        print('User types refreshed: $userTypes');
        emit(UserClassificationTypesLoadedState(userTypes: userTypes));
      },
    );
  }

  void resetToInitial() {
    emit(InitialIntersetsStates());
  }
}
