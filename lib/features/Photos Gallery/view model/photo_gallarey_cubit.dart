import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartgallery/features/Photos%20Gallery/view%20model/photo_gallarey_state.dart';
import 'package:smartgallery/features/Photos%20Gallery/view%20model/photo_gallery_service.dart';

class PhotoGalleryCubit extends Cubit<PhotoGalleryStates> {
  PhotoGalleryCubit(this.photoGalleryService)
    : super(InitialPhotoGalleryState());

  final PhotoGalleryService photoGalleryService;



  Future<void> uploadImages({
    required List<String> imagePaths,
    required String userId,
  }) async {
    emit(LoadingUploadImagesState());

    var response = await photoGalleryService.uploadImages(
      imagePaths: imagePaths,
      userId: userId,
    );

    response.fold(
      (failure) {
        emit(FailurePhotoGalleryState(failure: failure));
      },
      (message) {
        print('Images uploaded successfully: $message');
        emit(SuccessPhotoGalleryState(message: message));
      },
    );
  }

  Future<void> updateAudio({
    required int imageId,
    required String audioPath,
  }) async {
    emit(LoadingUpdateAudioState());

    var response = await photoGalleryService.updateAudio(
      imageId: imageId,
      audioPath: audioPath,
    );

    response.fold(
      (failure) {
        emit(FailurePhotoGalleryState(failure: failure));
      },
      (message) {
        print('Audio updated successfully: $message');
        emit(SuccessPhotoGalleryState(message: message));
      },
    );
  }

  Future<void> updateImage({
    required int imageId,
    required String imagePath,
  }) async {
    emit(LoadingUpdateImageState());

    var response = await photoGalleryService.updateImage(
      imageId: imageId,
      imagePath: imagePath,
    );

    response.fold(
      (failure) {
        emit(FailurePhotoGalleryState(failure: failure));
      },
      (message) {
        print('Image updated successfully: $message');
        emit(SuccessPhotoGalleryState(message: message));
      },
    );
  }
}
