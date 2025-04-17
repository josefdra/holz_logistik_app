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
  }

  final PhotoApi _photoApi;
  final PhotoSyncService _photoSyncService;

  /// Provides a [Stream] of all photos.
  Stream<Map<String, dynamic>> get photoUpdates => _photoApi.photoUpdates;

  /// Provides photos.
  Future<List<Photo>> getPhotosByLocation(String locationId) =>
      _photoApi.getPhotosByLocation(locationId);

  /// Handle updates from Server
  void _handleServerUpdate(Map<String, dynamic> data) {
    if (data['deleted'] == true || data['deleted'] == 1) {
      _photoApi.deletePhoto(
        id: data['id'] as String,
        locationId: data['locationId'] as String,
      );
    } else {
      _photoApi.savePhoto(Photo.fromJson(data));
    }
  }

  /// Saves a [photo].
  ///
  /// If a [photo] with the same id already exists, it will be replaced.
  Future<void> savePhoto(Photo photo) {
    _photoApi.savePhoto(photo);
    return _photoSyncService.sendPhotoUpdate(photo.toJson());
  }

  /// Saves multiple [photos].
  Future<void> savePhotos(List<Photo> photos) {
    for (final photo in photos) {
      savePhoto(photo);
    }

    return Future<void>.value();
  }

  /// Deletes the `photo` with the given id.
  Future<void> deletePhoto({required String id, required String locationId}) {
    _photoApi.deletePhoto(id: id, locationId: locationId);
    final data = {
      'id': id,
      'deleted': true,
      'timestamp': DateTime.now().toIso8601String(),
    };

    return _photoSyncService.sendPhotoUpdate(data);
  }

  /// Disposes any resources managed by the repository.
  void dispose() => _photoApi.close();
}
