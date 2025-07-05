import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

import '../models/photo_item_model.dart';
import '../utils/theme/theme.dart';

class GalleryPicker extends StatefulWidget {
  final Function(PhotoItem?) onPhotoSelected;

  const GalleryPicker({
    Key? key,
    required this.onPhotoSelected,
  }) : super(key: key);

  @override
  State<GalleryPicker> createState() => _GalleryPickerState();
}

class _GalleryPickerState extends State<GalleryPicker> {
  List<PhotoItem> recentPhotos = [];
  List<PhotoItem> galleryPhotos = [];
  PhotoItem? selectedPhoto;
  String selectedTab = 'Recents';
  final ImagePicker _picker = ImagePicker();
  bool _isLoadingGallery = false;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _requestPermissionAndLoadGallery() async {
    setState(() {
      _isLoadingGallery = true;
      _permissionDenied = false;
    });

    try {
      // Request permission to access photos
      final PermissionState result =
          await PhotoManager.requestPermissionExtend();

      if (result.isAuth) {
        await _loadGalleryPhotos();
      } else {
        setState(() {
          _permissionDenied = true;
        });
      }
    } catch (e) {
      setState(() {
        _permissionDenied = true;
      });
      print('Error requesting permission: $e');
    } finally {
      setState(() {
        _isLoadingGallery = false;
      });
    }
  }

  Future<void> _loadGalleryPhotos() async {
    try {
      // Get photo albums
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true,
      );

      if (albums.isNotEmpty) {
        // Get photos from the main album (usually "Recent" or "All Photos")
        final AssetPathEntity album = albums.first;
        final List<AssetEntity> assets = await album.getAssetListPaged(
          page: 0,
          size: 100, // Load first 100 photos
        );

        // Convert AssetEntity to PhotoItem
        final List<PhotoItem> loadedPhotos = [];
        for (int i = 0; i < assets.length; i++) {
          final asset = assets[i];
          final file = await asset.file;
          if (file != null) {
            loadedPhotos.add(PhotoItem(
              id: 'gallery_${asset.id}',
              imagePath: file.path,
              label: null,
              assetEntity: asset,
            ));
          }
        }

        setState(() {
          galleryPhotos = loadedPhotos;
        });
      }
    } catch (e) {
      print('Error loading gallery photos: $e');
      setState(() {
        _permissionDenied = true;
      });
    }
  }

  void _selectPhoto(PhotoItem photo) {
    setState(() {
      // Deselect previous photo
      if (selectedPhoto != null) {
        selectedPhoto!.isSelected = false;
      }

      // Select new photo
      photo.isSelected = true;
      selectedPhoto = photo;
    });
  }

  Future<void> _pickFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      preferredCameraDevice:
          CameraDevice.front, // Front camera for profile photos
    );

    if (image != null) {
      final newPhoto = PhotoItem(
        id: 'camera_${DateTime.now().millisecondsSinceEpoch}',
        imagePath: image.path,
        label: 'New Photo',
      );

      setState(() {
        // Add to recent photos
        recentPhotos.insert(0, newPhoto);
        // Auto-select the new photo
        _selectPhoto(newPhoto);
      });
    }
  }

  void _togglePhotoSelection(PhotoItem photo) {
    setState(() {
      if (selectedPhoto == photo) {
        // Deselect if already selected
        selectedPhoto!.isSelected = false;
        selectedPhoto = null;
      } else {
        // Deselect previous photo
        if (selectedPhoto != null) {
          selectedPhoto!.isSelected = false;
        }
        // Select new photo
        photo.isSelected = true;
        selectedPhoto = photo;
      }
    });
  }

  void _confirmSelection() {
    widget.onPhotoSelected(selectedPhoto);
  }

  List<PhotoItem> get photos {
    if (selectedTab == 'Recents') {
      return recentPhotos;
    } else if (selectedTab == 'Gallery') {
      return galleryPhotos;
    }
    return [];
  }

  void _onTabChanged(String tab) {
    setState(() {
      selectedTab = tab;
    });

    // Load gallery photos when Gallery tab is selected for the first time
    if (tab == 'Gallery' &&
        galleryPhotos.isEmpty &&
        !_isLoadingGallery &&
        !_permissionDenied) {
      _requestPermissionAndLoadGallery();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: isDarkMode ? AppThemeColor.darkMode : AppThemeColor.brightness,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? AppThemeColor.darkMode
                  : AppThemeColor.brightness,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: isDarkMode
                              ? AppThemeColor.greenLower
                              : AppThemeColor.primaryColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Text(
                      'Photos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode
                            ? AppThemeColor.brightness
                            : AppThemeColor.darkMode,
                      ),
                    ),
                    TextButton(
                      onPressed:
                          selectedPhoto != null ? _confirmSelection : null,
                      child: Text(
                        'Done',
                        style: TextStyle(
                          color: selectedPhoto != null
                              ? (isDarkMode
                                  ? AppThemeColor.greenLower
                                  : AppThemeColor.primaryColor)
                              : Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Tab Bar
                Container(
                  height: 32,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ['Recents', 'Gallery'].map((tab) {
                      final isSelected = selectedTab == tab;
                      return GestureDetector(
                        onTap: () => _onTabChanged(tab),
                        child: Container(
                          margin: const EdgeInsets.only(right: 16),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDarkMode
                                    ? AppThemeColor.greenLower
                                    : AppThemeColor.primaryColor)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            tab,
                            style: TextStyle(
                              color: isSelected
                                  ? AppThemeColor.brightness
                                  : (isDarkMode
                                      ? AppThemeColor.brightness
                                      : AppThemeColor.darkMode),
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Photo Grid
          Expanded(
            child: Container(
              color: isDarkMode
                  ? AppThemeColor.darkMode
                  : AppThemeColor.brightness,
              child: _buildPhotoGridContent(isDarkMode),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRecentsView(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Camera button as the main action
          GestureDetector(
            onTap: _pickFromCamera,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color:
                    isDarkMode ? AppThemeColor.black : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDarkMode
                      ? AppThemeColor.greenLower
                      : AppThemeColor.primaryColor,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    size: 40,
                    color: isDarkMode
                        ? AppThemeColor.greenLower
                        : AppThemeColor.primaryColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Camera',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode
                          ? AppThemeColor.greenLower
                          : AppThemeColor.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Recent Photos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Take a photo to get started',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGridContent(bool isDarkMode) {
    if (selectedTab == 'Recents' && recentPhotos.isEmpty) {
      return _buildEmptyRecentsView(isDarkMode);
    }

    // Handle gallery loading states
    if (selectedTab == 'Gallery') {
      if (_isLoadingGallery) {
        return _buildLoadingView(isDarkMode);
      }
      if (_permissionDenied) {
        return _buildPermissionDeniedView(isDarkMode);
      }
      if (galleryPhotos.isEmpty) {
        return _buildEmptyGalleryView(isDarkMode);
      }
    }

    // Show photo grid
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemCount: photos.length + 1, // +1 for camera button
      itemBuilder: (context, index) {
        if (index == 0) {
          // Camera button
          return GestureDetector(
            onTap: _pickFromCamera,
            child: Container(
              decoration: BoxDecoration(
                color:
                    isDarkMode ? AppThemeColor.black : const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDarkMode
                      ? AppThemeColor.greenLower
                      : AppThemeColor.primaryColor,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    size: 32,
                    color: isDarkMode
                        ? AppThemeColor.greenLower
                        : AppThemeColor.primaryColor,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Camera',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode
                          ? AppThemeColor.greenLower
                          : AppThemeColor.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final photo = photos[index - 1];
        return GestureDetector(
          onTap: () => _togglePhotoSelection(photo),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isDarkMode ? AppThemeColor.black : Colors.grey[300],
                  border: photo.isSelected
                      ? Border.all(
                          color: isDarkMode
                              ? AppThemeColor.greenLower
                              : AppThemeColor.primaryColor,
                          width: 3,
                        )
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildPhotoWidget(photo),
                ),
              ),

              // Selection indicator
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: photo.isSelected
                        ? (isDarkMode
                            ? AppThemeColor.greenLower
                            : AppThemeColor.primaryColor)
                        : Colors.white.withOpacity(0.8),
                    border: Border.all(
                      color: photo.isSelected
                          ? (isDarkMode
                              ? AppThemeColor.greenLower
                              : AppThemeColor.primaryColor)
                          : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: photo.isSelected
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),

              // Photo label
              if (photo.label != null)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      photo.label!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingView(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: isDarkMode
                ? AppThemeColor.greenLower
                : AppThemeColor.primaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading Photos...',
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDeniedView(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 80,
              color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Permission Required',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please allow access to photos to browse your gallery',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _requestPermissionAndLoadGallery,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode
                    ? AppThemeColor.greenLower
                    : AppThemeColor.primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Grant Permission'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyGalleryView(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 80,
            color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Photos Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No photos found in your gallery',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoWidget(PhotoItem photo) {
    // For demonstration, we'll show a colored container with an icon
    // In a real app, you'd load the actual image from photo.imagePath
    final colors = [
      AppThemeColor.primaryColor,
      AppThemeColor.greenBrighter,
      AppThemeColor.greenLower,
      AppThemeColor.blue,
      Colors.orange,
      Colors.purple,
    ];

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: colors[photo.id.hashCode % colors.length],
      child: Icon(
        Icons.image,
        color: Colors.white.withOpacity(0.7),
        size: 32,
      ),
    );
  }
}
