import 'package:flutter/material.dart';
import 'package:flutter_cheatsheet/inline_audio_player/inline_audio_player.dart';

import 'audio_recorder/audio_recorder.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String _audioUrl =
      'https://cdn.discordapp.com/attachments/475120233779298305/981272851002830898/DJ_Genki_-_HYPER_GENERATOR.mp3';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AudioRecorderView(
                        onCompleted: (path) {
                          debugPrint('AudioRecorderView.onCompleted: $path');
                        },
                      ),
                    ),
                  );
                },
                child: const Text('Audio Recorder'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InlineAudioPlayer(url: _audioUrl),
                    ),
                  );
                },
                child: const Text('Inline Audio Player'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
