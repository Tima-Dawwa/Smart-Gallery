import 'package:smartgallery/core/helpers/failure.dart';
import 'package:smartgallery/features/Gallery%20Folders/model/media.dart';

abstract class PhotoGalleryStates {}

class InitialPhotoGalleryState extends PhotoGalleryStates {}

class SuccessPhotoGalleryState extends PhotoGalleryStates {
  final String message;

  SuccessPhotoGalleryState({required this.message});
}

class FailurePhotoGalleryState extends PhotoGalleryStates {
  final Failure failure;

  FailurePhotoGalleryState({required this.failure});
}

class SuccessFolderMediaState extends PhotoGalleryStates {
  final List<Media> mediaList;

  SuccessFolderMediaState({required this.mediaList});
}

class LoadingFolderMediaState extends PhotoGalleryStates {}

class LoadingUploadImagesState extends PhotoGalleryStates {}

class LoadingUpdateAudioState extends PhotoGalleryStates {}

class LoadingUpdateImageState extends PhotoGalleryStates {}
