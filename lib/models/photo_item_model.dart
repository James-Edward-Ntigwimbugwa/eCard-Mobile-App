import 'package:photo_manager/photo_manager.dart';

class PhotoItem {
  final String id;
  final String imagePath;
  final String? label;
  final AssetEntity? assetEntity;
  bool isSelected;

  PhotoItem({
    required this.id,
    required this.imagePath,
    this.label,
    this.assetEntity, // Add this parameter
    this.isSelected = false,
  });
}
