import 'package:flutter/material.dart';
import 'package:flutter_cheatsheet/helper.dart';
import 'package:just_audio/just_audio.dart';

/// Inline Audio Player
/// need [just_audio](https://pub.dev/packages/just_audio) for audio handler
/// work on web and android

class InlineAudioPlayer extends StatefulWidget {
  const InlineAudioPlayer({Key? key, required this.url, this.player}) : super(key: key);

  final String url;

  final AudioPlayer? player;

  @override
  State<InlineAudioPlayer> createState() => _InlineAudioPlayerState();
}

class _InlineAudioPlayerState extends State<InlineAudioPlayer> {
  late AudioPlayer _audioPlayer;
  Duration _position = Duration.zero;
  Widget _iconState = const Icon(Icons.play_arrow);

  void _play() {
    setState(() {
      if (_audioPlayer.playing) {
        _audioPlayer.pause();
      } else {
        _audioPlayer.play();
      }
    });
  }

  void _seek(double value) {
    setState(() {
      _audioPlayer.seek(Duration(seconds: value.toInt()));
    });
  }

  @override
  void initState() {
    _audioPlayer = widget.player ?? AudioPlayer();

    _audioPlayer.setUrl(widget.url);

    _audioPlayer.positionStream.listen((event) {
      setState(() {
        _position = event;
      });
    });

    _audioPlayer.playerStateStream.listen((event) {
      switch (event.processingState) {
        case ProcessingState.loading:
        case ProcessingState.buffering:
          setState(() {
            _iconState = const SizedBox(width: 24, height: 24, child: CircularProgressIndicator());
          });
          break;
        case ProcessingState.completed:
          setState(() {
            _audioPlayer.stop();
            _audioPlayer.seek(Duration.zero);
          });
          break;
        default:
          setState(() {
            _iconState = Icon(event.playing ? Icons.pause : Icons.play_arrow, color: Theme.of(context).primaryColor);
          });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Player'),
      ),
      body: Center(
        child: inlineAudioPlayer(),
      ),
    );
  }

  Widget inlineAudioPlayer() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(360),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(360),
                    onTap: _play,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: _iconState,
                    ),
                  ),
                ),
              ),
              Text(durationFormat(_position)),
              Expanded(
                child: Slider(
                  value: _position.inSeconds.toDouble(),
                  onChanged: _seek,
                  max: (_audioPlayer.duration ?? _position).inSeconds.toDouble(),
                ),
              ),
              Text(durationFormat(_audioPlayer.duration ?? Duration.zero)),
            ],
          ),
        ),
      ],
    );
  }
}