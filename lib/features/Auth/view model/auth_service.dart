import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:smartgallery/api/api_service.dart';
import 'package:smartgallery/core/helpers/failure.dart';

class AuthService {
  final ApiService api;
  String? token;

  AuthService(this.api);

  Future<Either<Failure, Map<String, dynamic>>> login({
    required String username,
    required String password,
  }) async {
    try {
      Map<String, dynamic> response = await api.post(
        endPoint: '/api/auth/login',
        body: {'username': username, 'password': password},
      );
      // token = response['token'];
      return right(response);
    } catch (e) {
      if (e is DioException) {
        return left(Failure.fromDioException(e));
      } else {
        return left(
          Failure(errMessage: 'something went wrong (not DioException)'),
        );
      }
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> register({
    required String username,
    required int age,
    required String password,
  
  }) async {
    try {
      Map<String, dynamic> response = await api.post(
        endPoint: '/api/auth/signup',
        body: {
          "username": username,
          "age": age,
          "password": password,
        },
      );
      // token = response['token'];
      return right(response);
    } catch (e) {
      if (e is DioException) {
        return left(Failure.fromDioException(e));
      }
      return left(
        Failure(errMessage: 'Something went wrong (not DioException)'),
      );
    }
  }
}
