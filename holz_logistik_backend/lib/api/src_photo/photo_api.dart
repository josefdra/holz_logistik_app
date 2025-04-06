import 'package:holz_logistik_backend/api/photo_api.dart';

/// {@template photo_api}
/// The interface for an API that provides access to photos.
/// {@endtemplate}
abstract class PhotoApi {
  /// {@macro photo_api}
  const PhotoApi();

  /// Provides a [Stream] of all photos.
  Stream<List<Photo>> get photos;

  /// Saves or updates a [photo].
  ///
  /// If a [photo] with the same id already exists, it will be updated.
  Future<void> savePhoto(Photo photo);

  /// Deletes the `photo` with the given [id].
  ///
  /// If no `photo` with the given id exists, a [PhotoNotFoundException] 
  /// error is thrown.
  Future<void> deletePhoto(int id);

  /// Closes the client and frees up any resources.
  Future<void> close();
}

/// Error thrown when a [Photo] with a given id is not found.
class PhotoNotFoundException implements Exception {}
