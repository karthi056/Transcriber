import 'package:flutter/material.dart';

class OutputScreen extends StatelessWidget {
  final String output;
  const OutputScreen({super.key, required this.output});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transcription Output')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(output),
      ),
    );
  }
}
