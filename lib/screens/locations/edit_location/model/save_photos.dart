import 'package:holz_logistik_backend/repository/repository.dart';

List<String> savePhotos(PhotoRepository repo, List<Photo> photos) {
  for (final photo in photos) {
    repo.savePhoto(photo);
  }

  return photos.map((photo) => photo.id).toList();
}
