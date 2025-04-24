import 'package:holz_logistik_backend/api/photo_api.dart';

/// {@template photo_api}
/// The interface for an API that provides access to photos.
/// {@endtemplate}
abstract class PhotoApi {
  /// {@macro photo_api}
  const PhotoApi();

  /// Provides updates on finished photos
  Stream<String> get photoUpdates;

  /// Provides the last sync date
  Future<DateTime> getLastSyncDate();

  /// Sets the last sync date
  Future<void> setLastSyncDate(DateTime date);

  /// Gets updates
  Future<List<Map<String, dynamic>>> getUpdates();

  /// Tests if a photo already exists
  Future<bool> checkIfPhotoExists(String photoId);

  /// Provides photos.
  Future<List<Photo>> getPhotosByLocation(String locationId);

  /// Provides photos ids by location.
  Future<List<String>> getPhotoIdsByLocation(String locationId);

  /// Saves or updates a [photo].
  ///
  /// If a [photo] with the same id already exists, it will be updated.
  Future<void> savePhoto(Photo photo, {bool fromServer = false});

  /// Marks a `photo` with the given [id] as deleted.
  Future<void> markPhotoDeleted({
    required String id,
    required String locationId,
  });

  /// Deletes the `photo` with the given [id].
  Future<void> deletePhoto({required String id});

  /// Deletes photos by location id
  Future<void> deletePhotosByLocationId({required String locationId});

  /// Sets synced
  Future<void> setSynced({required String id});

  /// Closes the client and frees up any resources.
  Future<void> close();
}
