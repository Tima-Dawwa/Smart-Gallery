import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:smartgallery/core/helpers/api_service.dart';
import 'package:smartgallery/core/helpers/failure.dart';

import 'package:smartgallery/features/Auth/model/repos/auth_repo.dart';

class AuthRepoImpl extends AuthRepo {
  final ApiService apiService;
  String? token;

  AuthRepoImpl(this.apiService);

  @override
  Future<Either<Failure, Map<String, dynamic>>> login({
    required String name,
    required String password,
  }) async {
    try {
      final response = await apiService.post(
        endPoint: '/auth/login',
        body: {'name': name, 'password': password},
      );
      token = response['token'];
      return right(response);
    } catch (e) {
      if (e is DioException) {
        return left(Failure.fromDioException(e));
      } else {
        return left(Failure(errMessage: 'Something went wrong'));
      }
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> register({
    required String name,
    required int age,
    required String password,
  }) async {
    try {
      final response = await apiService.post(
        endPoint: '/auth/register',
        body: {
          "first_name": name,
          "age": age,
          "password": password,
        },
      );
      return right(response);
    } catch (e) {
      if (e is DioException) {
        return left(Failure.fromDioException(e));
      } else {
        return left(Failure(errMessage: 'Something went wrong'));
      }
    }
  }

 

  @override
  Future<Either<Failure, Map<String, dynamic>>> getProfileData({
    required String token,
  }) async {
    try {
      final response = await apiService.get(
        endPoint: '/users/profile',
        headers: {"Authorization": 'Bearer $token'},
      );
      return right(response);
    } catch (e) {
      if (e is DioException) {
        return left(Failure.fromDioException(e));
      } else {
        return left(Failure(errMessage: 'Something went wrong'));
      }
    }
  }
}
