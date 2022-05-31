import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cheatsheet/helper.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

/// AudioRecorderView
/// need [flutter_sound] for recorder and [permission_handler] for permission handler
/// only work on web
/// not tested on iOS due to money

typedef OnCompleted = void Function(String path);

class AudioRecorderView extends StatefulWidget {
  const AudioRecorderView({Key? key, required this.onCompleted}) : super(key: key);

  final OnCompleted onCompleted;

  @override
  State<AudioRecorderView> createState() => _AudioRecorderViewState();
}

class _AudioRecorderViewState extends State<AudioRecorderView> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool isInitialized = false;
  Duration _duration = Duration.zero;
  final List<double> db = [0];

  Widget button(Widget icon, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(32.0)),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: icon,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    if (!kIsWeb) {
      checkPermission();
    }

    _recorder.openRecorder().then((value) {
      setState(() {
        isInitialized = true;
      });
    });

    _recorder.onProgress!.listen((event) {
      setState(() {
        _duration = event.duration;
        db.add(event.decibels ?? 0);
      });
    });
    super.initState();
  }

  Future checkPermission() async {
    var status = await Permission.microphone.status;
    if (status == PermissionStatus.granted) {
      debugPrint('Permission granted');
    } else if (status == PermissionStatus.denied) {
      debugPrint('Denied. Show a dialog with a reason and again ask for the permission.');
    } else if (status == PermissionStatus.permanentlyDenied) {
      debugPrint('Take the user to the settings page.');
      await openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Center(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 32),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(360),
                    boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.1))]),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 62),
                child: const Icon(
                  Icons.mic,
                  color: Colors.redAccent,
                  size: 160,
                ),
              ),
              const SizedBox(height: 32),
              Text(durationFormat(_duration), style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 100),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  button(const Icon(Icons.fiber_manual_record, color: Colors.redAccent, size: 48), _record),
                  if (_recorder.isRecording) button(const Icon(Icons.pause, size: 48), _pause),
                  if (_recorder.isPaused) button(const Icon(Icons.play_arrow, size: 48), _resume),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _record() {
    if (isInitialized) {
      setState(() {
        if (_recorder.isRecording || _recorder.isPaused) {
          _recorder.stopRecorder().then((value) {
            widget.onCompleted(value!);
          });
        } else {
          _recorder.startRecorder(
            toFile: 'audio_${DateTime.now().millisecondsSinceEpoch}.webm',
            codec: Codec.opusWebM,
          ).then((value) {
            _recorder.setSubscriptionDuration(const Duration(seconds: 1));
          });
        }
      });
    }
  }

  void _pause() {
    setState(() {
      _recorder.pauseRecorder();
    });
  }

  void _resume() {
    setState(() {
      _recorder.resumeRecorder();
    });
  }
}
