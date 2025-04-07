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
  late final _photoStreamController = BehaviorSubject<List<Photo>>.seeded(
    const [],
  );

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
    final photos = photosJson
        .map((photo) => Photo.fromJson(Map<String, dynamic>.from(photo)))
        .toList();
    _photoStreamController.add(photos);
  }

  /// Get the `photo`s from the [_photoStreamController]
  @override
  Stream<List<Photo>> get photos => _photoStreamController.asBroadcastStream();

  /// Insert or Update a `photo` to the database based on [photoData]
  Future<int> _insertOrUpdatePhoto(Map<String, dynamic> photoData) async {
    return _coreLocalStorage.insertOrUpdate(PhotoTable.tableName, photoData);
  }

  /// Insert or Update a [photo]
  @override
  Future<int> savePhoto(Photo photo) {
    final photos = [..._photoStreamController.value];
    final photoIndex = photos.indexWhere((t) => t.id == photo.id);
    if (photoIndex >= 0) {
      photos[photoIndex] = photo;
    } else {
      photos.add(photo);
    }

    _photoStreamController.add(photos);
    return _insertOrUpdatePhoto(photo.toJson());
  }

  /// Delete a Photo from the database based on [id]
  Future<int> _deletePhoto(String id) async {
    return _coreLocalStorage.delete(PhotoTable.tableName, id);
  }

  /// Delete a Photo based on [id]
  @override
  Future<int> deletePhoto(String id) async {
    final photos = [..._photoStreamController.value];
    final photoIndex = photos.indexWhere((t) => t.id == id);
    if (photoIndex == -1) {
      throw PhotoNotFoundException();
    } else {
      photos.removeAt(photoIndex);
      _photoStreamController.add(photos);
      return _deletePhoto(id);
    }
  }

  /// Close the [_photoStreamController]
  @override
  Future<void> close() {
    return _photoStreamController.close();
  }
}
