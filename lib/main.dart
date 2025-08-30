import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartgallery/core/helpers/service_locator.dart';
import 'package:smartgallery/features/Auth/view%20model/auth_cubit.dart';
import 'package:smartgallery/features/Auth/view%20model/auth_service.dart';
import 'package:smartgallery/features/Auth/view/signIn.dart';
import 'package:smartgallery/features/Display%20Interset/view%20model/display_intereset_cubit.dart';
import 'package:smartgallery/features/Display%20Interset/view%20model/display_interset_service.dart';
import 'package:smartgallery/features/Gallery%20Folders/view%20model/gallery_folder_cubit.dart';
import 'package:smartgallery/features/Gallery%20Folders/view%20model/gallery_folder_service.dart';
import 'package:smartgallery/features/My%20Intereset/view%20model/my_interset_cubit.dart';
import 'package:smartgallery/features/My%20Intereset/view%20model/my_interset_services.dart';
import 'package:smartgallery/features/Photos%20Gallery/view%20model/photo_gallarey_cubit.dart';
import 'package:smartgallery/features/Photos%20Gallery/view%20model/photo_gallery_service.dart';
import 'package:smartgallery/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit(getIt.get<AuthService>())),
        BlocProvider(
          create:
              (context) =>
                  ClassificationCubit(getIt.get<ClassificationService>()),
        ),
        BlocProvider(
          create: (context) => IntersetCubit(getIt.get<IntersetService>()),
        ),
        BlocProvider(
          create:
              (context) =>
                  GalleryFolderCubit(getIt.get<GalleryFolderService>()),
        ),
        BlocProvider(
          create:
              (context) => PhotoGalleryCubit(getIt.get<PhotoGalleryService>()),
        ),
      ],
      child: MaterialApp(
        title: 'Pixort',
        debugShowCheckedModeBanner: false,
        home: const SplashScreenWrapper(),
      ),
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  State<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      logoAssetPath: 'assets/logo.jpeg',
      onAnimationComplete: () {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) => SignInPage(),
            transitionDuration: const Duration(milliseconds: 500),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },
      splashDuration: const Duration(seconds: 3),
    );
  }
}
