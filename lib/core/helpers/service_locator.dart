import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:smartgallery/core/helpers/api_service.dart';
import 'package:smartgallery/features/Auth/data/repos/auth_repos_impl.dart';

final getIt = GetIt.instance;

Future<void> setup() async {
  getIt.registerSingleton<ApiService>(ApiService(Dio()));
  getIt.registerSingleton<AuthRepoImpl>(AuthRepoImpl(getIt.get<ApiService>()));
}
