import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:smartgallery/api/api_service.dart';
import 'package:smartgallery/core/helpers/failure.dart';
import 'package:smartgallery/features/Gallery%20Folders/model/media.dart';
import 'package:smartgallery/features/Gallery%20Folders/model/folders.dart';

class GalleryFolderService {
  final ApiService api;

  GalleryFolderService(this.api);

  Future<Either<Failure, String>> updateNameFolder({
    required int folderId,
    required String newName,
  }) async {
    try {
      // Debug print to check the parameters
      print('Updating folder - ID: $folderId, Name: $newName');

      Map<String, dynamic> response = await api.post(
        endPoint: '/api/folder/update_folderName',
        body: {'folder_id': folderId, 'new_name': newName},
      );

      print('Update name response: $response');

      if (response.containsKey('message') || response.containsKey('success')) {
        return right(response['message'] ?? 'Folder name updated successfully');
      } else {
        return left(Failure(errMessage: 'Failed To Update Folder Name'));
      }
    } catch (e) {
      print('Error in updateNameFolder: $e');
      if (e is DioException) {
        print('DioException details: ${e.response?.data}');
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
      // Debug print to check the parameters
      print('Updating folder password - ID: $folderId, Password: $newPassword');

      Map<String, dynamic> response = await api.post(
        endPoint: '/api/folder/updateFolderPassword',
        body: {'folder_id': folderId, 'new_password': newPassword},
      );

      print('Update password response: $response');

      if (response.containsKey('message') || response.containsKey('success')) {
        return right(
          response['message'] ?? 'Folder password updated successfully',
        );
      } else {
        return left(Failure(errMessage: 'Failed To Update Folder Password'));
      }
    } catch (e) {
      print('Error in updateFolderPassword: $e');
      if (e is DioException) {
        print('DioException details: ${e.response?.data}');
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
      print('Deleting folder - Name: $folderName, UserID: $userId');

      Map<String, dynamic> response = await api.delete(
        endPoint: '/api/folder/deleteFolder',
        body: {'folder_name': folderName, 'user_id': userId},
      );

      print('Delete folder response: $response');

      if (response.containsKey('message') || response.containsKey('success')) {
        return right(response['message'] ?? 'Folder deleted successfully');
      } else {
        return left(Failure(errMessage: 'Failed To Delete Folder'));
      }
    } catch (e) {
      print('Error in deleteFolder: $e');
      if (e is DioException) {
        print('DioException details: ${e.response?.data}');
        return left(Failure.fromDioException(e));
      } else {
        return left(
          Failure(errMessage: 'Something went wrong while Delete Folder: $e'),
        );
      }
    }
  }

  Future<Either<Failure, List<Media>>> getFolderMedia({
    required int folderId,
  }) async {
    try {
      print('Getting folder media for folder ID: $folderId');

      Map<String, dynamic> response = await api.get(
        endPoint: '/api/folder/get_foldermedia/$folderId',
      );

      if (response.containsKey('success') && response['success'] == true) {
        List<Media> mediaList = [];

        if (response['media'] != null && response['media'] is List) {
          for (var mediaJson in response['media']) {
            try {
              Media media = Media.fromJson(mediaJson);
              mediaList.add(media);
            } catch (e) {
              print('Error parsing media item: $e');
            }
          }
        }

        return right(mediaList);
      } else {
        return left(Failure(errMessage: 'Failed To Get Folder Media'));
      }
    } catch (e) {
      print('Error in getFolderMedia: $e');
      if (e is DioException) {
        print('DioException details: ${e.response?.data}');
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
    required String userId,
  }) async {
    try {
      print('Uploading images for user: $userId');
      print('Image paths: $imagePaths');

      FormData formData = FormData();

      for (String imagePath in imagePaths) {
        formData.files.add(
          MapEntry('images', await MultipartFile.fromFile(imagePath)),
        );
      }

      formData.fields.add(MapEntry('userName', userId));

      Map<String, dynamic> response = await api.post(
        endPoint: '/api/media/upload-images',
        body: formData,
      );

      print('Upload images response: $response');

      if (response.containsKey('message') || response.containsKey('success')) {
        return right(response['message'] ?? 'Images uploaded successfully');
      } else {
        return left(Failure(errMessage: 'Failed To Upload Images'));
      }
    } catch (e) {
      print('Error in uploadImages: $e');
      if (e is DioException) {
        print('DioException details: ${e.response?.data}');
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

  Future<Either<Failure, List<Folder>>> getAllFolders({
    required int userId,
  }) async {
    try {
      print('Getting all folders for user ID: $userId');

      Map<String, dynamic> response = await api.get(
        endPoint: '/api/folder/get_all_folders/$userId',
      );

      print('Get all folders response: $response');

      if (response.containsKey('success') && response['success'] == true) {
        List<Folder> folders = [];

        if (response['folders'] != null && response['folders'] is List) {
          for (var folderJson in response['folders']) {
            try {
              // Convert the JSON to Folder model
              Folder folder = Folder.fromJson(folderJson);
              folders.add(folder);
            } catch (e) {
              print('Error parsing folder item: $e');
              // Continue parsing other folders even if one fails
            }
          }
        }

        return right(folders);
      } else {
        return left(Failure(errMessage: 'Failed To Get All Folders'));
      }
    } catch (e) {
      print('Error in getAllFolders: $e');
      if (e is DioException) {
        print('DioException details: ${e.response?.data}');
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
