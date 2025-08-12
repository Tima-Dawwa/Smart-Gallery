import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:smartgallery/api/api_service.dart';
import 'package:smartgallery/core/helpers/failure.dart';

class GalleryFolderService {
  final ApiService api;

  GalleryFolderService(this.api);

  Future<Either<Failure, String>> updateNameFolder({
    required int folderId,
    required String newName,
  }) async {
    try {
      Map<String, dynamic> response = await api.post(
        endPoint: '/api/folder/update_folderName',
        body: {'folder_id': folderId, 'new_name': newName},
      );

      if (response.containsKey('message')) {
        return right(response['message']);
      } else {
        return left(Failure(errMessage: 'Failed To Update Folder Name'));
      }
    } catch (e) {
      if (e is DioException) {
        return left(Failure.fromDioException(e));
      } else {
        return left(
          Failure(
            errMessage: 'Something went wrong while Updating Folder Name: $e',
          ),
        );
      }
    }
  }

  Future<Either<Failure, String>> updateFolderPassword({
    required int folderId,
    required String newPassword,
  }) async {
    try {
      Map<String, dynamic> response = await api.post(
        endPoint: '/api/folder/updateFolderPassword',
        body: {'folder_id': folderId, 'new_name': newPassword},
      );

      if (response.containsKey('message')) {
        return right(response['message']);
      } else {
        return left(Failure(errMessage: 'Failed To Update Folder Password'));
      }
    } catch (e) {
      if (e is DioException) {
        return left(Failure.fromDioException(e));
      } else {
        return left(
          Failure(
            errMessage:
                'Something went wrong while Updating Folder Password: $e',
          ),
        );
      }
    }
  }

  Future<Either<Failure, String>> deleteFolder({
    required String folderName,
    required int userId,
  }) async {
    try {
      Map<String, dynamic> response = await api.delete(
        endPoint: '/api/folder/deleteFolder',
        body: {'folder_name': folderName, 'user_id': userId},
      );

      if (response.containsKey('message')) {
        return right(response['message']);
      } else {
        return left(Failure(errMessage: 'Failed To Delete Folder'));
      }
    } catch (e) {
      if (e is DioException) {
        return left(Failure.fromDioException(e));
      } else {
        return left(
          Failure(errMessage: 'Something went wrong while Delete Folder: $e'),
        );
      }
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> getFolderMedia({
    required int folderId,
  }) async {
    try {
      Map<String, dynamic> response = await api.get(
        endPoint: '/api/folder/get_foldermedia/$folderId',
      );

      if (response.containsKey('success') && response['success'] == true) {
        return right(response);
      } else {
        return left(Failure(errMessage: 'Failed To Get Folder Media'));
      }
    } catch (e) {
      if (e is DioException) {
        return left(Failure.fromDioException(e));
      } else {
        return left(
          Failure(
            errMessage: 'Something went wrong while Getting Folder Media: $e',
          ),
        );
      }
    }
  }

  Future<Either<Failure, String>> uploadImages({
    required List<String> imagePaths,
    required String userName,
  }) async {
    try {
      FormData formData = FormData();

      for (String imagePath in imagePaths) {
        formData.files.add(
          MapEntry('images', await MultipartFile.fromFile(imagePath)),
        );
      }

      formData.fields.add(MapEntry('userName', userName));

      Map<String, dynamic> response = await api.post(
        endPoint: '/api/media/upload-images',
        body: formData,
      );

      if (response.containsKey('message')) {
        return right(response['message']);
      } else {
        return left(Failure(errMessage: 'Failed To Upload Images'));
      }
    } catch (e) {
      if (e is DioException) {
        return left(Failure.fromDioException(e));
      } else {
        return left(
          Failure(
            errMessage: 'Something went wrong while Uploading Images: $e',
          ),
        );
      }
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> getAllFolders({
    required int userId,
  }) async {
    try {
      Map<String, dynamic> response = await api.get(
        endPoint: '/api/folder/get_all_folders/$userId',
      );

      if (response.containsKey('success') && response['success'] == true) {
        return right(response);
      } else {
        return left(Failure(errMessage: 'Failed To Get All Folders'));
      }
    } catch (e) {
      if (e is DioException) {
        return left(Failure.fromDioException(e));
      } else {
        return left(
          Failure(
            errMessage: 'Something went wrong while Getting All Folders: $e',
          ),
        );
      }
    }
  }
}
