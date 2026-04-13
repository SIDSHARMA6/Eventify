import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();
  factory CloudinaryService() => _instance;
  CloudinaryService._internal();

  static const String _cloudName = 'dgfqim3jy';
  static const String _uploadPreset = 'eventify_unsigned';

  Future<String> uploadImage(File imageFile, String folder) async {
    final uri =
        Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = folder
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return json['secure_url'] as String;
    }
    throw Exception(
        'Cloudinary error: ${response.statusCode} - ${response.body}');
  }

}
