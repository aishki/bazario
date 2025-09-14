import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class CloudinaryService {
  static const String cloudName = 'ddnkxzfii';
  static const String apiKey = '297989575297736';
  static const String apiSecret = 'Ivjvk3_J3_U_w5KH7iBpjnNUKO4';
  static const String uploadUrl =
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';

  Future<String?> uploadImage(File imageFile) async {
    try {
      print('[v0] Starting Cloudinary upload...');

      // Generate timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Create signature
      final signature = _generateSignature(timestamp);

      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

      // Add fields
      request.fields['api_key'] = apiKey;
      request.fields['timestamp'] = timestamp.toString();
      request.fields['signature'] = signature;
      request.fields['folder'] = 'bazario/vendor_logos';

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      print('[v0] Sending request to Cloudinary...');

      // Send request
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('[v0] Cloudinary response status: ${response.statusCode}');
      print('[v0] Cloudinary response body: $responseBody');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        final secureUrl = jsonResponse['secure_url'];
        print('[v0] Upload successful: $secureUrl');
        return secureUrl;
      } else {
        print('[v0] Upload failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('[v0] Error uploading to Cloudinary: $e');
      return null;
    }
  }

  String _generateSignature(int timestamp) {
    // Create the string to sign
    final stringToSign =
        'folder=bazario/vendor_logos&timestamp=$timestamp$apiSecret';

    // Generate SHA1 hash
    final bytes = utf8.encode(stringToSign);
    final digest = sha1.convert(bytes);

    return digest.toString();
  }
}
