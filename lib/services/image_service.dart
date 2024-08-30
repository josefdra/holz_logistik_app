import 'dart:io';

import 'package:holz_logistik/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ImageService {
  Future<String> saveImageLocally(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = path.basename(image.path);
    final savedImage = await image.copy('${directory.path}/$fileName');
    return savedImage.path;
  }

  Future<List<String>> uploadImages(List<File> images) async {
    List<String> uploadedUrls = [];

    for (var image in images) {
      var request = http.MultipartRequest(
          'POST', Uri.parse('${ApiConfig.baseUrl}/upload'));
      request.files.add(await http.MultipartFile.fromPath('image', image.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var imageUrl = responseString; // Assuming the response is the image URL
        uploadedUrls.add(imageUrl);
      } else {
        throw Exception('Failed to upload image');
      }
    }

    return uploadedUrls;
  }

  Future<File> downloadImage(String url) async {
    var response = await http.get(Uri.parse(url));
    var directory = await getTemporaryDirectory();
    var fileName = path.basename(url);
    var filePath = path.join(directory.path, fileName);
    var file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  Future<void> deleteLocalImage(String filePath) async {
    var file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
