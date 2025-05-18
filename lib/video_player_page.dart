import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class VideoPlayerPage extends StatefulWidget {
  final String filePath;

  const VideoPlayerPage({super.key, required this.filePath});

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isBuffering = false;
  double _currentPosition = 0;
  double _bufferingProgress = 0;
  bool _showControls = true;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _controller = VideoPlayerController.file(File(widget.filePath))
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _controller!.play();

        // Listen to player events
        _controller!.addListener(_controllerListener);
      })
      ..setLooping(false);
  }

  void _controllerListener() {
    if (!mounted) return;

    final isBuffering = _controller!.value.isBuffering;
    if (isBuffering != _isBuffering) {
      setState(() {
        _isBuffering = isBuffering;
      });
    }

    final position = _controller!.value.position.inMilliseconds.toDouble();
    final duration = _controller!.value.duration.inMilliseconds.toDouble();
    
    if (duration > 0) {
      final progress = position / duration;
      setState(() {
        _currentPosition = progress.clamp(0.0, 1.0);
      });
    }

    final buffered = _controller!.value.buffered;
    if (buffered.isNotEmpty && duration > 0) {
      final bufferEnd = buffered.last.end.inMilliseconds.toDouble();
      final bufferProgress = bufferEnd / duration;
      setState(() {
        _bufferingProgress = bufferProgress.clamp(0.0, 1.0);
      });
    }
  }

  void _togglePlayPause() {
    setState(() {
      _controller!.value.isPlaying ? _controller!.pause() : _controller!.play();
    });
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  void _skipForward() {
    final newPosition = _controller!.value.position + const Duration(seconds: 10);
    _controller!.seekTo(newPosition);
  }

  void _skipBackward() {
    final newPosition = _controller!.value.position - const Duration(seconds: 10);
    _controller!.seekTo(newPosition);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return hours == '00' ? '$minutes:$seconds' : '$hours:$minutes:$seconds';
  }

  @override
  void dispose() {
    _controller?.removeListener(_controllerListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isFullScreen
          ? null
          : AppBar(
              title: const Text('Video Oynatıcı'),
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
      backgroundColor: Colors.black,
      body: _isInitialized
          ? GestureDetector(
              onTap: () {
                setState(() {
                  _showControls = !_showControls;
                });
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Center(
                    child: AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    ),
                  ),
                  if (_isBuffering)
                    const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  if (_showControls)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.7),
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.0, 0.2, 0.8, 1.0],
                        ),
                      ),
                    ),
                  if (_showControls)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Column(
                        children: [
                          // Progress bar
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Stack(
                              children: [
                                // Buffer progress
                                LinearProgressIndicator(
                                  value: _bufferingProgress,
                                  backgroundColor: Colors.grey[800],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.grey[400]!),
                                  minHeight: 5,
                                ),
                                // Playback progress
                                SliderTheme(
                                  data: SliderThemeData(
                                    trackHeight: 5,
                                    activeTrackColor: Theme.of(context).colorScheme.primary,
                                    inactiveTrackColor: Colors.transparent,
                                    thumbColor: Theme.of(context).colorScheme.primary,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 6,
                                    ),
                                    overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 12,
                                    ),
                                  ),
                                  child: Slider(
                                    value: _currentPosition,
                                    onChanged: (value) {
                                      final duration = _controller!.value.duration;
                                      final newPosition = duration * value;
                                      _controller!.seekTo(newPosition);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Timing and controls
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, bottom: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Current time / Total time
                                Text(
                                  '${_formatDuration(_controller!.value.position)} / ${_formatDuration(_controller!.value.duration)}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                // Controls
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.replay_10),
                                      color: Colors.white,
                                      onPressed: _skipBackward,
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        _controller!.value.isPlaying
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        size: 40,
                                      ),
                                      color: Colors.white,
                                      onPressed: _togglePlayPause,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.forward_10),
                                      color: Colors.white,
                                      onPressed: _skipForward,
                                    ),
                                    IconButton(
                                      icon: Icon(_isFullScreen
                                          ? Icons.fullscreen_exit
                                          : Icons.fullscreen),
                                      color: Colors.white,
                                      onPressed: _toggleFullScreen,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 20),
                  Text(
                    'Video yükleniyor...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
    );
  }
}