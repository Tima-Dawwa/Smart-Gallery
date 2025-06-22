import 'package:dio/dio.dart';
import 'package:smartgallery/core/utils/constants.dart';

class Failure {
  final String? errTitle;
  final dynamic errMessage;
  final DioExceptionType? errType;

  Failure({required this.errMessage, this.errTitle, this.errType});

  factory Failure.fromDioException(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        print('dio exc error is: ${dioException.error.toString()}');
        return Failure(
          errTitle: 'Error',
          errMessage: kInternetMessage,
          errType: dioException.type,
        );

      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
        return Failure(
          errTitle: 'Error',
          errMessage: kWrongMessage,
          errType: dioException.type,
        );

      case DioExceptionType.badResponse:
        return Failure._fromBadResponse(
          dioException.response?.statusCode,
          dioException.response?.data,
          dioException.type,
        );
    }
  }

  factory Failure._fromBadResponse(
    int? statusCode,
    dynamic data,
    DioExceptionType type,
  ) {
    if (data != null && data is Map<String, dynamic>) {
      if (data.containsKey('message')) {
        return Failure(
          errTitle: 'Error',
          errMessage: data['message'],
          errType: type,
        );
      } else if (data.containsKey('errors')) {
        final errors = data['errors'] as Map<String, dynamic>;
        final firstKey = errors.keys.first;
        final firstMessage = (errors[firstKey] as List).first;
        return Failure(
          errTitle: firstKey,
          errMessage: firstMessage,
          errType: type,
        );
      }
    }

    return Failure(
      errTitle: 'Error',
      errMessage: 'Something went wrong',
      errType: type,
    );
  }
}
