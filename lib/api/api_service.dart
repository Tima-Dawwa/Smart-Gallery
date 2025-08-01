

import 'package:dio/dio.dart';
import 'package:smartgallery/core/helpers/service_locator.dart';
import 'package:smartgallery/features/Auth/model/repos/auth_repos_impl.dart';

class ApiService {
  // final String baseUrl = 'http://10.0.2.2:5000';
  final String baseUrl = 'https://c75d-5-0-163-131.ngrok-free.app';
  final Dio _dio;

  // final String token =
  //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjBkOTVhMjZmZjk4NWY2ZWUxYzBjNjkwZiIsIm5hbWUiOnsiZmlyc3RfbmFtZSI6IkRhdm9udGUiLCJsYXN0X25hbWUiOiJSb29iIn0sImlhdCI6MTcyMzgxMjA3N30._sU36wrll7j_pj_zuOXUclRjZyTYxoNVZfxj7reI1VA';
  ApiService(this._dio);

  Future<Map<String, dynamic>> get({
    required String endPoint,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? extra,
  }) async {
    var response = await _dio.get(
      '$baseUrl$endPoint',
      options: Options(
        headers: headers ??
            {
              'Authorization': 'Bearer ${getIt.get<AuthRepoImpl>().token}',
            },
        extra: extra,
      ),
    );
    print(response.statusCode);
    print(response);
    return response.data;
  }

  Future<Map<String, dynamic>> post({
    required String endPoint,
    required dynamic body,
    Map<String, dynamic>? queryParameters,
  }) async {
    var response = await _dio.post(
      '$baseUrl$endPoint',
      data: body,
      queryParameters: queryParameters,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${getIt.get<AuthRepoImpl>().token}',
        },
      ),
    );
    print(response.statusCode);
    print(response);
    return response.data;
  }

  Future<Map<String, dynamic>> delete({
    required String endPoint,
    required dynamic body,
  }) async {
    var response = await _dio.delete(
      '$baseUrl$endPoint',
      data: body,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${getIt.get<AuthRepoImpl>().token}',
        },
      ),
    );
    print(response.statusCode);
    print(response);
    return response.data;
  }

  Future<Map<String, dynamic>> put({
    required String endPoint,
    required dynamic body,
    Map<String, dynamic>? queryParameters,
  }) async {
    var response = await _dio.put(
      '$baseUrl$endPoint',
      data: body,
      queryParameters: queryParameters,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${getIt.get<AuthRepoImpl>().token}',
        },
      ),
    );
    print(response.statusCode);
    print(response);
    return response.data;
  }
}
