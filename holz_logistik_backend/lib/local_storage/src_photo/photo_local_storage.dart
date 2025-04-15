import 'package:holz_logistik_backend/api/photo_api.dart';
import 'package:holz_logistik_backend/local_storage/core_local_storage.dart';
import 'package:holz_logistik_backend/local_storage/photo_local_storage.dart';
import 'package:rxdart/subjects.dart';
import 'package:sqflite/sqflite.dart';

/// {@template photo_local_storage}
/// A flutter implementation of the photo PhotoLocalStorage that uses
/// CoreLocalStorage and sqflite.
/// {@endtemplate}
class PhotoLocalStorage extends PhotoApi {
  /// {@macro photo_local_storage}
  PhotoLocalStorage({required CoreLocalStorage coreLocalStorage})
      : _coreLocalStorage = coreLocalStorage {
    // Register the table with the core database
    _coreLocalStorage
      ..registerTable(PhotoTable.createTable)
      ..registerMigration(_migratePhotoTable);

    _init();
  }

  final CoreLocalStorage _coreLocalStorage;
  late final _photoStreamController =
      BehaviorSubject<Map<String, List<Photo>>>.seeded(
    const {},
  );

  late final Stream<Map<String, List<Photo>>> _broadcastPhotosByLocation =
      _photoStreamController.stream;

  /// Migration function for photo table
  Future<void> _migratePhotoTable(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Migration logic here if needed
  }

  /// Initialization
  Future<void> _init() async {
    final photosJson = await _coreLocalStorage.getAll(PhotoTable.tableName);

    final photosByLocationId = <String, List<Photo>>{};

    for (final photoData in photosJson) {
      final photo = Photo.fromJson(Map<String, dynamic>.from(photoData));

      if (!photosByLocationId.containsKey(photo.locationId)) {
        photosByLocationId[photo.locationId] = [];
      }

      photosByLocationId[photo.locationId]!.add(photo);
    }
    _photoStreamController.add(photosByLocationId);
  }

  @override
  Stream<Map<String, List<Photo>>> get photosByLocation =>
      _broadcastPhotosByLocation;

  @override
  Map<String, List<Photo>> get currentPhotosByLocation =>
      _photoStreamController.value;

  /// Insert or Update a `photo` to the database based on [photoData]
  Future<int> _insertOrUpdatePhoto(Map<String, dynamic> photoData) async {
    return _coreLocalStorage.insertOrUpdate(
      PhotoTable.tableName,
      photoData,
    );
  }

  /// Insert or Update a [photo]
  @override
  Future<int> savePhoto(Photo photo) {
    final currentPhotosByLocation = _photoStreamController.value;
    if (!currentPhotosByLocation.containsKey(photo.locationId)) {
      currentPhotosByLocation[photo.locationId] = [];
    }

    currentPhotosByLocation[photo.locationId]!.add(photo);
    _photoStreamController.add(currentPhotosByLocation);

    return _insertOrUpdatePhoto(photo.toJson());
  }

  /// Delete a Photo from the database based on [id]
  Future<int> _deletePhoto(String id) async {
    return _coreLocalStorage.delete(PhotoTable.tableName, id);
  }

  /// Delete a Photo based on [id] and [locationId]
  @override
  Future<int> deletePhoto({
    required String id,
    required String locationId,
  }) async {
    final currentPhotosByLocation = _photoStreamController.value;

    currentPhotosByLocation[locationId]!.removeWhere((p) => p.id == id);

    if (currentPhotosByLocation[locationId]!.isEmpty) {
      currentPhotosByLocation.remove(locationId);
    }
    _photoStreamController.add(currentPhotosByLocation);

    return _deletePhoto(id);
  }

  /// Close the [_photoStreamController]
  @override
  Future<void> close() {
    return _photoStreamController.close();
  }
}
