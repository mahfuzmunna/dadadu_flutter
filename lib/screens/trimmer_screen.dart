import 'dart:io';

import 'package:flutter/material.dart';
import 'package:start/generated/l10n.dart';
import 'package:video_trimmer/video_trimmer.dart';

class TrimmerView extends StatefulWidget {
  final String videoFilePath;

  const TrimmerView({
    super.key,
    required this.videoFilePath,
  });

  @override
  State<TrimmerView> createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
  final Trimmer _trimmer = Trimmer();
  double _startValue = 0.0;
  double _endValue = 0.0;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    await _trimmer.loadVideo(videoFile: File(widget.videoFilePath));
    setState(() {
      _endValue =
          _trimmer.videoPlayerController?.value.duration.inSeconds.toDouble() ??
              20.0;
    });
  }

  Future<void> _saveTrimmedVideo() async {
    setState(() => _isSaving = true);

    await _trimmer.saveTrimmedVideo(
      startValue: _startValue,
      endValue: _endValue,
      onSave: (String? outputPath) {
        Navigator.pop(context, outputPath);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(locale.trimTitle)),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: VideoViewer(trimmer: _trimmer),
                ),
                TrimViewer(
                  trimmer: _trimmer,
                  viewerHeight: 50.0,
                  viewerWidth: MediaQuery.of(context).size.width,
                  maxVideoLength: const Duration(seconds: 20),
                  onChangeStart: (value) => _startValue = value,
                  onChangeEnd: (value) => _endValue = value,
                  onChangePlaybackState: (isPlaying) {},
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _saveTrimmedVideo,
                  icon: const Icon(Icons.check),
                  label: Text(locale.trimContinue),
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }
}
