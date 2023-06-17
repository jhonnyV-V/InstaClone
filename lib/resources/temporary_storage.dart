import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:instagram_clone/utils/constants.dart';
import 'package:path_provider/path_provider.dart';

class TemporaryStorage {
  static Future<String> getImage(String uid, String route, String url) async {
    final Directory temp = await getTemporaryDirectory();
    File imageFile = File('${temp.path}/images/$route/$uid.png');
    if (defaultProfilePicture == url) {
      imageFile = File('${temp.path}/images/$tempProfilePicture/default.png');
    }
    if (await imageFile.exists()) {
      return imageFile.path;
    }

    return await saveImageToCache(imageFile, url);
  }

  static Future<String> saveImageToCache(File img, String url) async {
    await img.create(recursive: true);
    http.Response response = await http.get(
      Uri.parse(
        url,
      ),
    );
    img.writeAsBytes(response.bodyBytes);

    return img.path;
  }
}
