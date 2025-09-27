import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/pajamas.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../../services/vendor_docs_service.dart';
import '../../models/vendor.dart';
import '../../models/vendor_document.dart';

class VendorMyDocs extends StatefulWidget {
  final String userId;
  final String vendorId;
  final String businessName;
  final Vendor vendor;

  const VendorMyDocs({
    super.key,
    required this.userId,
    required this.vendorId,
    required this.businessName,
    required this.vendor,
  });

  @override
  State<VendorMyDocs> createState() => _VendorMyDocsState();
}

class _VendorMyDocsState extends State<VendorMyDocs> {
  final VendorDocsService _service = VendorDocsService();
  bool _loading = true;
  List<VendorDocument>? _docs;

  @override
  void initState() {
    super.initState();
    _fetchDocs();
  }

  Future<void> _fetchDocs() async {
    setState(() => _loading = true);
    final docs = await _service.fetchVendorDocuments(widget.vendorId);
    if (mounted) {
      setState(() {
        _docs = docs;
        _loading = false;
      });
    }
  }

  // Pick any allowed file type (images & common docs) and return File or null
  Future<File?> _pickAnyFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
    } catch (e, st) {
      debugPrint("File pick error: $e\n$st");
    }
    return null;
  }

  Future<void> _onUpload(String docType) async {
    final file = await _pickAnyFile();
    if (file == null) return;

    // show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: LoadingAnimationWidget.inkDrop(
          color: const Color(0xFF74CC00),
          size: 50,
        ),
      ),
    );

    final success = await _service.uploadDocument(
      vendorId: widget.vendorId,
      docType: docType,
      file: file,
    );

    Navigator.pop(context); // close loading
    if (success) {
      await _fetchDocs();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Document uploaded')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Upload failed')));
    }
  }

  Future<void> _onReplace(String docId) async {
    final file = await _pickAnyFile();
    if (file == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: LoadingAnimationWidget.inkDrop(
          color: const Color(0xFF74CC00),
          size: 50,
        ),
      ),
    );

    final success = await _service.replaceDocument(
      documentId: docId,
      file: file,
    );

    Navigator.pop(context);
    if (success) {
      await _fetchDocs();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Document replaced')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Replace failed')));
    }
  }

  Future<void> _onDelete(String docId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm delete'),
        content: const Text('Are you sure you want to delete this file?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final success = await _service.deleteDocument(docId);
    if (success) {
      await _fetchDocs();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Document deleted')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Delete failed')));
    }
  }

  Widget _buildHeaderBox() {
    final completedCount = _docs == null
        ? 0
        : _docs!.where((d) => d.fileUrl != null).length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF74CC00)),
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 👉 Row 1: Status summary
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1AA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Iconify(
                  Pajamas.status_closed,
                  color: Color(0xFF74CC00),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Status: ',
                  style: const TextStyle(
                    fontFamily: 'Starla',
                    color: Color(0xFF276700),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$completedCount out of 4 Completed',
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    color: Color(0xFF569109),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          //Row 2
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Right column (instructions)
              Expanded(
                flex: 2,
                child: Text(
                  'Please upload your required documents here and complete the requirements. Once submitted, kindly wait for verification—our team will review and approve your documents if valid.',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Color(0xFF276700),
                    height: 1.3,
                  ),
                  softWrap: true,
                ),
              ),
            ],
          ),

          //Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: Divider(thickness: 1.5, color: const Color(0xFF74CC00)),
          ),

          // 👉 Row 3: Left note
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column (note)
              Expanded(
                flex: 1,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Iconify(
                      Pajamas.status_alert,
                      color: Color(0xFF74CC00),
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Upload your required documents in PDF, DOC, or PNG format.',
                        maxLines: 7,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'Poppins',
                          color: Color(0xFF569109),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocsList() {
    // images ordered: red, green, blue, orange
    final assetByType = {
      'business_permit': 'lib/assets/images/my-docs-list/red.png',
      'bir_registration': 'lib/assets/images/my-docs-list/green.png',
      'contract_moa': 'lib/assets/images/my-docs-list/blue.png',
      'government_id': 'lib/assets/images/my-docs-list/orange.png',
    };

    final types = [
      {'key': 'business_permit', 'title': 'Business Permit'},
      {'key': 'bir_registration', 'title': 'BIR Registration'},
      {'key': 'contract_moa', 'title': 'Contract (MOA)'},
      {'key': 'government_id', 'title': 'Valid Government ID'},
    ];

    final width = MediaQuery.of(context).size.width * 0.92;

    return Column(
      children: List.generate(types.length, (i) {
        final t = types[i];
        final existing = _docs?.firstWhere(
          (d) => d.docType == t['key'],
          orElse: () => VendorDocument.empty(t['key']!),
        )!;

        return Column(
          children: [
            Container(
              width: width,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: AssetImage('lib/assets/images/my-docs-list-bg.png'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DocumentTile(
                title: t['title']!,
                imageAsset: assetByType[t['key']]!,
                doc: existing!,
                onUpload: () => _onUpload(t['key']!),
                onReplace: () => _onReplace(existing.id!),
                onDelete: () => _onDelete(existing.id!),
              ),
            ),
            if (i < types.length - 1) const SizedBox(height: 10),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: AppBar(
              elevation: 0,
              backgroundColor: Colors.white.withOpacity(0.7),
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF569109),
                      size: 28,
                    ),
                  ),
                  const Icon(
                    Icons.storefront_rounded,
                    size: 28,
                    color: Color(0xFF569109),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "My Docs",
                    style: TextStyle(
                      fontFamily: 'Starla',
                      fontSize: 22,
                      color: Color(0xFF569109),
                    ),
                  ),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: Container(height: 2, color: const Color(0xFF74CC00)),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/assets/images/my-docs-bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: _loading
            ? Center(
                child: LoadingAnimationWidget.inkDrop(
                  color: const Color(0xFF74CC00),
                  size: 60,
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 100),
                    _buildHeaderBox(),
                    const SizedBox(height: 18),
                    _buildDocsList(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}

/// Reusable document tile (no outer bg — outer wrapper sets background/height)
class DocumentTile extends StatelessWidget {
  final String title;
  final String imageAsset;
  final VendorDocument doc;
  final VoidCallback onUpload;
  final VoidCallback onReplace;
  final VoidCallback onDelete;

  const DocumentTile({
    super.key,
    required this.title,
    required this.imageAsset,
    required this.doc,
    required this.onUpload,
    required this.onReplace,
    required this.onDelete,
  });

  Widget _statusRow() {
    // returns icon + text depending on doc.status
    if (doc.fileUrl == null) {
      return Row(
        children: const [
          Icon(Icons.close, color: Color(0xFFDD602D), size: 20),
          SizedBox(width: 4),
          Text(
            'NO SUBMISSION',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Color(0xFFDD602D),
            ),
          ),
        ],
      );
    }

    if (doc.status == 'pending') {
      return Row(
        children: const [
          Iconify(Mdi.receipt_text_minus, color: Color(0xFFFF9E17), size: 20),
          SizedBox(width: 6),
          Text(
            'PENDING',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Color(0xFFFF9500),
            ),
          ),
        ],
      );
    }

    if (doc.status == 'approved') {
      return Row(
        children: const [
          Icon(Icons.check_circle, color: Color(0xFFFF9500), size: 20),
          SizedBox(width: 6),
          Text(
            'APPROVED',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Color(0xFFFF9500),
            ),
          ),
        ],
      );
    }

    // denied
    return Row(
      children: const [
        Icon(Icons.block, color: Color(0xFFDD602D)),
        SizedBox(width: 6),
        Text(
          'INVALID',
          style: TextStyle(fontFamily: 'Poppins', color: Color(0xFFDD602D)),
        ),
      ],
    );
  }

  Future<void> _viewFile(BuildContext context) async {
    if (doc.fileUrl == null) return;

    final url = Uri.parse(doc.fileUrl!);
    final lower = doc.fileUrl!.toLowerCase();

    // treat common image extensions as images
    final isImage =
        lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.gif') ||
        lower.contains('/image/');

    if (isImage) {
      // image preview dialog
      showDialog(
        context: context,
        builder: (_) => Dialog(
          child: InteractiveViewer(child: Image.network(doc.fileUrl!)),
        ),
      );
      return;
    }

    // otherwise open externally (PDF / DOC)
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open file')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final uploaded = doc.fileUrl != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 👉 Row 1: image + (title + status)
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // left: small image
            SizedBox(
              width: 64,
              child: Center(
                child: Image.asset(
                  imageAsset,
                  width: 55,
                  height: 55,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // right: title + status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Starla',
                      color: Color(0xFF276700),
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    doc.fileUrl != null && doc.uploadedAt != null
                        ? 'Uploaded on ${DateFormat("MMM dd, yyyy • h:mm a").format(doc.uploadedAt!.toLocal())}'
                        : 'FILE DOES NOT EXIST',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF325602),
                      fontSize: 11,
                    ),
                  ),

                  const SizedBox(height: 10),
                  _statusRow(),
                ],
              ),
            ),
          ],
        ),

        // 👉 Row 2: buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (doc.fileUrl == null)
              ElevatedButton(
                onPressed: onUpload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD800),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 4,
                  ),
                  minimumSize: const Size(0, 0),
                ),
                child: const Text(
                  'UPLOAD',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF792401),
                  ),
                ),
              )
            else ...[
              ElevatedButton(
                onPressed: () => _viewFile(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD800),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 4,
                  ),
                  minimumSize: const Size(0, 0),
                ),
                child: const Text(
                  'VIEW',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF792401),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: onReplace,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD800),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 4,
                  ),
                  minimumSize: const Size(0, 0),
                ),
                child: const Text(
                  'REPLACE',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF792401),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: onDelete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDD602D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 4,
                  ),
                  minimumSize: const Size(0, 0),
                ),
                child: const Text(
                  'DELETE',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
