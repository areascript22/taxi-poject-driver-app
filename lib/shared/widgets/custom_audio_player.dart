import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class CustomAudioPlayer extends StatefulWidget {
  final String byAudioIndicationsURL;
  const CustomAudioPlayer({
    super.key,
    required this.byAudioIndicationsURL,
  });

  @override
  State<CustomAudioPlayer> createState() => _CustomAudioPlayerState();
}

class _CustomAudioPlayerState extends State<CustomAudioPlayer> {
  //VARIABLES
  final logger = Logger();
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<Duration>? audioDurationListener;
  StreamSubscription<Duration>? onPositionChangedListener;
  StreamSubscription<Duration>? onPlayerCompleteListener;
  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;
  Duration elapsedDuration = Duration.zero;
  bool _isPlaying = false;
  bool isSliding = false;
  bool loading = false;
  double _testValue = 5;
  //
  @override
  void initState() {
    super.initState();
    listenToDuration();
  }

  @override
  void dispose() {
    audioDurationListener?.cancel();
    onPlayerCompleteListener?.cancel();
    onPositionChangedListener?.cancel();
    super.dispose();
  }

  //FUNCTIONS
  void _pauseAudio() async {
    await _audioPlayer.pause();
    setState(() => _isPlaying = false);
  }

  Future<void> _playAudio() async {
    if (widget.byAudioIndicationsURL.isEmpty) {
      logger.e("Audio URL is empty: ${widget.byAudioIndicationsURL}.aac");
      return;
    }

    setState(() {
      loading = true;
    });
    try {
      await _audioPlayer.play(UrlSource(widget.byAudioIndicationsURL));
    } catch (e) {
      logger.e("Error trying to play audio: $e");
    }

    if (mounted) {
      setState(() {
        loading = false;
        _isPlaying = true;
      });
    }
  }

  //Seek to a specific position in the current song
  Future<Null> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  //Listen to duration
  void listenToDuration() {
    //Listen for the total duration
    audioDurationListener =
        _audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        _totalDuration = newDuration;
      });
    });

    //Listen for the current durationa
    _audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        _currentDuration = newPosition;
      });
    });

    //Listen for song completion
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
      });
    });
  }

  String formatTime(Duration duration) {
    String twoDigitSeconds =
        duration.inSeconds.remainder(60).toString().padLeft(1, "0");
    String formatedTime = "${duration.inMinutes}: $twoDigitSeconds";
    return formatedTime;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1F272A),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Play/Pause button
          IconButton(
            icon: loading
                ? const SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(),
                  )
                : Icon(
                    _isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    color: Colors.white,
                    size: 30,
                  ),
            onPressed: () {
              if (_isPlaying) {
                _pauseAudio();
              } else {
                _playAudio();
              }
            },
          ),
          // Progress Indicator
          Expanded(
            flex: 2,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.green,
                inactiveTrackColor: Colors.white24,
                thumbColor: Colors.green,
                overlayColor: Colors.green.withOpacity(0.2),
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                trackHeight: 2.0,
              ),
              child: Slider(
                min: 0.0,
                max: _totalDuration.inSeconds.toDouble(),
                value: !isSliding
                    ? _currentDuration.inSeconds.toDouble()
                    : _testValue,
                label: _testValue.round().toString(),
                onChangeStart: (value) {
                  isSliding = true;
                },
                onChanged: (double value) {
                  setState(() {
                    _testValue = value;
                  });
                },
                onChangeEnd: (value2) async {
                  await seek(Duration(seconds: value2.toInt()));
                  setState(() {
                    isSliding = false;
                  });
                },
              ),
            ),
          ),

          // Duration
          Text(
            _currentDuration != Duration.zero
                ? formatTime(_currentDuration)
                : formatTime(elapsedDuration),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
