import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:driver_app/features/ride_request/viewmodel/ride_request_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class DeliveryByAudio extends StatefulWidget {
  const DeliveryByAudio({super.key});

  @override
  State<DeliveryByAudio> createState() => _DeliveryByAudioState();
}

class _DeliveryByAudioState extends State<DeliveryByAudio> {
  //VARIABLES
  final logger = Logger();
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription<Duration>? audioDurationListener;
  Duration _currentDuration = Duration.zero;
  Duration _totalDuration = Duration.zero;
  Duration elapsedDuration = Duration.zero;
  bool _isPlaying = false;
  bool isSliding = false;
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
    super.dispose();
  }

  //FUNCTIONS
  void _pauseAudio() async {
    await _audioPlayer.pause();
    setState(() => _isPlaying = false);
  }

  Future<void> _playAudio(RideRequestViewModel rideRequestViewModel) async {
    if (rideRequestViewModel.byAudioIndicationsURL.isEmpty) {
      logger.e(
          "Audio URL is empty: ${rideRequestViewModel.byAudioIndicationsURL}.aac");
      return;
    }
    await _audioPlayer
        .play(UrlSource(rideRequestViewModel.byAudioIndicationsURL));
    setState(() => _isPlaying = true);
  }

  //Seek to a specific position in the current song
  Future<Null> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  //Listen to duration
  void listenToDuration() {
    //Listen for the total duration
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
    String formatedTime = "${duration.inMinutes}: ${twoDigitSeconds}";
    return formatedTime;
  }

  @override
  Widget build(BuildContext context) {
    final rideRequestViewModel = Provider.of<RideRequestViewModel>(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //Audio player buttons
          const SizedBox(height: 10),
          Container(
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
                  icon: Icon(
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
                      _playAudio(rideRequestViewModel);
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
          ),
        ],
      ),
    );
  }
}
