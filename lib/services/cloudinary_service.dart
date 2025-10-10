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

  Future<CloudinaryUploadResult?> uploadImage(File imageFile) async {
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
        final publicId = jsonResponse['public_id'];

        print('[v0] Upload successful: $secureUrl (public_id: $publicId)');

        return CloudinaryUploadResult(secureUrl: secureUrl, publicId: publicId);
      } else {
        print('[v0] Upload failed with status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('[v0] Error uploading to Cloudinary: $e');
      return null;
    }
  }

  Future<bool> deleteImage(String publicId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Create signature
      final stringToSign = 'public_id=$publicId&timestamp=$timestamp$apiSecret';
      final signature = sha1.convert(utf8.encode(stringToSign)).toString();

      final url = 'https://api.cloudinary.com/v1_1/$cloudName/image/destroy';

      print('[v0] DELETE request → public_id=$publicId');

      final response = await http.post(
        Uri.parse(url),
        body: {
          'public_id': publicId,
          'api_key': apiKey,
          'timestamp': timestamp.toString(),
          'signature': signature,
        },
      );

      final jsonResponse = json.decode(response.body);
      print('[v0] Delete response: $jsonResponse');

      if (response.statusCode == 200) {
        switch (jsonResponse['result']) {
          case 'ok':
            return true;
          case 'not found':
            print('[v0] Cloudinary says: image not found → $publicId');
            return false;
          default:
            print('[v0] Unexpected result: ${jsonResponse['result']}');
            return false;
        }
      } else {
        print(
          '[v0] Failed with status ${response.statusCode}: ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('[v0] Error deleting from Cloudinary: $e');
      return false;
    }
  }

  /// Extracts public_id from a Cloudinary URL.
  /// Example:
  ///   input:  https://res.cloudinary.com/demo/image/upload/v1312461204/sample.jpg
  ///   output: sample
  String extractPublicId(String imageUrl) {
    try {
      final uri = Uri.parse(imageUrl);
      final segments = uri.pathSegments;

      // Example segments:
      // [ "demo", "image", "upload", "v1234567890", "bazario", "vendor_logos", "hw5bflpl0jtand7n18yi.png" ]

      // Drop first 4 (demo, image, upload, v1234567890)
      final publicIdSegments = segments.sublist(4);

      // Remove extension
      final lastSegment = publicIdSegments.last.split('.').first;
      publicIdSegments[publicIdSegments.length - 1] = lastSegment;

      final publicId = publicIdSegments.join('/');

      print("[v0] Extracted public_id: $publicId");
      return publicId;
    } catch (e) {
      print("[v0] Failed to extract public_id: $e");
      return '';
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

class CloudinaryUploadResult {
  final String secureUrl;
  final String publicId;

  CloudinaryUploadResult({required this.secureUrl, required this.publicId});
}
