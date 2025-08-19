import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:smartgallery/api/api_service.dart';
import 'package:smartgallery/core/helpers/failure.dart';
import 'package:smartgallery/features/Gallery%20Folders/model/media.dart';

class PhotoGalleryService {
  final ApiService api;

  PhotoGalleryService(this.api);



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

      formData.fields.add(MapEntry('image_id', imageId.toString()));

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
  
      if (e is DioException) {
    
        return left(Failure.fromDioException(e));
      } else {
        return left(
          Failure(errMessage: 'Something went wrong while Updating Image: $e'),
        );
      }
    }
  }
}
