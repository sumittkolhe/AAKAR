import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../theme.dart';
import '../widgets/aakar_widgets.dart';

class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});

  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  final GlobalKey _globalKey = GlobalKey();
  List<DrawingPoint?> _points = [];
  Color _selectedColor = Colors.black;
  double _strokeWidth = 5.0;
  
  final List<Color> _colors = [
    Colors.black,
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.pink,
    Colors.white,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Draw Your Feelings 🎨',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () {
              setState(() {
                _points.clear();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.save_alt_rounded),
            onPressed: _saveDrawing,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.darkGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. Tool Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.surface.withValues(alpha: 0.5),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _colors.map((color) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedColor = color;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _selectedColor == color ? Colors.white : Colors.transparent,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    if (_selectedColor == color)
                                      BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 100,
                      child:SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                        ),
                        child: Slider(
                          value: _strokeWidth,
                          min: 1.0,
                          max: 20.0,
                          activeColor: _selectedColor,
                          inactiveColor: AppColors.textMuted,
                          onChanged: (value) {
                            setState(() {
                              _strokeWidth = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Canvas
              Expanded(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      child: RepaintBoundary(
                        key: _globalKey,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            setState(() {
                              RenderBox renderBox = context.findRenderObject() as RenderBox;
                              _points.add(DrawingPoint(
                                offset: renderBox.globalToLocal(details.globalPosition),
                                paint: Paint()
                                  ..color = _selectedColor
                                  ..strokeCap = StrokeCap.round
                                  ..strokeWidth = _strokeWidth,
                              ));
                            });
                          },
                          onPanStart: (details) {
                            setState(() {
                              RenderBox renderBox = context.findRenderObject() as RenderBox;
                              _points.add(DrawingPoint(
                                offset: renderBox.globalToLocal(details.globalPosition),
                                paint: Paint()
                                  ..color = _selectedColor
                                  ..strokeCap = StrokeCap.round
                                  ..strokeWidth = _strokeWidth,
                              ));
                            });
                          },
                          onPanEnd: (details) {
                            setState(() {
                              _points.add(null);
                            });
                          },
                          child: CustomPaint(
                            painter: DrawingPainter(_points),
                            size: Size.infinite,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveDrawing() async {
    try {
      // 1. Request Permission (Storage) - Handling basic cases
      // Note: On newer Android versions (10+), scoped storage might not require permission for app directory
      // But for gallery, it does. For now, let's save to App Documents which is safe.

      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData != null) {
        final buffer = byteData.buffer.asUint8List();
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/drawing_${const Uuid().v4()}.png';
        final file = File(filePath);
        await file.writeAsBytes(buffer);

        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Saved to $filePath'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error saving: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save drawing')),
        );
      }
    }
  }
}

class DrawingPoint {
  Offset offset;
  Paint paint;

  DrawingPoint({required this.offset, required this.paint});
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint?> points;

  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    // White background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.white);

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!.offset, points[i + 1]!.offset, points[i]!.paint);
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawPoints(ui.PointMode.points, [points[i]!.offset], points[i]!.paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
