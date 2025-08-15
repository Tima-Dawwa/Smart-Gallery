import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartgallery/features/Gallery%20Folders/model/media.dart';
import 'package:smartgallery/features/Gallery%20Folders/model/folders.dart';
import 'package:smartgallery/features/Gallery%20Folders/view%20model/gallery_folder_service.dart';
import 'package:smartgallery/features/Gallery%20Folders/view%20model/gallery_folder_states.dart';

class GalleryFolderCubit extends Cubit<GalleryFolderStates> {
  GalleryFolderCubit(this.galleryFolderService)
    : super(InitialGalleryFolderState());

  final GalleryFolderService galleryFolderService;

  Future<void> updateNameFolder({
    required int folderId,
    required String newName,
  }) async {
    emit(LoadingUpdateFolderNameState());

    var response = await galleryFolderService.updateNameFolder(
      folderId: folderId,
      newName: newName,
    );

    response.fold(
      (failure) {
        emit(FailureGalleryFolderState(failure: failure));
      },
      (message) {
        print('Folder name updated successfully: $message');
        emit(SuccessGalleryFolderState(message: message));
      },
    );
  }

  Future<void> updateFolderPassword({
    required int folderId,
    required String newPassword,
  }) async {
    emit(LoadingUpdateFolderPasswordState());

    var response = await galleryFolderService.updateFolderPassword(
      folderId: folderId,
      newPassword: newPassword,
    );

    response.fold(
      (failure) {
        emit(FailureGalleryFolderState(failure: failure));
      },
      (message) {
        print('Folder password updated successfully: $message');
        emit(SuccessGalleryFolderState(message: message));
      },
    );
  }

  Future<void> deleteFolder({
    required String folderName,
    required int userId,
  }) async {
    emit(LoadingDeleteFolderState());

    var response = await galleryFolderService.deleteFolder(
      folderName: folderName,
      userId: userId,
    );

    response.fold(
      (failure) {
        emit(FailureGalleryFolderState(failure: failure));
      },
      (message) {
        print('Folder deleted successfully: $message');
        emit(SuccessGalleryFolderState(message: message));
        // Optionally refresh folder list after deletion
        // getAllFolders(userId);
      },
    );
  }

  Future<void> getFolderMedia({required int folderId}) async {
    emit(LoadingFolderMediaState());

    var response = await galleryFolderService.getFolderMedia(
      folderId: folderId,
    );

    response.fold(
      (failure) {
        emit(FailureGalleryFolderState(failure: failure));
      },
      (mediaList) {
        print(
          'Folder media loaded for folder $folderId: ${mediaList.length} items',
        );

        // Filter out media items that have no actual content
        List<Media> validMedia =
            mediaList.where((media) => media.hasMedia).cast<Media>().toList();

        print('Valid media items: ${validMedia.length}');
        emit(SuccessFolderMediaState(mediaList: validMedia));
      },
    );
  }

  Future<void> uploadImages({
    required List<String> imagePaths,
    required String userId,
  }) async {
    emit(LoadingUploadImagesState());

    var response = await galleryFolderService.uploadImages(
      imagePaths: imagePaths,
      userId: userId,
    );

    response.fold(
      (failure) {
        emit(FailureGalleryFolderState(failure: failure));
      },
      (message) {
        print('Images uploaded successfully: $message');
        emit(SuccessGalleryFolderState(message: message));
      },
    );
  }

  // Updated getAllFolders method to work with List<Folder>
  Future<void> getAllFolders({required int userId}) async {
    emit(LoadingAllFoldersState());

    var response = await galleryFolderService.getAllFolders(userId: userId);

    response.fold(
      (failure) {
        emit(FailureGalleryFolderState(failure: failure));
      },
      (folders) {
        print('All folders loaded for user $userId: ${folders.length} folders');
        emit(SuccessAllFoldersState(folders: folders));
      },
    );
  }

  void resetToInitial() {
    emit(InitialGalleryFolderState());
  }

  Future<void> refreshFolderData({int? userId, int? folderId}) async {
    if (userId != null) {
      await getAllFolders(userId: userId);
    }
    if (folderId != null) {
      await getFolderMedia(folderId: folderId);
    }
  }
}
