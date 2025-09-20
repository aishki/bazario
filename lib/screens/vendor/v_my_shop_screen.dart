import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/vendor.dart';
import '../../models/vendor_contact.dart';
import '../../models/vendor_product.dart';
import '../../services/vendor_service.dart';
import '../../services/cloudinary_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:iconify_flutter/icons/icon_park_solid.dart';
import 'package:iconify_flutter/icons/prime.dart';
import 'package:iconify_flutter/icons/ic.dart';

class VendorMyShop extends StatefulWidget {
  final String userId;
  final String vendorId;
  final String businessName;
  final Vendor vendor;

  const VendorMyShop({
    super.key,
    required this.userId,
    required this.vendorId,
    required this.businessName,
    required this.vendor,
  });

  @override
  State<VendorMyShop> createState() => _VendorMyShopState();
}

class _VendorMyShopState extends State<VendorMyShop> {
  final List<VendorProduct> _products = [];
  final VendorService _vendorService = VendorService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;
  bool _isEditMode = false;
  bool _isUploadingImage = false;
  Vendor? _currentVendor;
  VendorProduct? _currentlyEditingProduct;

  @override
  void initState() {
    super.initState();
    _currentVendor = widget.vendor;
    _loadVendorProducts();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("[VendorMyShop] Current Vendor: ${_currentVendor?.toJson()}");

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/assets/images/my-shop-bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                  left: 16,
                  right: 16,
                  bottom: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFFFF390F),
                            size: 28,
                          ),
                        ),
                        const Icon(
                          SolarIconsBold.shop,
                          size: 28,
                          color: Color(0xFFFF390F),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "My Shop",
                          style: TextStyle(
                            fontFamily: 'Starla',
                            fontSize: 22,
                            color: Color(0xFFFF390F),
                          ),
                        ),
                      ],
                    ),

                    // Orange + White stacked
                    Stack(
                      clipBehavior: Clip
                          .none, // 👈 allows white container to overflow upwards
                      children: [
                        Column(
                          children: [
                            // Orange container
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(
                                10,
                                30,
                                10,
                                16,
                              ),
                              decoration: const BoxDecoration(
                                color: Color(0xFFDD602D),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  topRight: Radius.circular(24),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Profile + Socials row
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Profile circle
                                      Container(
                                        margin: const EdgeInsets.only(left: 10),
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 3,
                                          ),
                                          image: DecorationImage(
                                            image:
                                                _currentVendor?.logoUrl !=
                                                        null &&
                                                    _currentVendor!
                                                        .logoUrl!
                                                        .isNotEmpty
                                                ? NetworkImage(
                                                    _currentVendor!.logoUrl!,
                                                  )
                                                : const AssetImage(
                                                        "lib/assets/images/logo_img.jpg",
                                                      )
                                                      as ImageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 30),

                                      // Business name + socials
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _currentVendor?.businessName ??
                                                  "Unknown",
                                              style: const TextStyle(
                                                fontFamily: 'Starla',
                                                fontSize: 18,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 8),

                                            // Social Links
                                            if (_currentVendor
                                                    ?.contactDisplayPreferences
                                                    .showInstagram ??
                                                false) ...[
                                              Row(
                                                children: [
                                                  Iconify(
                                                    Mdi.instagram,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    _currentVendor
                                                            ?.socialLinks
                                                            .instagram ??
                                                        "Not added yet",
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                            ],

                                            if (_currentVendor
                                                    ?.contactDisplayPreferences
                                                    .showFacebook ??
                                                false) ...[
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.facebook,
                                                    size: 18,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    _currentVendor
                                                            ?.socialLinks
                                                            .facebook ??
                                                        "Not added yet",
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                            ],

                                            if (_currentVendor
                                                    ?.contactDisplayPreferences
                                                    .showPhone ??
                                                false) ...[
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.phone,
                                                    size: 18,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    _currentVendor
                                                            ?.contact
                                                            ?.phoneNumber ??
                                                        "Not added yet",
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                            ],

                                            if (_currentVendor
                                                    ?.contactDisplayPreferences
                                                    .showWebsite ??
                                                false) ...[
                                              Row(
                                                children: [
                                                  Iconify(
                                                    Prime.globe,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    _currentVendor
                                                            ?.socialLinks
                                                            .website ??
                                                        "Not added yet",
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                            ],

                                            if (_currentVendor
                                                    ?.contactDisplayPreferences
                                                    .showTiktok ??
                                                false) ...[
                                              Row(
                                                children: [
                                                  Iconify(
                                                    Ic.baseline_tiktok,
                                                    size: 18,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    _currentVendor
                                                            ?.socialLinks
                                                            .tiktok ??
                                                        "Not added yet",
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                            ],

                                            if (_currentVendor
                                                    ?.contactDisplayPreferences
                                                    .showTwitter ??
                                                false) ...[
                                              Row(
                                                children: [
                                                  Iconify(
                                                    Prime.twitter,
                                                    size: 18,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    _currentVendor
                                                            ?.socialLinks
                                                            .twitter ??
                                                        "Not added yet",
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // Description container inside orange container
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(230),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _currentVendor?.description ??
                                          "Shop description not yet added...",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Buttons inside orange container
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildActionButton(
                                        label: "EDIT SHOP DETAILS",
                                        onTap: () =>
                                            _openEditShopDetails(context),
                                      ),
                                      _buildActionButton(
                                        label: _isEditMode
                                            ? "SAVE CHANGES"
                                            : "EDIT TOP PRODUCTS",
                                        onTap: () {
                                          if (_isEditMode &&
                                              _currentlyEditingProduct !=
                                                  null) {
                                            _saveProductChanges(
                                              _currentlyEditingProduct!,
                                            );
                                          } else {
                                            setState(() {
                                              _isEditMode = true;
                                            });
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // White container overlapping
                            Positioned(
                              top: null,
                              bottom: 0, // pin to bottom of orange
                              left: 0,
                              right: 0,
                              child: Transform.translate(
                                offset: const Offset(0, -9), // overlap depth
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFFFFFFF,
                                    ).withOpacity(0.75),
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(16),
                                      bottomRight: Radius.circular(16),
                                    ),
                                    border: Border.all(
                                      color: const Color(0xFFDD602D),
                                      width: 7,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Header row
                                      Row(
                                        children: const [
                                          Icon(
                                            SolarIconsBold.shop,
                                            size: 28,
                                            color: Color(0xFFDD602D),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            "TOP PRODUCTS",
                                            style: TextStyle(
                                              fontFamily: "Bagel Fat One",
                                              fontSize: 20,
                                              color: Color(0xFFDD602D),
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Scrollable products
                                      FutureBuilder<List<VendorProduct>>(
                                        future: _vendorService.getTopProducts(
                                          widget.vendorId,
                                        ),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 100,
                                                  ), // top + bottom
                                              child: Center(
                                                child:
                                                    LoadingAnimationWidget.inkDrop(
                                                      color: const Color(
                                                        0xFFDD602D,
                                                      ),
                                                      size: 50,
                                                    ),
                                              ),
                                            );
                                          } else if (snapshot.hasError) {
                                            return const Center(
                                              child: Text(
                                                "Failed to load products.",
                                              ),
                                            );
                                          } else if (!snapshot.hasData ||
                                              snapshot.data!.isEmpty) {
                                            return const Center(
                                              child: Text(
                                                "No top products yet.",
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            );
                                          }

                                          final _products = snapshot.data!;
                                          return ReorderableListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            padding: const EdgeInsets.only(
                                              top: 13,
                                            ),
                                            itemCount: _products.length,
                                            onReorder: (oldIndex, newIndex) {
                                              setState(() {
                                                if (newIndex > oldIndex)
                                                  newIndex--;
                                                final item = _products.removeAt(
                                                  oldIndex,
                                                );
                                                _products.insert(
                                                  newIndex,
                                                  item,
                                                );
                                              });
                                            },
                                            itemBuilder: (context, index) {
                                              final product = _products[index];
                                              return Container(
                                                key: ValueKey(product.id),
                                                margin: const EdgeInsets.only(
                                                  bottom: 10,
                                                ),
                                                padding: const EdgeInsets.all(
                                                  10,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _isEditMode
                                                      ? const Color(0xFF792401)
                                                      : const Color(0xFFDD602D),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Stack(
                                                  children: [
                                                    Row(
                                                      children: [
                                                        // Image
                                                        Container(
                                                          width: 90,
                                                          height: 90,
                                                          decoration: BoxDecoration(
                                                            border: Border.all(
                                                              color:
                                                                  const Color(
                                                                    0xFFFFD800,
                                                                  ),
                                                              width: 4,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  5,
                                                                ),
                                                            image: DecorationImage(
                                                              image: NetworkImage(
                                                                product.imageUrl ??
                                                                    "https://via.placeholder.com/150",
                                                              ),
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 16,
                                                        ),

                                                        // Details
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              GestureDetector(
                                                                onDoubleTap:
                                                                    _isEditMode
                                                                    ? () => _editProductField(
                                                                        product,
                                                                        "name",
                                                                      )
                                                                    : null,
                                                                child: Text(
                                                                  product.name ??
                                                                      "No Name Provided",
                                                                  style: const TextStyle(
                                                                    fontFamily:
                                                                        "Starla",
                                                                    fontSize:
                                                                        15,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 6,
                                                              ),
                                                              GestureDetector(
                                                                onDoubleTap:
                                                                    _isEditMode
                                                                    ? () => _editProductField(
                                                                        product,
                                                                        "description",
                                                                      )
                                                                    : null,
                                                                child: Container(
                                                                  padding:
                                                                      const EdgeInsets.all(
                                                                        8,
                                                                      ),
                                                                  decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          5,
                                                                        ),
                                                                  ),
                                                                  child: Text(
                                                                    product.description ??
                                                                        "No description",
                                                                    style: const TextStyle(
                                                                      fontSize:
                                                                          11,
                                                                      color: Color(
                                                                        0xDDDD602D,
                                                                      ),
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                    ),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    maxLines: 3,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),

                                                    // Delete icon
                                                    if (_isEditMode)
                                                      Positioned(
                                                        top: 0,
                                                        right: 0,
                                                        child: GestureDetector(
                                                          onTap: () =>
                                                              _confirmDelete(
                                                                context,
                                                                product,
                                                              ),
                                                          child: const Iconify(
                                                            IconParkSolid
                                                                .delete_key,
                                                            size: 30,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),

                                      // Add button at bottom
                                      Align(
                                        alignment: Alignment.center,
                                        child: GestureDetector(
                                          onTap: () {
                                            _openAddProductDialog(context);
                                          },
                                          child: Image.asset(
                                            "lib/assets/icons/add.png",
                                            width: 30,
                                            height: 30,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD400),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Color(0xFF792401),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _isUploadingImage = true;
        });

        final imageFile = File(image.path);
        final imageUrl = await _cloudinaryService.uploadImage(imageFile);

        if (imageUrl != null) {
          // Update the vendor with new logo URL
          final updatedVendor = Vendor(
            id: _currentVendor?.id ?? "Unknown",
            businessName: _currentVendor?.businessName ?? "",
            description: _currentVendor?.description,
            logoUrl: imageUrl, // Set new Cloudinary URL
            socialLinks: _currentVendor?.socialLinks ?? SocialLinks(),
            verified: _currentVendor?.verified ?? false,
            businessCategory: _currentVendor?.businessCategory,
            createdAt: _currentVendor?.createdAt ?? DateTime.now(),
            contact: _currentVendor?.contact,
          );

          bool success = await _vendorService.updateVendorProfile(
            updatedVendor,
          );

          if (success) {
            setState(() {
              _currentVendor = updatedVendor;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile picture updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to update profile picture.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to upload image. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('[v0] Error picking/uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  void _openEditShopDetails(BuildContext context) {
    final businessNameController = TextEditingController(
      text: _currentVendor?.businessName,
    );
    final facebookController = TextEditingController(
      text: _currentVendor?.socialLinks.facebook ?? '',
    );
    final instagramController = TextEditingController(
      text: _currentVendor?.socialLinks.instagram ?? '',
    );
    final phoneController = TextEditingController(
      text: _currentVendor?.contact?.phoneNumber ?? '',
    );
    final descriptionController = TextEditingController(
      text: _currentVendor?.description ?? '',
    );
    final websiteController = TextEditingController(
      text: _currentVendor?.socialLinks.website ?? '',
    );
    final tiktokController = TextEditingController(
      text: _currentVendor?.socialLinks.tiktok ?? '',
    );

    bool showInstagram =
        _currentVendor?.contactDisplayPreferences.showInstagram ?? true;
    bool showFacebook =
        _currentVendor?.contactDisplayPreferences.showFacebook ?? true;
    bool showPhone =
        _currentVendor?.contactDisplayPreferences.showPhone ?? true;
    bool showWebsite =
        _currentVendor?.contactDisplayPreferences.showWebsite ?? false;
    bool showTiktok =
        _currentVendor?.contactDisplayPreferences.showTiktok ?? false;
    bool showTwitter =
        _currentVendor?.contactDisplayPreferences.showTwitter ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            int getSelectedCount() {
              int count = 0;
              if (showInstagram) count++;
              if (showFacebook) count++;
              if (showPhone) count++;
              if (showWebsite) count++;
              if (showTiktok) count++;
              if (showTwitter) count++;
              return count;
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.80,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                        const Expanded(
                          child: Text(
                            "Edit Shop Details",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48), // Balance the close button
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        bottom:
                            MediaQuery.of(ctx).viewInsets.bottom +
                            100, // Extra space for navbar
                      ),
                      child: Column(
                        children: [
                          // Profile Pic + Edit (centered horizontally)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(left: 10),
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  image: DecorationImage(
                                    image:
                                        _currentVendor?.logoUrl != null &&
                                            _currentVendor!.logoUrl!.isNotEmpty
                                        ? NetworkImage(_currentVendor!.logoUrl!)
                                        : const AssetImage(
                                                "lib/assets/images/logo_img.jpg",
                                              )
                                              as ImageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),

                              OutlinedButton.icon(
                                onPressed: _isUploadingImage
                                    ? null
                                    : _pickAndUploadImage,
                                icon: _isUploadingImage
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.edit,
                                        size: 16,
                                        color: Color(0xFF2E7D32),
                                      ), // green
                                label: const Text(
                                  "Edit Picture",
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 13,
                                    color: Color(0xFF2E7D32), // green text
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor:
                                      Colors.grey[200], // light gray bg
                                  side: BorderSide.none, // remove border
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          _buildEditField(
                            "Business Name",
                            businessNameController,
                          ),
                          _buildEditField("Facebook URL", facebookController),
                          _buildEditField("Instagram URL", instagramController),
                          _buildEditField("Website URL", websiteController),
                          _buildEditField("TikTok URL", tiktokController),
                          _buildEditField("Contact Number", phoneController),
                          _buildEditField(
                            "Business Description",
                            descriptionController,
                            maxLines: 3,
                          ),

                          const SizedBox(height: 20),

                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Contact Display Settings \n(Select up to 3)",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: "Poppins",
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Selected: ${getSelectedCount()}/3",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: "Poppins",
                                    color: getSelectedCount() > 3
                                        ? Colors.red
                                        : Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 12),

                                CheckboxListTile(
                                  title: const Row(
                                    children: [
                                      Icon(
                                        Icons.camera_alt,
                                        size: 18,
                                        color: Colors.black54,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Instagram",
                                        style: TextStyle(fontFamily: "Poppins"),
                                      ),
                                    ],
                                  ),
                                  value: showInstagram,
                                  onChanged: (value) {
                                    if (value == true ||
                                        getSelectedCount() > 1) {
                                      setModalState(() {
                                        showInstagram = value ?? false;
                                      });
                                    }
                                  },
                                  dense: true,
                                ),

                                CheckboxListTile(
                                  title: const Row(
                                    children: [
                                      Icon(
                                        Icons.facebook,
                                        size: 18,
                                        color: Colors.black54,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Facebook",
                                        style: TextStyle(fontFamily: "Poppins"),
                                      ),
                                    ],
                                  ),
                                  value: showFacebook,
                                  onChanged: (value) {
                                    if (value == true ||
                                        getSelectedCount() > 1) {
                                      setModalState(() {
                                        showFacebook = value ?? false;
                                      });
                                    }
                                  },
                                  dense: true,
                                ),

                                CheckboxListTile(
                                  title: const Row(
                                    children: [
                                      Icon(
                                        Icons.phone,
                                        size: 18,
                                        color: Colors.black54,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Phone Number",
                                        style: TextStyle(fontFamily: "Poppins"),
                                      ),
                                    ],
                                  ),
                                  value: showPhone,
                                  onChanged: (value) {
                                    if (value == true ||
                                        getSelectedCount() > 1) {
                                      setModalState(() {
                                        showPhone = value ?? false;
                                      });
                                    }
                                  },
                                  dense: true,
                                ),

                                CheckboxListTile(
                                  title: const Row(
                                    children: [
                                      Iconify(
                                        Prime.globe,
                                        size: 18,
                                        color: Colors.black54,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Website",
                                        style: TextStyle(fontFamily: "Poppins"),
                                      ),
                                    ],
                                  ),
                                  value: showWebsite,
                                  onChanged: (value) {
                                    if (value == false ||
                                        getSelectedCount() < 3) {
                                      setModalState(() {
                                        showWebsite = value ?? false;
                                      });
                                    }
                                  },
                                  dense: true,
                                ),

                                CheckboxListTile(
                                  title: const Row(
                                    children: [
                                      Iconify(
                                        Ic.baseline_tiktok,
                                        size: 18,
                                        color: Colors.black54,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "TikTok",
                                        style: TextStyle(fontFamily: "Poppins"),
                                      ),
                                    ],
                                  ),
                                  value: showTiktok,
                                  onChanged: (value) {
                                    if (value == false ||
                                        getSelectedCount() < 3) {
                                      setModalState(() {
                                        showTiktok = value ?? false;
                                      });
                                    }
                                  },
                                  dense: true,
                                ),

                                CheckboxListTile(
                                  title: const Row(
                                    children: [
                                      Iconify(
                                        Prime.twitter,
                                        size: 18,
                                        color: Colors.black54,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Twitter",
                                        style: TextStyle(fontFamily: "Poppins"),
                                      ),
                                    ],
                                  ),
                                  value: showTwitter,
                                  onChanged: (value) {
                                    if (value == false ||
                                        getSelectedCount() < 3) {
                                      setModalState(() {
                                        showTwitter = value ?? false;
                                      });
                                    }
                                  },
                                  dense: true,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Colors.grey[200]!)),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading || getSelectedCount() > 3
                            ? null
                            : () async {
                                setModalState(() {
                                  _isLoading = true;
                                });

                                try {
                                  final updatedVendor = Vendor(
                                    id: _currentVendor?.id ?? "Unknown",
                                    businessName: businessNameController.text,
                                    description:
                                        descriptionController.text.isEmpty
                                        ? null
                                        : descriptionController.text,
                                    logoUrl: _currentVendor?.logoUrl,
                                    socialLinks: SocialLinks(
                                      facebook: facebookController.text.isEmpty
                                          ? null
                                          : facebookController.text,
                                      instagram:
                                          instagramController.text.isEmpty
                                          ? null
                                          : instagramController.text,
                                      website: websiteController.text.isEmpty
                                          ? null
                                          : websiteController.text,
                                      tiktok: tiktokController.text.isEmpty
                                          ? null
                                          : tiktokController.text,
                                      twitter:
                                          _currentVendor?.socialLinks.twitter,
                                      youtube:
                                          _currentVendor?.socialLinks.youtube,
                                    ),
                                    verified: _currentVendor?.verified ?? false,
                                    businessCategory:
                                        _currentVendor?.businessCategory,
                                    createdAt:
                                        _currentVendor?.createdAt ??
                                        DateTime.now(),
                                    contact: _currentVendor?.contact != null
                                        ? VendorContact(
                                            firstName: _currentVendor
                                                ?.contact
                                                ?.firstName,
                                            middleName: _currentVendor
                                                ?.contact
                                                ?.middleName,
                                            lastName: _currentVendor
                                                ?.contact
                                                ?.lastName,
                                            suffix:
                                                _currentVendor?.contact?.suffix,
                                            phoneNumber:
                                                phoneController.text.isEmpty
                                                ? null
                                                : phoneController.text,
                                            email:
                                                _currentVendor?.contact?.email,
                                            position: _currentVendor
                                                ?.contact
                                                ?.position,
                                            createdAt: _currentVendor
                                                ?.contact
                                                ?.createdAt,
                                          )
                                        : phoneController.text.isNotEmpty
                                        ? VendorContact(
                                            phoneNumber: phoneController.text,
                                          )
                                        : null,
                                    contactDisplayPreferences:
                                        ContactDisplayPreferences(
                                          showInstagram: showInstagram,
                                          showFacebook: showFacebook,
                                          showPhone: showPhone,
                                          showWebsite: showWebsite,
                                          showTiktok: showTiktok,
                                          showTwitter: showTwitter,
                                        ),
                                  );

                                  // Update vendor via API
                                  bool success = await _vendorService
                                      .updateVendorProfile(updatedVendor);

                                  if (success) {
                                    setState(() {
                                      _currentVendor = updatedVendor;
                                    });

                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Shop details updated successfully!',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Failed to update shop details. Please try again.',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  print('[v0] Error updating vendor: $e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                } finally {
                                  setModalState(() {
                                    _isLoading = false;
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Save Changes",
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openAddProductDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0xFF792401).withOpacity(0.95),
      builder: (context) {
        final TextEditingController descController = TextEditingController();
        XFile? pickedImage;

        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 16),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Orange container
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDD602D),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // Left: Upload image
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      final picker = ImagePicker();
                                      final image = await picker.pickImage(
                                        source: ImageSource.gallery,
                                      );
                                      if (image != null) {
                                        setState(() => pickedImage = image);
                                      }
                                    },
                                    child: Container(
                                      height: 200,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.white),
                                      ),
                                      child: pickedImage == null
                                          ? Center(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: const [
                                                  Icon(
                                                    SolarIconsBold.upload,
                                                    size: 28,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    "UPLOAD PRODUCT IMAGE HERE",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontFamily: "Starla",
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            )
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.file(
                                                File(pickedImage!.path),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Right: description input
                                Expanded(
                                  child: Container(
                                    height: 150,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: TextField(
                                        controller: descController,
                                        maxLines: null,
                                        style: const TextStyle(
                                          fontFamily: "Poppins",
                                          color: Color(0xFF792401),
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          hintText:
                                              "Type your top product description here...",
                                          hintStyle: TextStyle(
                                            fontFamily: "Poppins",
                                            fontSize: 12,
                                            color: Color(0xFFDD602D),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Add product button OUTSIDE the orange container
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () async {
                          if (pickedImage != null &&
                              descController.text.trim().isNotEmpty) {
                            // TODO: Upload image → get URL
                            // TODO: Save {imageUrl, description} to DB
                            Navigator.pop(context); // close modal
                            setState(() {}); // refresh UI
                          }
                        },
                        child: const Text(
                          "Add Top Product",
                          style: TextStyle(
                            fontFamily: "Poppins",
                            color: Color(0xFF792401),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Close button in the top-right corner (clipped)
                  Positioned(
                    top: -10,
                    right: -12,
                    child: SizedBox(
                      height: 30,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(20),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => Navigator.pop(context),
                            icon: const Iconify(
                              size: 30,
                              IconParkSolid.delete_key,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext pageContext, VendorProduct product) {
    showDialog(
      context: context, // <- parent page context
      builder: (ctx) {
        return AlertDialog(
          title: Text("Delete Product"),
          content: Text("Are you sure you want to delete this product?"),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx); // Close dialog immediately

                final success = await _vendorService.deleteProduct(product.id);

                if (!mounted) return;

                if (success) {
                  await _loadVendorProducts();

                  // ✅ Use parent `context`, not ctx
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Product deleted successfully")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to delete product")),
                  );
                }
              },
              child: Text("Delete"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadVendorProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Assuming VendorService has a method to fetch vendor products
      final products = await _vendorService.getTopProducts(widget.vendorId);

      if (mounted) {
        setState(() {
          _products
            ..clear()
            ..addAll(products);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      debugPrint("Error loading vendor products: $e");
    }
  }

  Future<bool> _saveProductChanges(VendorProduct product) async {
    final success = await _vendorService.updateTopProducts(product);
    if (!mounted) return success;
    if (success && mounted) {
      setState(() {
        _isEditMode = false;
      });
    }

    return success;
  }

  // call signature: _editProductField(product, "name" / "description")
  void _editProductField(VendorProduct product, String field) {
    final controller = TextEditingController(
      text: field == 'name' ? product.name : product.description,
    );

    // Use the State's `context` to create the dialog. Inside builder
    // use `dialogCtx` to immediately pop/close the dialog.
    showDialog(
      context: context, // <- use State.context (safe)
      builder: (dialogCtx) {
        return AlertDialog(
          title: Text("Edit ${field[0].toUpperCase()}${field.substring(1)}"),
          content: TextField(
            controller: controller,
            maxLines: field == "description" ? 3 : 1,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: "Enter $field",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                // 1) Close the dialog IMMEDIATELY with the dialog's ctx
                Navigator.of(dialogCtx).pop();

                // 2) Apply the change locally (optimistic update)
                final newValue = controller.text.trim();
                setState(() {
                  if (field == "name") {
                    product.name = newValue;
                  } else {
                    product.description = newValue;
                  }
                });

                // 3) Persist asynchronously
                final success = await _saveProductChanges(product);

                // 4) If the widget is disposed while awaiting, bail out
                if (!mounted) return;

                // 5) Refresh the _products list safely (re-fetch)
                await _loadVendorProducts();

                // 6) Use the State.context (not item/dialog ctx) to show snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? "${field[0].toUpperCase()}${field.substring(1)} updated"
                          : "Failed to update ${field}",
                    ),
                  ),
                );
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: controller,
              maxLines: maxLines,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                hintStyle: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: Colors.grey,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.black26, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Colors.deepOrange,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
