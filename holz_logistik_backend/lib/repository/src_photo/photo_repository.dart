import 'dart:async';

import 'package:holz_logistik_backend/api/photo_api.dart';
import 'package:holz_logistik_backend/sync/photo_sync_service.dart';

/// {@template photo_repository}
/// A repository that handles `photo` related requests.
/// {@endtemplate}
class PhotoRepository {
  /// {@macro photo_repository}
  PhotoRepository({
    required PhotoApi photoApi,
    required PhotoSyncService photoSyncService,
  })  : _photoApi = photoApi,
        _photoSyncService = photoSyncService {
    _photoSyncService.photoUpdates.listen(_handleServerUpdate);
    _init();
  }

  final PhotoApi _photoApi;
  final PhotoSyncService _photoSyncService;

  /// Provides a [Stream] of photoUpdates.
  Stream<String> get photoUpdates => _photoApi.photoUpdates;

  void _init() {
    _photoSyncService
      ..registerDateGetter(_photoApi.getLastSyncDate)
      ..registerDataGetter(_photoApi.getUpdates);
  }

  /// Provides photos.
  Future<List<Photo>> getPhotosByLocation(String locationId) =>
      _photoApi.getPhotosByLocation(locationId);

  /// Handle updates from Server
  void _handleServerUpdate(Map<String, dynamic> data) {
    if (data.containsKey('newSyncDate')) {
      _photoApi.setLastSyncDate(
        DateTime.fromMillisecondsSinceEpoch(
          data['newSyncDate'] as int,
          isUtc: true,
        ),
      );
    } else if (data['deleted'] == true || data['deleted'] == 1) {
      _photoApi.deletePhoto(
        id: data['id'] as String,
      );
    } else if (data['synced'] == true || data['synced'] == 1) {
      _photoApi.setSynced(id: data['id'] as String);
    } else {
      final photo = Photo.fromJson(data);
      _photoApi.savePhoto(photo, fromServer: true);
    }
  }

  /// Saves a [photo].
  ///
  /// If a [photo] with the same id already exists, it will be replaced.
  Future<void> savePhoto(Photo photo) {
    final p = photo.copyWith(lastEdit: DateTime.now());
    _photoApi.savePhoto(p);
    return _photoSyncService.sendPhotoUpdate(p.toJson());
  }

  /// Saves multiple [photos].
  Future<void> updatePhotos(List<Photo> photos, String locationId) async {
    final oldPhotoIds = await _photoApi.getPhotoIdsByLocation(locationId);
    final newPhotoIds = <String>[];

    for (final photo in photos) {
      final photoExists = await _photoApi.checkIfPhotoExists(photo.id);
      if (!photoExists) {
        await savePhoto(photo.copyWith(locationId: locationId));
      }
      newPhotoIds.add(photo.id);
    }

    for (final oldId in oldPhotoIds) {
      if (!newPhotoIds.any((id) => id == oldId)) {
        await deletePhoto(id: oldId, locationId: locationId);
      }
    }

    return Future<void>.value();
  }

  /// Deletes the `photo` with the given id.
  Future<void> deletePhoto({required String id, required String locationId}) {
    _photoApi.markPhotoDeleted(id: id, locationId: locationId);
    final data = {
      'id': id,
      'deleted': 1,
      'locationId': locationId,
      'timestamp': DateTime.now().toUtc().millisecondsSinceEpoch,
    };

    return _photoSyncService.sendPhotoUpdate(data);
  }

  /// Deletes photos by location id.
  Future<void> deletePhotosByLocationId({required String locationId}) {
    return _photoApi.deletePhotosByLocationId(locationId: locationId);
  }

  /// Disposes any resources managed by the repository.
  void dispose() => _photoApi.close();
}
