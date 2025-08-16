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

      Map<String, dynamic> response = await api.post(
        endPoint: '/api/folder/update_folderName',
        body: {'folder_id': folderId.toString(), 'new_name': newName.trim()},
      );


      if (response.containsKey('message') ||
          response.containsKey('success') ||
          (response.containsKey('success') && response['success'] == true)) {
        return right(response['message'] ?? 'Folder name updated successfully');
      } else {
        return left(
          Failure(
            errMessage: response['error'] ?? 'Failed To Update Folder Name',
          ),
        );
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
        body: {'folder_id': folderId.toString(), 'new_password': newPassword},
      );


      if (response.containsKey('message') ||
          response.containsKey('success') ||
          (response.containsKey('success') && response['success'] == true)) {
        return right(
          response['message'] ?? 'Folder password updated successfully',
        );
      } else {
        return left(
          Failure(
            errMessage: response['error'] ?? 'Failed To Update Folder Password',
          ),
        );
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
        body: {'folder_name': folderName.trim(), 'user_id': userId.toString()},
      );

      if (response.containsKey('message') ||
          response.containsKey('success') ||
          (response.containsKey('success') && response['success'] == true)) {
        return right(response['message'] ?? 'Folder deleted successfully');
      } else {
        return left(
          Failure(errMessage: response['error'] ?? 'Failed To Delete Folder'),
        );
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

  Future<Either<Failure, List<Media>>> getFolderMedia({
    required int folderId,
  }) async {
    try {
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
        return left(
          Failure(
            errMessage: response['error'] ?? 'Failed To Get Folder Media',
          ),
        );
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
    required String userId,
  }) async {
    try {
      FormData formData = FormData();

      for (String imagePath in imagePaths) {
        formData.files.add(
          MapEntry('images', await MultipartFile.fromFile(imagePath)),
        );
      }

      formData.fields.add(MapEntry('userid', userId));

      Map<String, dynamic> response = await api.post(
        endPoint: '/api/media/upload-images',
        body: formData,
      );

      if (response.containsKey('message') ||
          response.containsKey('success') ||
          (response.containsKey('success') && response['success'] == true)) {
        return right(response['message'] ?? 'Images uploaded successfully');
      } else {
        return left(
          Failure(errMessage: response['error'] ?? 'Failed To Upload Images'),
        );
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

  Future<Either<Failure, List<Folder>>> getAllFolders({
    required int userId,
  }) async {
    try {
      Map<String, dynamic> response = await api.get(
        endPoint: '/api/folder/get_all_folders/$userId',
      );

      if (response.containsKey('success') && response['success'] == true) {
        List<Folder> folders = [];

        if (response['folders'] != null && response['folders'] is List) {
          for (var folderJson in response['folders']) {
            try {
              Folder folder = Folder.fromJson(folderJson);
              folders.add(folder);
            } catch (e) {
              print('Error parsing folder item: $e');
            }
          }
        }

        return right(folders);
      } else {
        return left(
          Failure(errMessage: response['error'] ?? 'Failed To Get All Folders'),
        );
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

  Future<Either<Failure, String>> updateAudio({
    required int imageId,
    required String audioPath,
  }) async {
    try {
      print('Updating audio for image ID: $imageId');
      print('Audio path: $audioPath');

      FormData formData = FormData();

      formData.fields.add(MapEntry('image_id', imageId.toString()));

      formData.files.add(
        MapEntry('audio', await MultipartFile.fromFile(audioPath)),
      );

      Map<String, dynamic> response = await api.post(
        endPoint: '/api/media/updateAudio',
        body: formData,
      );

      print('Update audio response: $response');

      if (response.containsKey('message') ||
          response.containsKey('success') ||
          (response.containsKey('success') && response['success'] == true)) {
        return right(response['message'] ?? 'Audio updated successfully');
      } else {
        return left(
          Failure(errMessage: response['error'] ?? 'Failed To Update Audio'),
        );
      }
    } catch (e) {
      print('Error in updateAudio: $e');
      if (e is DioException) {
        print('DioException details: ${e.response?.data}');
        print('DioException status code: ${e.response?.statusCode}');
        return left(Failure.fromDioException(e));
      } else {
        return left(
          Failure(errMessage: 'Something went wrong while Updating Audio: $e'),
        );
      }
    }
  }

  Future<Either<Failure, String>> updateImage({
    required int imageId,
    required String imagePath,
  }) async {
    try {
      print('Updating image for image ID: $imageId');
      print('Image path: $imagePath');

      FormData formData = FormData();

      // Add the image_id as a field
      formData.fields.add(MapEntry('image_id', imageId.toString()));

      // Add the image file
      formData.files.add(
        MapEntry('image', await MultipartFile.fromFile(imagePath)),
      );

      Map<String, dynamic> response = await api.post(
        endPoint: '/api/media/updateImage',
        body: formData,
      );

      print('Update image response: $response');

      if (response.containsKey('message') ||
          response.containsKey('success') ||
          (response.containsKey('success') && response['success'] == true)) {
        return right(response['message'] ?? 'Image updated successfully');
      } else {
        return left(
          Failure(errMessage: response['error'] ?? 'Failed To Update Image'),
        );
      }
    } catch (e) {
      print('Error in updateImage: $e');
      if (e is DioException) {
        print('DioException details: ${e.response?.data}');
        print('DioException status code: ${e.response?.statusCode}');
        return left(Failure.fromDioException(e));
      } else {
        return left(
          Failure(errMessage: 'Something went wrong while Updating Image: $e'),
        );
      }
    }
  }
}
