import 'dart:io';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../data/bg_data.dart';
import '../utils/text_utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ServerControlPage(),
    );
  }
}

class ServerControlPage extends StatefulWidget {
  const ServerControlPage({super.key});

  @override
  State<ServerControlPage> createState() => _ServerControlPageState();
}

class _ServerControlPageState extends State<ServerControlPage> {
  Process? _process;
  bool _isRunning = false;

  void startServer() async {
    if (_isRunning) return;

    try {
      _process = await Process.start(
        'python',
        ['app.py'],
        mode: ProcessStartMode.normal,
      );

      debugPrint("Server process started");

      _process!.stdout.transform(utf8.decoder).listen((data) {
        debugPrint("Server Output: $data");
        setState(() {
          _isRunning = true;
        });
      });

      _process!.stderr.transform(utf8.decoder).listen((data) {
        debugPrint("Server Error: $data");
      });
    } catch (e) {
      debugPrint("Error starting server: $e");
    }
  }

  void stopServer() {
    if (_process != null) {
      _process!.kill();
      _isRunning = false;
      debugPrint("Server stopped");
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(bgList[0]), // Background image
            fit: BoxFit.fill,
          ),
        ),
        alignment: Alignment.center,
        child: Container(
          height: 500,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(15),
            color: Colors.black.withOpacity(0.1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaY: 5, sigmaX: 5),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Center(
                      child: TextUtil(
                        text: "Speech Admin Server Control",
                        weight: true,
                        size: 30,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _isRunning ? null : startServer,
                      child: const Text("Start Server"),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _isRunning ? stopServer : null,
                      child: const Text("Stop Server"),
                    ),
                    const Spacer(),
                    Text(
                      _isRunning ? "Server is Running" : "Server is Stopped",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
