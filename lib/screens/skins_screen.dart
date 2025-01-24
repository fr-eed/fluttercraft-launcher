import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:async';

class SkinGridScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const List<(String, String)> skins = [
      ("Grandpa", "https://fc-skins.pages.dev/grandpa.png"),
      ("May", "https://fc-skins.pages.dev/may.png"),
      ("Paz", "https://fc-skins.pages.dev/paz.png"),
      ("Soldier", "https://fc-skins.pages.dev/soldier.png"),
    ];

    return Scaffold(
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemCount: skins.length, // Replace with actual skin count
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Card(
                elevation: 0,
                color: Colors.transparent,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.grey.shade300
                          : Colors.grey.shade900),
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: MinecraftSkinViewer(
                        skinUrl: skins[index].$2,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        skins[index].$1,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 4,
                left: 4,
                child: PopupMenuButton(
                  icon: Icon(Icons.more_vert, color: Colors.grey),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20),
                          SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'delete') {
                      // Handle delete
                    } else if (value == 'edit') {
                      // Handle edit
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add skin logic here
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Skin'),
      ),
    );
  }
}

class MinecraftSkinViewer extends StatelessWidget {
  final String skinUrl;

  MinecraftSkinViewer({required this.skinUrl});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ui.Image>(
      future: _loadImage(skinUrl),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return CustomPaint(
            size: Size(200, 400), // Adjust size as needed
            painter: MinecraftSkinPainter(snapshot.data!),
          );
        }
        return CircularProgressIndicator();
      },
    );
  }

  Future<ui.Image> _loadImage(String url) async {
    final ImageProvider provider = NetworkImage(url);
    final ImageStream stream = provider.resolve(ImageConfiguration());
    Completer<ui.Image> completer = Completer<ui.Image>();

    stream.addListener(
        ImageStreamListener((ImageInfo frame, bool synchronousCall) {
      completer.complete(frame.image);
    }));

    return completer.future;
  }
}

class MinecraftSkinPainter extends CustomPainter {
  final ui.Image skin;

  MinecraftSkinPainter(this.skin);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Save the canvas state
    canvas.save();

    // Move to center
    canvas.translate(size.width / 2, size.height / 2);

    // Draw head
    _drawHead(canvas, paint);

    // Draw body
    _drawBody(canvas, paint);

    // Draw arms
    _drawArms(canvas, paint);

    // Draw legs
    _drawLegs(canvas, paint);

    // Restore canvas state
    canvas.restore();
  }

  void _drawHead(Canvas canvas, Paint paint) {
    // Extract head texture from skin (usually at 8,8,16,16)
    final src = Rect.fromLTWH(8, 8, 8, 8);
    final dst = Rect.fromLTWH(-20, -60, 40, 40);

    canvas.drawImageRect(skin, src, dst, paint);
  }

  void _drawBody(Canvas canvas, Paint paint) {
    // Extract body texture from skin (usually at 20,20,28,32)
    final src = Rect.fromLTWH(20, 20, 8, 12);
    final dst = Rect.fromLTWH(-20, -20, 40, 60);

    canvas.drawImageRect(skin, src, dst, paint);
  }

  void _drawArms(Canvas canvas, Paint paint) {
    // Left arm
    final leftArmSrc = Rect.fromLTWH(44, 20, 4, 12);
    final leftArmDst = Rect.fromLTWH(-35, -20, 15, 60);
    canvas.drawImageRect(skin, leftArmSrc, leftArmDst, paint);

    // Right arm
    final rightArmSrc = Rect.fromLTWH(44, 20, 4, 12);
    final rightArmDst = Rect.fromLTWH(20, -20, 15, 60);
    canvas.drawImageRect(skin, rightArmSrc, rightArmDst, paint);
  }

  void _drawLegs(Canvas canvas, Paint paint) {
    // Left leg
    final leftLegSrc = Rect.fromLTWH(4, 20, 4, 12);
    final leftLegDst = Rect.fromLTWH(-20, 40, 20, 60);
    canvas.drawImageRect(skin, leftLegSrc, leftLegDst, paint);

    // Right leg
    final rightLegSrc = Rect.fromLTWH(4, 20, 4, 12);
    final rightLegDst = Rect.fromLTWH(0, 40, 20, 60);
    canvas.drawImageRect(skin, rightLegSrc, rightLegDst, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
