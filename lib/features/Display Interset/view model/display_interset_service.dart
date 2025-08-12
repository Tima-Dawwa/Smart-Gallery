import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:smartgallery/api/api_service.dart';
import 'package:smartgallery/core/helpers/failure.dart';

class ClassificationService {
  final ApiService api;

  ClassificationService(this.api);

  Future<Either<Failure, List<String>>> getClassificationTypes() async {
    try {
      Map<String, dynamic> response = await api.get(
        endPoint: '/api/classification/types',
      );

      if (response.containsKey('types') && response['types'] is List) {
        List<String> types = List<String>.from(response['types']);
        return right(types);
      } else {
        return left(
          Failure(
            errMessage: 'Invalid response format for classification types',
          ),
        );
      }
    } catch (e) {
      if (e is DioException) {
        return left(Failure.fromDioException(e));
      } else {
        return left(
          Failure(
            errMessage:
                'Something went wrong while fetching classification types',
          ),
        );
      }
    }
  }

  Future<Either<Failure, List<String>>> getUserClassificationTypes(
    int userId,
  ) async {
    try {
      Map<String, dynamic> response = await api.get(
        endPoint: '/api/classification/user-types/$userId',
      );

      if (response.containsKey('types') && response['types'] is List) {
        List<String> types = List<String>.from(response['types']);
        return right(types);
      } else {
        return left(
          Failure(
            errMessage: 'Invalid response format for user classification types',
          ),
        );
      }
    } catch (e) {
      if (e is DioException) {
        return left(Failure.fromDioException(e));
      } else {
        return left(
          Failure(
            errMessage:
                'Something went wrong while fetching user classification types',
          ),
        );
      }
    }
  }

  Future<Either<Failure, String>> insertUserClassification({
    required int userId,
    required String classificationType,
  }) async {
    try {
      Map<String, dynamic> response = await api.post(
        endPoint: '/api/classification/insert_user_classification',
        body: {'user_id': userId, 'classification_type': classificationType},
      );

      if (response.containsKey('message')) {
        return right(response['message']);
      } else {
        return left(
          Failure(
            errMessage: 'Classification insertion failed - no message received',
          ),
        );
      }
    } catch (e) {
      if (e is DioException) {
        return left(Failure.fromDioException(e));
      } else {
        return left(
          Failure(
            errMessage: 'Something went wrong while inserting classification',
          ),
        );
      }
    }
  }

  Future<Either<Failure, String>> deleteUserClassification({
    required int userId,
    required String classificationType,
  }) async {
    try {
      Map<String, dynamic> response = await api.delete(
        endPoint: '/api/classification/delete_user_classification',
        body: {'user_id': userId, 'classification_type': classificationType},
      );

      if (response.containsKey('message')) {
        return right(response['message']);
      } else {
        return left(
          Failure(
            errMessage: 'Classification deletion failed - no message received',
          ),
        );
      }
    } catch (e) {
      if (e is DioException) {
        return left(Failure.fromDioException(e));
      } else {
        return left(
          Failure(
            errMessage: 'Something went wrong while deleting classification',
          ),
        );
      }
    }
  }
}
