

import 'package:dartz/dartz.dart';
import 'package:smartgallery/core/helpers/failure.dart';

abstract class AuthRepo {
  Future<Either<Failure, Map<String, dynamic>>> login({
    required String name,
    required String password,
  });
  Future<Either<Failure, Map<String, dynamic>>> register({
    required String name,
    required int age,
    required String password,
  });
 
 
  Future<Either<Failure, Map<String, dynamic>>> getProfileData({
    required String token,
  });
 
 
}
