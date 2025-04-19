import 'package:holz_logistik_backend/api/photo_api.dart';

/// {@template photo_api}
/// The interface for an API that provides access to photos.
/// {@endtemplate}
abstract class PhotoApi {
  /// {@macro photo_api}
  const PhotoApi();

  /// Provides updates on finished photos
  Stream<String> get photoUpdates;

  /// Tests if a photo already exists
  Future<bool> checkIfPhotoExists(String photoId);

  /// Provides photos.
  Future<List<Photo>> getPhotosByLocation(String locationId);

  /// Provides photos ids by location.
  Future<List<String>> getPhotoIdsByLocation(String locationId);

  /// Saves or updates a [photo].
  ///
  /// If a [photo] with the same id already exists, it will be updated.
  Future<void> savePhoto(Photo photo);

  /// Deletes the `photo` with the given [id].
  Future<void> deletePhoto({required String id, required String locationId});

  /// Deletes the photos by location id
  Future<void> deletePhotosByLocationId({required String locationId});

  /// Closes the client and frees up any resources.
  Future<void> close();
}
