import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/vendor.dart';
import '../../models/vendor_contact.dart';
import '../../models/vendor_product.dart';
import '../../services/vendor_service.dart';
import '../../services/cloudinary_service.dart';
import '../../services/validation_service.dart';
import '../../services/availability_check_service.dart';
import '../../utils/debouncer.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:iconify_flutter/icons/icon_park_solid.dart';
import 'package:iconify_flutter/icons/ph.dart';
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

  //For contact number nodes
  final _phoneFocus = FocusNode();
  final _phoneDebouncer = Debouncer();
  String? _phoneError;
  bool _phoneValid = true;
  bool _showHint = true;

  @override
  void dispose() {
    _phoneDebouncer.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  // Track locally edited products
  final Set<VendorProduct> _editedProducts = {};

  bool _isLoading = false;
  bool _isEditMode = false;
  bool _isUploadingImage = false;
  Vendor? _currentVendor;
  VendorProduct? _currentlyEditingProduct;

  @override
  void initState() {
    super.initState();
    _currentVendor = widget.vendor;
    _loadVendorData();
    _loadVendorProducts();
  }

  Future<void> _loadVendorData() async {
    try {
      final vendorData = await _vendorService.getVendorProfile(widget.vendorId);
      if (vendorData != null && mounted) {
        setState(() {
          _currentVendor = vendorData;
        });
        debugPrint(
          "[VendorMyShop] Loaded vendor data: ${_currentVendor?.toJson()}",
        );
      }
    } catch (e) {
      debugPrint("[VendorMyShop] Error loading vendor data: $e");
    }
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
                                                        "lib/assets/images/default_profile.jpg",
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
                                        fontSize: 13,
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
                                        label: _isEditMode
                                            ? "CANCEL"
                                            : "EDIT SHOP DETAILS",
                                        onTap: () {
                                          if (_isEditMode) {
                                            // Exit edit mode without saving
                                            setState(() {
                                              _isEditMode = false;
                                            });
                                          } else {
                                            _openEditShopDetails(context);
                                          }
                                        },
                                        backgroundColor: _isEditMode
                                            ? const Color(
                                                0xFFFFE5E5,
                                              ) // light red bg
                                            : const Color(
                                                0xFFFFD400,
                                              ), // default yellow bg
                                        textColor: _isEditMode
                                            ? const Color(
                                                0xFF8B0000,
                                              ) // dark red text
                                            : const Color(
                                                0xFF792401,
                                              ), // default brown text
                                      ),

                                      _buildActionButton(
                                        label: _isEditMode
                                            ? "SAVE CHANGES"
                                            : "EDIT TOP PRODUCTS",
                                        onTap: () async {
                                          if (_isEditMode) {
                                            final success =
                                                await _saveAllProductChanges();
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  success
                                                      ? "All changes saved successfully"
                                                      : "Some changes failed to save",
                                                ),
                                              ),
                                            );
                                          } else {
                                            setState(() {
                                              _isEditMode = true;
                                              _showHint = true;
                                            });
                                          }
                                        },
                                        backgroundColor: _isEditMode
                                            ? const Color(
                                                0xFFE0FABC,
                                              ) // light green for save
                                            : const Color(
                                                0xFFFFD400,
                                              ), // default yellow
                                        textColor: _isEditMode
                                            ? const Color(
                                                0xFF276700,
                                              ) // dark green text
                                            : const Color(
                                                0xFF792401,
                                              ), // default brown text
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // TOP PRODUCTS SECTION WHITE CONTAINER
                            // ------------------ TOP PRODUCTS SECTION ------------------
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Transform.translate(
                                offset: const Offset(0, -9),
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
                                            "SELLER'S TOP PICKS",
                                            style: TextStyle(
                                              fontFamily: "Bagel Fat One",
                                              fontSize: 20,
                                              color: Color(0xFFDD602D),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 4),

                                      // 🟡 Hint text visible only in edit mode
                                      if (_isEditMode && _showHint)
                                        Container(
                                          width: double.infinity,
                                          margin: const EdgeInsets.only(
                                            left: 4,
                                            top: 8,
                                            bottom: 10,
                                          ),
                                          padding: const EdgeInsets.all(9),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFE7D1),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFFDD602D),
                                              width: 1,
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 4,
                                                    ), // space for close button
                                                child: const Text(
                                                  "Hint:\n"
                                                  "💡 Tap once to open product details\n"
                                                  "💡 Double-tap the fields you want to edit.",
                                                  style: TextStyle(
                                                    fontFamily: "Poppins",
                                                    fontSize: 10.5,
                                                    color: Color(0xFF792401),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 0,
                                                right: 0,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _showHint = false;
                                                    });
                                                  },
                                                  child: const Icon(
                                                    Icons.close,
                                                    size: 14,
                                                    color: Color(0xFF792401),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                      if (!_isEditMode)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 8,
                                          ),
                                          child: SizedBox(
                                            width: double.infinity,
                                            child: TextButton(
                                              style: TextButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 10,
                                                    ),
                                                backgroundColor: const Color(
                                                  0xFFFFD400,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                alignment: Alignment.centerLeft,
                                              ),
                                              onPressed: () {
                                                if (_products
                                                        .where(
                                                          (p) =>
                                                              p.isFeatured ==
                                                              true,
                                                        )
                                                        .length >=
                                                    5) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        "You can only feature 5 top products for your shop! Delete an existing product first to replace them.",
                                                      ),
                                                      backgroundColor:
                                                          Colors.red,
                                                    ),
                                                  );
                                                } else {
                                                  _openAddProductDialog(
                                                    context,
                                                  );
                                                }
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: const [
                                                  Iconify(
                                                    Ph.plus_bold,
                                                    color: Color(0xFF792401),
                                                    size: 15,
                                                  ),
                                                  SizedBox(width: 6),
                                                  Text(
                                                    "Add",
                                                    style: TextStyle(
                                                      fontFamily: "Poppins",
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF792401),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),

                                      // FutureBuilder section
                                      FutureBuilder<List<VendorProduct>>(
                                        future: _vendorService.getTopProducts(
                                          widget.vendorId,
                                        ),
                                        builder: (context, snapshot) {
                                          // 1️⃣ Loading State
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 100,
                                                  ),
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
                                          }

                                          // 2️⃣ Error State
                                          if (snapshot.hasError) {
                                            return const Center(
                                              child: Text(
                                                "Failed to load products.",
                                              ),
                                            );
                                          }

                                          // 3️⃣ Success or Empty State
                                          if (snapshot.hasData) {
                                            // assign products to our state list if not yet loaded
                                            if (_products.isEmpty) {
                                              _products.addAll(snapshot.data!);
                                            }

                                            // if still empty → show ghost gif
                                            if (_products.isEmpty) {
                                              return Center(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Image.asset(
                                                      "lib/assets/icons/empty_ghost.gif",
                                                      height: 150,
                                                    ),
                                                    const Text(
                                                      "No top products yet.",
                                                      style: TextStyle(
                                                        color: Colors.black54,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20),
                                                  ],
                                                ),
                                              );
                                            }

                                            // ✅ Normal Display of Product List
                                            return ReorderableListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),

                                              itemCount: _products.length,
                                              onReorder: (oldIndex, newIndex) {
                                                setState(() {
                                                  if (newIndex > oldIndex)
                                                    newIndex--;
                                                  final item = _products
                                                      .removeAt(oldIndex);
                                                  _products.insert(
                                                    newIndex,
                                                    item,
                                                  );
                                                });
                                              },
                                              itemBuilder: (context, index) {
                                                final product =
                                                    _products[index];

                                                return GestureDetector(
                                                  key: ValueKey(product.id),
                                                  onTap: () =>
                                                      _openProductDialog(
                                                        context,
                                                        product,
                                                      ),
                                                  onDoubleTap: _isEditMode
                                                      ? () => _editProductField(
                                                          product,
                                                          "description",
                                                        )
                                                      : null,
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                          bottom: 10,
                                                        ),
                                                    padding:
                                                        const EdgeInsets.all(
                                                          10,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: _isEditMode
                                                          ? const Color(
                                                              0xFF792401,
                                                            )
                                                          : const Color(
                                                              0xFFDD602D,
                                                            ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Stack(
                                                      clipBehavior: Clip.none,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            // ✅ Product image
                                                            GestureDetector(
                                                              onDoubleTap:
                                                                  _isEditMode
                                                                  ? () async {
                                                                      final picked = await ImagePicker().pickImage(
                                                                        source:
                                                                            ImageSource.gallery,
                                                                      );
                                                                      if (picked !=
                                                                          null) {
                                                                        setState(() {
                                                                          product
                                                                              .imageUrl = picked
                                                                              .path;
                                                                          _editedProducts.add(
                                                                            product,
                                                                          );
                                                                        });
                                                                      }
                                                                    }
                                                                  : null,
                                                              child: Container(
                                                                width: 90,
                                                                height: 90,
                                                                decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                    color: const Color(
                                                                      0xFFFFD800,
                                                                    ),
                                                                    width: 4,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        5,
                                                                      ),
                                                                  image: DecorationImage(
                                                                    image:
                                                                        product.imageUrl?.startsWith(
                                                                              'http',
                                                                            ) ==
                                                                            true
                                                                        ? NetworkImage(
                                                                            product.imageUrl!,
                                                                          )
                                                                        : (product.imageUrl !=
                                                                                  null &&
                                                                              product.imageUrl!.isNotEmpty)
                                                                        ? FileImage(
                                                                            File(
                                                                              product.imageUrl!,
                                                                            ),
                                                                          )
                                                                        : const AssetImage(
                                                                                'lib/assets/icons/placeholder.png',
                                                                              )
                                                                              as ImageProvider,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              width: 16,
                                                            ),

                                                            // ✅ Product text
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
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
                                                                  const SizedBox(
                                                                    height: 6,
                                                                  ),

                                                                  // ✅ White background with fade-out at bottom
                                                                  Container(
                                                                    width: 168,
                                                                    height: 70,
                                                                    decoration: BoxDecoration(
                                                                      color: Colors
                                                                          .white,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            5,
                                                                          ),
                                                                    ),
                                                                    child: Stack(
                                                                      children: [
                                                                        // Description text
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.all(
                                                                                8,
                                                                              ),
                                                                          child: Text(
                                                                            product.description ??
                                                                                "No description",
                                                                            style: const TextStyle(
                                                                              fontSize: 11,
                                                                              color: Color(
                                                                                0xFFDD602D,
                                                                              ),
                                                                              fontWeight: FontWeight.w500,
                                                                            ),
                                                                            maxLines:
                                                                                3,
                                                                            overflow:
                                                                                TextOverflow.fade,
                                                                            softWrap:
                                                                                true,
                                                                          ),
                                                                        ),

                                                                        // Fade effect at the bottom
                                                                        Positioned(
                                                                          left:
                                                                              0,
                                                                          right:
                                                                              0,
                                                                          bottom:
                                                                              0,
                                                                          height:
                                                                              16,
                                                                          child: Container(
                                                                            decoration: BoxDecoration(
                                                                              gradient: LinearGradient(
                                                                                begin: Alignment.topCenter,
                                                                                end: Alignment.bottomCenter,
                                                                                colors: [
                                                                                  Colors.white.withOpacity(
                                                                                    0,
                                                                                  ),
                                                                                  Colors.white,
                                                                                ],
                                                                              ),
                                                                              borderRadius: const BorderRadius.vertical(
                                                                                bottom: Radius.circular(
                                                                                  5,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),

                                                        if (_isEditMode)
                                                          Positioned(
                                                            top: -7,
                                                            right: -5,
                                                            child: GestureDetector(
                                                              onTap: () =>
                                                                  _confirmDelete(
                                                                    context,
                                                                    product,
                                                                  ),
                                                              child: const Iconify(
                                                                IconParkSolid
                                                                    .delete_key,
                                                                size: 27,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          }

                                          // Fallback (no data)
                                          return const SizedBox.shrink();
                                        },
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
    Color backgroundColor = const Color(0xFFFFD400),
    Color textColor = const Color(0xFF792401),
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  //This edit field is for INSIDE EDIT SHOP DETAILS
  Widget _buildEditField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    int? maxLength, // new param
    FocusNode? focusNode,
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              if (maxLength != null)
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (context, value, _) {
                    return Text(
                      "${value.text.length}/$maxLength",
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'Poppins',
                        color: value.text.length > maxLength
                            ? Colors.red
                            : Colors.grey[600],
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            maxLines: maxLines,
            maxLength: maxLength,
            onChanged: onChanged,
            buildCounter:
                (_, {required currentLength, maxLength, required isFocused}) =>
                    null,
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
        ],
      ),
    );
  }

  // -----------------------------------------------------------------
  // THE VOID
  // -----------------------------------------------------------------
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
                              fontSize: 15,
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
                                                "lib/assets/images/default_profile.jpg",
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
                                    ? LoadingAnimationWidget.horizontalRotatingDots(
                                        color: Colors.white,
                                        size: 20,
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
                            maxLength: 20,
                          ),

                          _buildEditField(
                            "Facebook URL",
                            facebookController,
                            maxLength: 80,
                          ),

                          _buildEditField(
                            "Instagram URL",
                            instagramController,
                            maxLength: 80,
                          ),

                          _buildEditField(
                            "Website URL",
                            websiteController,
                            maxLength: 80,
                          ),

                          _buildEditField(
                            "TikTok URL",
                            tiktokController,
                            maxLength: 80,
                          ),

                          // ✅ Contact number with validation + debounce
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildEditField(
                                "Contact Number",
                                phoneController,
                                focusNode: _phoneFocus,
                                onChanged: (value) =>
                                    _onPhoneChanged(value, setModalState),
                                maxLength: 15,
                              ),
                              if (_phoneError != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8,
                                    bottom: 8,
                                  ),
                                  child: Text(
                                    _phoneError!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'Poppins',
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          _buildEditField(
                            "Business Description",
                            descriptionController,
                            maxLines: 3,
                            maxLength: 150,
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
                        onPressed:
                            _isLoading || getSelectedCount() > 3 || !_phoneValid
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

  void _onPhoneChanged(
    String value,
    void Function(VoidCallback fn) setModalState,
  ) {
    final formatError = ValidationService.validatePhoneFormat(value);
    if (formatError != null) {
      setModalState(() {
        _phoneError = formatError;
        _phoneValid = false;
      });
      return;
    }

    _phoneDebouncer.run(() async {
      final error = await AvailabilityCheckService.checkPhoneAvailability(
        value,
      );
      setModalState(() {
        _phoneError = error;
        _phoneValid = error == null;
      });
    });
  }

  // Open Add Product dialog
  void _openAddProductDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0xFF792401).withOpacity(0.95),
      builder: (context) {
        final TextEditingController nameController = TextEditingController();
        final TextEditingController descController = TextEditingController();
        XFile? pickedImage;
        bool isUploading = false;

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
                                // Upload image
                                Expanded(
                                  child: GestureDetector(
                                    onTap: isUploading
                                        ? null
                                        : () async {
                                            final picker = ImagePicker();
                                            final image = await picker
                                                .pickImage(
                                                  source: ImageSource.gallery,
                                                );
                                            if (image != null) {
                                              setState(() {
                                                pickedImage = image;
                                              });
                                            }
                                          },
                                    child: Container(
                                      padding: const EdgeInsets.only(top: 8),
                                      height: 230,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.white),
                                      ),
                                      child: pickedImage == null
                                          ? Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
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

                                // Right: name and description inputs
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // ==== PRODUCT NAME ====
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Name",
                                            style: TextStyle(
                                              fontFamily: "Poppins",
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 5,
                                              vertical: 1,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child:
                                                ValueListenableBuilder<
                                                  TextEditingValue
                                                >(
                                                  valueListenable:
                                                      nameController,
                                                  builder: (context, value, _) {
                                                    return Text(
                                                      "${value.text.length}/20",
                                                      style: const TextStyle(
                                                        color: Color(
                                                          0xFFDD602D,
                                                        ),
                                                        fontSize: 10,
                                                        fontFamily: "Poppins",
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    );
                                                  },
                                                ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: TextField(
                                          controller: nameController,
                                          maxLength: 20,
                                          style: const TextStyle(
                                            fontFamily: "Poppins",
                                            color: Color(0xFF792401),
                                          ),
                                          textAlignVertical:
                                              TextAlignVertical.center,
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "e.g. Handmade Necklace",
                                            hintStyle: TextStyle(
                                              fontFamily: "Poppins",
                                              fontSize: 12,
                                              color: Color(0xFFDD602D),
                                            ),
                                            counterText: "",
                                            isCollapsed: true,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      // ==== PRODUCT DESCRIPTION ====
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Description",
                                            style: TextStyle(
                                              fontFamily: "Poppins",
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 5,
                                              vertical: 1,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child:
                                                ValueListenableBuilder<
                                                  TextEditingValue
                                                >(
                                                  valueListenable:
                                                      descController,
                                                  builder: (context, value, _) {
                                                    return Text(
                                                      "${value.text.length}/150",
                                                      style: const TextStyle(
                                                        color: Color(
                                                          0xFFDD602D,
                                                        ),
                                                        fontSize: 10,
                                                        fontFamily: "Poppins",
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    );
                                                  },
                                                ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        height: 150,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: TextField(
                                          controller: descController,
                                          maxLength: 150,
                                          maxLines: null,
                                          style: const TextStyle(
                                            fontFamily: "Poppins",
                                            color: Color(0xFF792401),
                                          ),
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            hintText:
                                                "e.g. A beautiful handmade necklace perfect for any occasion.",
                                            hintStyle: TextStyle(
                                              fontFamily: "Poppins",
                                              fontSize: 12,
                                              color: Color(0xFFDD602D),
                                            ),
                                            counterText: "",
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
                      ),
                      const SizedBox(height: 16),

                      // Add product button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isUploading
                              ? const Color.fromARGB(255, 28, 3, 255)
                              : const Color(0xFFFFD400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        onPressed: isUploading
                            ? null
                            : () async {
                                if (nameController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please enter a product name',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                if (pickedImage == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please select a product image',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  isUploading = true;
                                });

                                try {
                                  final imageFile = File(pickedImage!.path);
                                  final result = await _cloudinaryService
                                      .uploadImage(imageFile);

                                  if (result == null) {
                                    throw Exception("Failed to upload image");
                                  }

                                  final response = await _vendorService
                                      .addProduct(
                                        vendorId: widget.vendorId,
                                        name: nameController.text.trim(),
                                        description:
                                            descController.text.trim().isEmpty
                                            ? null
                                            : descController.text.trim(),
                                        imageUrl: result.secureUrl,
                                        isFeatured: true,
                                      );

                                  if (response['success'] == true) {
                                    Navigator.pop(context);
                                    await _loadVendorProducts();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Product added successfully!',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          response['message'] ??
                                              "Failed to add product",
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  print('[v0] Error adding product: $e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Error: ${e.toString()}"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                } finally {
                                  setState(() {
                                    isUploading = false;
                                  });
                                }
                              },
                        child: isUploading
                            ? LoadingAnimationWidget.horizontalRotatingDots(
                                color: Colors.white,
                                size: 20,
                              )
                            : const Text(
                                "Add Top Product",
                                style: TextStyle(
                                  fontFamily: "Poppins",
                                  color: Color(0xFF792401),
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),

                  // Close button
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
                            onPressed: isUploading
                                ? null
                                : () => Navigator.pop(context),
                            icon: const Iconify(
                              IconParkSolid.delete_key,
                              size: 30,
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
      barrierDismissible: false,
      barrierColor: const Color(0xFF792401).withOpacity(0.95),
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: Container(
            padding: const EdgeInsets.fromLTRB(16, 25, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Delete Product",
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFDD602D),
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                const Text(
                  "Are you sure you want to delete this product?",
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 13,
                    color: Color(0xFF792401),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        foregroundColor: const Color(0xFFDD602D),
                        side: const BorderSide(color: Color(0xFFDD602D)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        backgroundColor: const Color(0xFFDD602D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);

                        final success = await _vendorService.deleteProduct(
                          product.id,
                        );

                        if (!mounted) return;

                        if (success) {
                          if (product.imageUrl != null &&
                              product.imageUrl!.isNotEmpty) {
                            final cloudinary = CloudinaryService();
                            final publicId = cloudinary.extractPublicId(
                              product.imageUrl!,
                            );

                            if (publicId.isNotEmpty) {
                              await cloudinary.deleteImage(publicId);
                            }
                          }

                          await _loadVendorProducts();
                          setState(() {
                            _isEditMode = false;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Product deleted successfully"),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Failed to delete product"),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        "Delete",
                        style: TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Edit product name or description
  void _editProductField(VendorProduct product, String field) {
    final maxLength = field == "name" ? 20 : 150;
    final controller = TextEditingController(
      text: field == 'name' ? product.name : product.description,
    );

    showDialog(
      barrierColor: const Color(0xFF792401).withOpacity(0.95),
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              content: Container(
                padding: const EdgeInsets.fromLTRB(16, 25, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Edit ${field[0].toUpperCase()}${field.substring(1)}",
                        style: const TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFDD602D),
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Input field with char limit
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color.fromARGB(99, 221, 95, 45),
                        ),
                      ),
                      child: TextField(
                        controller: controller,
                        maxLength: maxLength,
                        maxLines: field == "description" ? 3 : 1,
                        onChanged: (_) => setStateDialog(() {}),
                        style: const TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 12,
                          color: Color(0xFF792401),
                        ),
                        decoration: InputDecoration(
                          counterText: "", // hide default counter
                          border: InputBorder.none,
                          hintText: "Enter $field",
                          hintStyle: const TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 12,
                            color: Color(0xFFDD602D),
                          ),
                        ),
                      ),
                    ),

                    // Custom counter below input
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "${controller.text.length} / $maxLength",
                        style: const TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 11,
                          color: Color(0xFFDD602D),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            foregroundColor: const Color(0xFFDD602D),
                            side: const BorderSide(color: Color(0xFFDD602D)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => Navigator.of(dialogCtx).pop(),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            backgroundColor: const Color(0xFFDD602D),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(dialogCtx).pop();
                            final newValue = controller.text.trim();
                            setState(() {
                              if (field == "name") {
                                product.name = newValue;
                              } else {
                                product.description = newValue;
                              }
                              _editedProducts.add(product);
                            });
                          },
                          child: const Text(
                            "Enter Changes",
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // View product details in a dialog
  void _openProductDialog(BuildContext context, VendorProduct product) {
    showDialog(
      context: context,
      barrierColor: const Color(0xFF792401).withOpacity(0.95),
      builder: (context) {
        final double dialogWidth = MediaQuery.of(context).size.width * 0.8;

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Center(
            child: Container(
              width: dialogWidth,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFDD602D),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Product Image
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFFFD400),
                        width: 4,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: product.imageUrl!.startsWith('http')
                            ? NetworkImage(product.imageUrl!)
                            : FileImage(File(product.imageUrl!))
                                  as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Product Name
                  Text(
                    product.name ?? "Unnamed Product",
                    style: const TextStyle(
                      fontFamily: "Starla",
                      fontSize: 18,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),

                  // Product Description with white background
                  Container(
                    constraints: const BoxConstraints(maxHeight: 140),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        product.description ??
                            "No description available for this product.",
                        style: const TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 12,
                          color: Color(0xFFDD602D),
                          height: 1.5,
                          fontWeight: FontWeight.w400, // More weight
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Close Button
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD400),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Close",
                      style: TextStyle(
                        fontFamily: "Poppins",
                        color: Color(0xFF792401),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadVendorProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use VendorService method to fetch vendor products
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

  Future<bool> _saveAllProductChanges() async {
    bool allSuccess = true;

    for (final product in _editedProducts) {
      final success = await _vendorService.updateTopProducts(product);
      if (!success) allSuccess = false;
    }

    if (!mounted) return allSuccess;

    if (allSuccess) {
      setState(() {
        _isEditMode = false;
        _editedProducts.clear();
      });

      await _loadVendorProducts();
    }

    return allSuccess;
  }

  // Pick & upload vendor logo (profile picture)
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
        final result = await _cloudinaryService.uploadImage(imageFile);

        if (result != null) {
          final updatedVendor = Vendor(
            id: _currentVendor?.id ?? "Unknown",
            businessName: _currentVendor?.businessName ?? "",
            description: _currentVendor?.description,
            logoUrl: result.secureUrl,
            socialLinks: _currentVendor?.socialLinks ?? SocialLinks(),
            verified: _currentVendor?.verified ?? false,
            businessCategory: _currentVendor?.businessCategory,
            createdAt: _currentVendor?.createdAt ?? DateTime.now(),
            contact: _currentVendor?.contact,
          );

          final success = await _vendorService.updateVendorProfile(
            updatedVendor,
          );

          if (success) {
            setState(() {
              _currentVendor = updatedVendor;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Profile picture updated successfully!"),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Failed to update profile picture."),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to upload image. Please try again."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('[v0] Error picking/uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }
}
