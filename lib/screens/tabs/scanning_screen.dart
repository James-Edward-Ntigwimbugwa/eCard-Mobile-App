import 'dart:async';
import 'package:flutter/material.dart';

class ScanningScreen extends StatefulWidget {
  final String? imageUrl;
  final double? imageSize; // Make this nullable

  const ScanningScreen({
    Key? key,
    this.imageUrl,
    this.imageSize,
  }) : super(key: key);

  @override
  State<ScanningScreen> createState() => ScanningScreenState();
}

class ScanningScreenState extends State<ScanningScreen> with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;

  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  // Default value if imageSize is null - reduced size
  double get _effectiveImageSize => widget.imageSize ?? 100.0;

  // Black-greenish color for circles
  final Color _circleColor = Color.fromARGB(255, 0, 110, 61); // Dark greenish-black

  @override
  void initState() {
    super.initState();

    // First circle animation
    _controller1 = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: false);
    _animation1 = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller1, curve: Curves.easeInOut)
    );

    // Second circle animation (delayed start)
    _controller2 = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation2 = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller2, curve: Curves.easeInOut)
    );

    // Third circle animation (more delayed start)
    _controller3 = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation3 = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller3, curve: Curves.easeInOut)
    );

    // Start animations with delays
    Timer(const Duration(milliseconds: 650), () {
      _controller2.repeat(reverse: false);
    });

    Timer(const Duration(milliseconds: 1300), () {
      _controller3.repeat(reverse: false);
    });
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16), // Spacing below SafeArea
            buildScanningWidget(),
            // Add your other content below
            Expanded(
              child: Container(
                // Your other content here
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildScanningWidget() {
    return Container(
      height: _effectiveImageSize * 3, // Container to hold the scanning circles
      alignment: Alignment.topCenter,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Third (outermost) scanning circle
          AnimatedBuilder(
            animation: _animation3,
            builder: (context, child) {
              return CustomPaint(
                size: Size(_effectiveImageSize * 2.2, _effectiveImageSize * 2.2),
                painter: CirclePainter(
                  progress: _animation3.value,
                  color: _circleColor.withOpacity(0.3),
                  strokeWidth: 5.0,
                ),
              );
            },
          ),

          // Second scanning circle
          AnimatedBuilder(
            animation: _animation2,
            builder: (context, child) {
              return CustomPaint(
                size: Size(_effectiveImageSize * 1.8, _effectiveImageSize * 1.8),
                painter: CirclePainter(
                  progress: _animation2.value,
                  color: _circleColor.withOpacity(0.5),
                  strokeWidth: 4.0,
                ),
              );
            },
          ),

          // First (innermost) scanning circle
          AnimatedBuilder(
            animation: _animation1,
            builder: (context, child) {
              return CustomPaint(
                size: Size(_effectiveImageSize * 1.4, _effectiveImageSize * 1.4),
                painter: CirclePainter(
                  progress: _animation1.value,
                  color: _circleColor.withOpacity(0.7),
                  strokeWidth: 3.0,
                ),
              );
            },
          ),

          // Image in the center
          Container(
            width: _effectiveImageSize,
            height: _effectiveImageSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: widget.imageUrl != null
                  ? Image.network(
                widget.imageUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                      color: _circleColor,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.image_not_supported,
                      size: _effectiveImageSize * 0.4,
                      color: Colors.grey,
                    ),
                  );
                },
              )
                  : Container(
                color: Colors.grey[200],
                child: Icon(
                  Icons.camera_alt,
                  size: _effectiveImageSize * 0.4,
                  color: _circleColor.withOpacity(0.7),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for drawing the scanning circles
class CirclePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  CirclePainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Use sweep gradient for a more dynamic 3D effect
    final gradient = SweepGradient(
      startAngle: 0,
      endAngle: 2 * 3.14159,
      tileMode: TileMode.repeated,
      colors: [
        color.withOpacity(0.2),
        color.withOpacity(0.8),
        color.withOpacity(0.2),
      ],
      stops: const [0.0, 0.5, 1.0],
      transform: GradientRotation(2 * 3.14159 * progress),
    );

    paint.shader = gradient.createShader(
      Rect.fromCircle(center: center, radius: radius),
    );

    // Draw circle with a small offset to enhance 3D effect
    final shadowOffset = Offset(1.0, 1.0) * (progress * 0.5);
    canvas.drawCircle(center + shadowOffset, radius, paint);

    // Draw main circle
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// Example of how to use this widget in your app
class ScanningExample extends StatelessWidget {
  const ScanningExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ScanningScreen(
      imageUrl: "https://via.placeholder.com/100",
      imageSize: 100, // Smaller size
    );
  }
}