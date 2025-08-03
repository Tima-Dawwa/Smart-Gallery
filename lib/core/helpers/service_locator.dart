import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:smartgallery/api/api_service.dart';
import 'package:smartgallery/features/Auth/view%20model/auth_service.dart';

final getIt = GetIt.instance;

Future<void> setup() async {
  getIt.registerSingleton<ApiService>(ApiService(Dio()));
  getIt.registerSingleton<AuthService>(AuthService(getIt.get<ApiService>()));

  
}
