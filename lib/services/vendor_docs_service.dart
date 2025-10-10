import 'dart:io';
import 'api_service.dart';
import '../models/vendor_document.dart';
import '../services/cloudinary_service.dart';

class VendorDocResult {
  final bool success;
  final String? message;
  final String? fileUrl;

  VendorDocResult({required this.success, this.message, this.fileUrl});
}

class VendorDocsService {
  final ApiService _apiService = ApiService();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  String _mapErrorMessage(String raw) {
    if (raw.contains("Unsupported ZIP file")) {
      return "That file type is not allowed. Please upload PDF, DOC, DOCX, JPG, or PNG.";
    }
    if (raw.contains("File size too large")) {
      return "File is too big. Maximum allowed size is 1MB.";
    }
    if (raw.contains("Network")) {
      return "Network error. Please check your internet connection.";
    }
    return "Unexpected error: $raw";
  }

  // Fetch vendor documents
  Future<List<VendorDocument>> fetchVendorDocuments(String vendorId) async {
    final response = await _apiService.get(
      'vendor_documents.php?vendor_id=$vendorId',
    );

    if (response['success'] == true && response['documents'] != null) {
      return (response['documents'] as List)
          .map((doc) => VendorDocument.fromJson(doc))
          .toList();
    }
    return [];
  }

  // Upload new document using Cloudinary
  Future<VendorDocResult> uploadDocument({
    required String vendorId,
    required String docType,
    required File file,
  }) async {
    try {
      // Upload to Cloudinary
      final result = await _cloudinaryService.uploadImage(file);

      if (result == null) {
        return VendorDocResult(
          success: false,
          message: "Upload failed. Please check your file format and size.",
        );
      }

      // Save metadata to backend
      final response = await _apiService.post('vendor_documents.php', {
        "vendor_id": vendorId,
        "doc_type": docType,
        "file_url": result.secureUrl,
        "public_id": result.publicId,
      });

      print('[vDocs] Backend response: $response');

      if (response['success'] == true) {
        return VendorDocResult(success: true, fileUrl: result.secureUrl);
      } else {
        return VendorDocResult(
          success: false,
          message: response['error'] ?? "Upload failed on server side.",
        );
      }
    } catch (e) {
      return VendorDocResult(
        success: false,
        message: _mapErrorMessage(e.toString()),
      );
    }
  }

  // Replace existing document with new file
  Future<VendorDocResult> replaceDocument({
    required String documentId,
    required File file,
  }) async {
    try {
      final result = await _cloudinaryService.uploadImage(file);

      if (result == null) {
        return VendorDocResult(
          success: false,
          message: "Upload failed. Please check your file format and size.",
        );
      }

      final response = await _apiService.put('vendor_documents.php', {
        "id": documentId,
        "file_url": result.secureUrl,
        "public_id": result.publicId,
      });

      if (response['success'] == true) {
        return VendorDocResult(success: true, fileUrl: result.secureUrl);
      } else {
        return VendorDocResult(
          success: false,
          message: response['error'] ?? "Replace failed on server side.",
        );
      }
    } catch (e) {
      return VendorDocResult(
        success: false,
        message: _mapErrorMessage(e.toString()),
      );
    }
  }

  // Delete a document
  Future<VendorDocResult> deleteDocument(String docId) async {
    try {
      final response = await _apiService.delete('vendor_documents.php', {
        "id": docId,
      });

      if (response['success'] == true) {
        return VendorDocResult(success: true);
      } else {
        return VendorDocResult(
          success: false,
          message: response['error'] ?? "Delete failed.",
        );
      }
    } catch (e) {
      return VendorDocResult(
        success: false,
        message: _mapErrorMessage(e.toString()),
      );
    }
  }
}
