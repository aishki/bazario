class VendorDocument {
  final String? id;
  final String docType;
  final String? fileUrl;
  final String? status;
  final DateTime? uploadedAt;

  VendorDocument({
    this.id,
    required this.docType,
    this.fileUrl,
    this.status,
    this.uploadedAt,
  });

  factory VendorDocument.fromJson(Map<String, dynamic> json) {
    return VendorDocument(
      id: json['id'],
      docType: json['doc_type'],
      fileUrl: json['file_url'],
      status: json['status'],
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.tryParse(json['uploaded_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "doc_type": docType,
      "file_url": fileUrl,
      "status": status,
      "uploaded_at": uploadedAt?.toIso8601String(),
    };
  }

  // 👇 This fixes the "undefined method empty" error
  factory VendorDocument.empty(String docType) {
    return VendorDocument(
      id: null,
      docType: docType,
      fileUrl: null,
      status: null,
      uploadedAt: null,
    );
  }
}
