import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:smartgallery/api/api_service.dart';
import 'package:smartgallery/core/helpers/failure.dart';

class IntersetService {
  final ApiService api;

  IntersetService(this.api);

  Future<Either<Failure, List<String>>> getClassificationTypes() async {
    try {
      dynamic response;

      try {
        response = await api.get(endPoint: '/api/classification/types');
      } catch (typeError) {

        print('Type error caught, trying alternative approach: $typeError');

        return left(
          Failure(
            errMessage:
                'API type mismatch - please check your ApiService implementation. The endpoint returns a List but ApiService expects a Map.',
          ),
        );
      }

      print('Raw classification types response: $response');
      print('Response type: ${response.runtimeType}');

      List<String> types;
      if (response is List) {
        types = List<String>.from(response);
      } else if (response is Map<String, dynamic> &&
          response.containsKey('types')) {
        if (response['types'] is List) {
          types = List<String>.from(response['types']);
        } else {
          return left(
            Failure(
              errMessage: 'Types field is not a list: ${response['types']}',
            ),
          );
        }
      } else {
        return left(
          Failure(
            errMessage:
                'Invalid response format for classification types: $response',
          ),
        );
      }

      print('Parsed classification types: $types');
      return right(types);
    } catch (e) {
      print('Error in getClassificationTypes: $e');
      if (e is DioException) {
        return left(Failure.fromDioException(e));
      } else {
        return left(
          Failure(
            errMessage:
                'Something went wrong while fetching classification types: $e',
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

      print('Raw user classification types response: $response');

      if (response.containsKey('types') && response['types'] is List) {
        List<String> types = List<String>.from(response['types']);
        print('Parsed user classification types: $types');
        return right(types);
      } else {
        return left(
          Failure(
            errMessage:
                'Invalid response format for user classification types: $response',
          ),
        );
      }
    } catch (e) {
      print('Error in getUserClassificationTypes: $e');
      if (e is DioException) {
        return left(Failure.fromDioException(e));
      } else {
        return left(
          Failure(
            errMessage:
                'Something went wrong while fetching user classification types: $e',
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
        body: {'userid': userId, 'classificationName': classificationType},
      );

      print('Insert classification response: $response');

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
      print('Error in insertUserClassification: $e');
      if (e is DioException) {
        return left(Failure.fromDioException(e));
      } else {
        return left(
          Failure(
            errMessage:
                'Something went wrong while inserting classification: $e',
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
        body: {'userid': userId, 'classification_type': classificationType},
      );

      print('Delete classification response: $response');

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
      print('Error in deleteUserClassification: $e');
      if (e is DioException) {
        return left(Failure.fromDioException(e));
      } else {
        return left(
          Failure(
            errMessage:
                'Something went wrong while deleting classification: $e',
          ),
        );
      }
    }
  }
}
