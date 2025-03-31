import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/scheduler.dart';

class SwirlyShaderedContainer extends StatefulWidget {
  final Widget child;
  final double width;
  final double height;
  final Color color1;
  final Color color2;
  final double swirlIntensity;
  final double swirlSpeed;

  const SwirlyShaderedContainer({
    Key? key,
    required this.child,
    this.width = double.infinity,
    this.height = double.infinity,
    this.color1 = const Color(0xFF1A4BC8), // Minecraft-style blue
    this.color2 = const Color(0xFFC821B3), // Purple
    this.swirlIntensity = 5.0,
    this.swirlSpeed = 0.3,
  }) : super(key: key);

  @override
  State<SwirlyShaderedContainer> createState() =>
      _SwirlyShaderedContainerState();
}

class _SwirlyShaderedContainerState extends State<SwirlyShaderedContainer>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _time = 0.0;
  ui.FragmentProgram? _program;
  ui.FragmentShader? _shader;

  @override
  void initState() {
    super.initState();
    _loadShader();
    _ticker = createTicker((elapsed) {
      setState(() {
        _time = elapsed.inMilliseconds / 1000.0; // Convert to seconds
      });
    });
    _ticker.start();
  }

  Future<void> _loadShader() async {
    try {
      _program =
          await ui.FragmentProgram.fromAsset('assets/swirly_gradient.frag');
      if (mounted) {
        setState(() {
          _shader = _program?.fragmentShader();
        });
      }
    } catch (e) {
      print('Error loading shader: $e');
      // Handle the error appropriately
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _shader?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_shader == null) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[800],
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: _ShaderPainter(
          shader: _shader!,
          time: _time,
          color1: widget.color1,
          color2: widget.color2,
          swirlIntensity: widget.swirlIntensity,
          swirlSpeed: widget.swirlSpeed,
        ),
        child: widget.child,
      ),
    );
  }
}

class _ShaderPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final double time;
  final Color color1;
  final Color color2;
  final double swirlIntensity;
  final double swirlSpeed;

  _ShaderPainter({
    required this.shader,
    required this.time,
    required this.color1,
    required this.color2,
    required this.swirlIntensity,
    required this.swirlSpeed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    shader.setFloat(2, time);
    shader.setFloat(3, color1.red / 255.0);
    shader.setFloat(4, color1.green / 255.0);
    shader.setFloat(5, color1.blue / 255.0);
    shader.setFloat(6, color1.alpha / 255.0);
    shader.setFloat(7, color2.red / 255.0);
    shader.setFloat(8, color2.green / 255.0);
    shader.setFloat(9, color2.blue / 255.0);
    shader.setFloat(10, color2.alpha / 255.0);
    shader.setFloat(11, swirlIntensity);
    shader.setFloat(12, swirlSpeed);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = shader,
    );
  }

  @override
  bool shouldRepaint(_ShaderPainter oldDelegate) {
    return oldDelegate.time != time;
  }
}
