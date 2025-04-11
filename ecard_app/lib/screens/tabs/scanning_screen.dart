import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class ScanningScreen extends StatefulWidget {
  final CameraController? camera;
  const ScanningScreen({super.key, this.camera});

  @override
  _ScanningScreenState createState() => _ScanningScreenState();
}

class _ScanningScreenState extends State<ScanningScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
