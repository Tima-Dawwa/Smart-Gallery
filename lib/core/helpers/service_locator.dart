import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:smartgallery/api/api_service.dart';
import 'package:smartgallery/features/Auth/view%20model/auth_service.dart';
import 'package:smartgallery/features/Display%20Interset/view%20model/display_interset_service.dart';
import 'package:smartgallery/features/Gallery%20Folders/view%20model/gallery_folder_service.dart';
import 'package:smartgallery/features/My%20Intereset/view%20model/my_interset_services.dart';

final getIt = GetIt.instance;

Future<void> setup() async {
  getIt.registerSingleton<ApiService>(ApiService(Dio()));
  getIt.registerSingleton<AuthService>(AuthService(getIt.get<ApiService>()));
  getIt.registerSingleton<ClassificationService>(
    ClassificationService(getIt.get<ApiService>()),
  );
  getIt.registerSingleton<IntersetService>(
    IntersetService(getIt.get<ApiService>()),
  );
  getIt.registerSingleton<GalleryFolderService>(
    GalleryFolderService(getIt.get<ApiService>()),
  );
}
