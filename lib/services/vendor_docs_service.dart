import 'dart:io';
import 'api_service.dart';
import '../models/vendor_document.dart';
import '../services/cloudinary_service.dart';

class VendorDocsService {
  final ApiService _apiService = ApiService();
  final CloudinaryService _cloudinaryService = CloudinaryService();

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
  Future<bool> uploadDocument({
    required String vendorId,
    required String docType,
    required File file,
  }) async {
    try {
      // Upload to Cloudinary first
      final fileUrl = await _cloudinaryService.uploadImage(file);
      if (fileUrl == null) {
        print('[vDocs] Cloudinary upload failed');
        return false;
      }

      // Save metadata to backend
      final response = await _apiService.post('vendor_documents.php', {
        "vendor_id": vendorId,
        "doc_type": docType,
        "file_url": fileUrl,
      });

      return response['success'] == true;
    } catch (e) {
      print('[vDocs] Error uploading document: $e');
      return false;
    }
  }

  // Replace existing document with new file
  Future<bool> replaceDocument({
    required String documentId,
    required File file,
  }) async {
    try {
      // Upload to Cloudinary
      final fileUrl = await _cloudinaryService.uploadImage(file);
      if (fileUrl == null) {
        print('[vDocs] Cloudinary upload failed');
        return false;
      }

      // Update backend with new file URL
      final response = await _apiService.put('vendor_documents.php', {
        "id": documentId,
        "file_url": fileUrl,
      });

      return response['success'] == true;
    } catch (e) {
      print('[vDocs] Error replacing document: $e');
      return false;
    }
  }

  // Delete a document
  Future<bool> deleteDocument(String docId) async {
    try {
      final response = await _apiService.delete('vendor_documents.php', {
        "id": docId,
      });
      return response['success'] == true;
    } catch (e) {
      print('[vDocs] Error deleting document: $e');
      return false;
    }
  }
}
