import 'dart:typed_data';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:start/generated/l10n.dart';

class CropSample extends StatefulWidget {
  final XFile imageFile;

  const CropSample({super.key, required this.imageFile});

  @override
  _CropSampleState createState() => _CropSampleState();
}


class _CropSampleState extends State<CropSample> {
  final _cropController = CropController();
  Uint8List? _selectedImageBytes;

  bool _isCircleUi = false;
  bool _isOverlayActive = true;
  bool _undoEnabled = false;
  bool _redoEnabled = false;
  String _statusText = '';

  @override
  void initState() {
    super.initState();
    _loadSelectedImage();
  }

  Future<void> _loadSelectedImage() async {
    final bytes = await widget.imageFile.readAsBytes();
    setState(() {
      _selectedImageBytes = bytes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    if (_selectedImageBytes == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(s.cropImage)),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Crop(
                  controller: _cropController,
                  image: _selectedImageBytes!,
                  radius: 45,
                  onCropped: (result) {
                    switch (result) {
                      case CropSuccess(:final croppedImage):
                        Navigator.pop(context, croppedImage);
                      case CropFailure(:final cause):
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(s.error),
                            content: Text('${s.cropFailed}: $cause'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(s.ok),
                              ),
                            ],
                          ),
                        );
                    }
                  },
                  withCircleUi: _isCircleUi,
                  maskColor: Colors.black.withOpacity(0.5),
                  onStatusChanged: (status) {
                    setState(() {
                      _statusText = {
                            CropStatus.nothing: s.noImageLoaded,
                            CropStatus.loading: s.loadingImage,
                            CropStatus.ready: s.imageReady,
                            CropStatus.cropping: s.cropping,
                          }[status] ??
                          '';
                    });
                  },
                  interactive: true,
                  fixCropRect: true,
                  initialRectBuilder: InitialRectBuilder.withBuilder(
                    (viewport, image) {
                      return Rect.fromLTRB(
                        viewport.left + 24,
                        viewport.top + 24,
                        viewport.right - 24,
                        viewport.bottom - 24,
                      );
                    },
                  ),
                  onHistoryChanged: (history) => setState(() {
                    _undoEnabled = history.undoCount > 0;
                    _redoEnabled = history.redoCount > 0;
                  }),
                  overlayBuilder: _isOverlayActive
                      ? (context, rect) {
                          return _isCircleUi
                              ? ClipOval(child: CustomPaint(painter: GridPainter()))
                              : CustomPaint(painter: GridPainter());
                        }
                      : null,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Text(_statusText),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.crop_square),
                      onPressed: () {
                        _isCircleUi = false;
                        _cropController
                          ..withCircleUi = false
                          ..aspectRatio = 1;
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.crop_16_9),
                      onPressed: () {
                        _isCircleUi = false;
                        _cropController.aspectRatio = 16 / 9;
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.circle),
                      onPressed: () {
                        _isCircleUi = true;
                        _cropController.withCircleUi = true;
                      },
                    ),
                    Switch(
                      value: _isOverlayActive,
                      onChanged: (v) => setState(() => _isOverlayActive = v),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _undoEnabled ? () => _cropController.undo() : null,
                      child: Text(s.undo),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _redoEnabled ? () => _cropController.redo() : null,
                      child: Text(s.redo),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _isCircleUi
                        ? _cropController.cropCircle()
                        : _cropController.crop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    child: Text(s.cropAndSave),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class GridPainter extends CustomPainter {
  final divisions = 2;
  final strokeWidth = 1.0;
  final Color color = Colors.white70;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..color = color;

    final spacing = size / (divisions + 1);
    for (var i = 1; i <= divisions; i++) {
      canvas.drawLine(
        Offset(spacing.width * i, 0),
        Offset(spacing.width * i, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(0, spacing.height * i),
        Offset(size.width, spacing.height * i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
