import 'package:smartgallery/core/helpers/failure.dart';
import 'package:smartgallery/features/Gallery%20Folders/model/media.dart';
import 'package:smartgallery/features/Gallery%20Folders/model/folders.dart';

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
  final List<Media> mediaList;

  SuccessFolderMediaState({required this.mediaList});
}

// Updated to use List<Folder> instead of Map<String, dynamic>
class SuccessAllFoldersState extends GalleryFolderStates {
  final List<Folder> folders;

  SuccessAllFoldersState({required this.folders});
}

class LoadingFolderMediaState extends GalleryFolderStates {}

class LoadingAllFoldersState extends GalleryFolderStates {}

class LoadingUploadImagesState extends GalleryFolderStates {}

class LoadingUpdateFolderNameState extends GalleryFolderStates {}

class LoadingUpdateFolderPasswordState extends GalleryFolderStates {}

class LoadingDeleteFolderState extends GalleryFolderStates {}
