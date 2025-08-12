import 'package:smartgallery/core/helpers/failure.dart';

abstract class GalleryFolderStates {}

class InitialGalleryFolderState extends GalleryFolderStates {}

class LoadingGalleryFolderState extends GalleryFolderStates {}

class SuccessGalleryFolderState extends GalleryFolderStates {
  final String message;

  SuccessGalleryFolderState({required this.message});
}

class FailureGalleryFolderState extends GalleryFolderStates {
  final Failure failure;

  FailureGalleryFolderState({required this.failure});
}


class SuccessFolderMediaState extends GalleryFolderStates {
  final Map<String, dynamic> data;

  SuccessFolderMediaState({required this.data});
}

class SuccessAllFoldersState extends GalleryFolderStates {
  final Map<String, dynamic> data;

  SuccessAllFoldersState({required this.data});
}


class LoadingFolderMediaState extends GalleryFolderStates {}

class LoadingAllFoldersState extends GalleryFolderStates {}

class LoadingUploadImagesState extends GalleryFolderStates {}

class LoadingUpdateFolderNameState extends GalleryFolderStates {}

class LoadingUpdateFolderPasswordState extends GalleryFolderStates {}

class LoadingDeleteFolderState extends GalleryFolderStates {}
