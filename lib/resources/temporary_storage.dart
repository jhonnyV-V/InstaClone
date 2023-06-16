import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class TemporaryStorage {
  static Future<String> getImage(String uid, String route, String url) async {
    final Directory temp = await getTemporaryDirectory();
    final File imageFile = File('${temp.path}/images/$route/$uid.png');
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
