import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../data/bg_data.dart';
import '../utils/text_utils.dart';

class TranscriberScreen extends StatefulWidget {
  const TranscriberScreen({super.key});

  @override
  _TranscriberScreenState createState() => _TranscriberScreenState();
}

class _TranscriberScreenState extends State<TranscriberScreen> {
  String _transcription = "Upload a file or transcribe from the microphone.";
  final String apiUrl = "http://127.0.0.1:5000";
  int selectedIndex = 0;
  bool showOption = false;

  Future<void> _pickFile(String fileType) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: fileType == "video" ? FileType.video : FileType.audio,
    );

    if (result != null) {
      if (kIsWeb) {
        Uint8List? bytes = result.files.single.bytes;
        if (bytes != null) {
          await _uploadBytes(bytes, result.files.single.name, fileType);
        }
      } else {
        String? path = result.files.single.path;
        if (path != null) {
          await _uploadFile(File(path), fileType);
        }
      }
    }
  }

  Future<void> _uploadFile(File file, String fileType) async {
    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$apiUrl/transcribe_$fileType"),
    );
    request.files.add(
      await http.MultipartFile.fromPath(fileType, file.path),
    );
    var response = await request.send();
    _handleResponse(response);
  }

  Future<void> _uploadBytes(
      Uint8List bytes, String fileName, String fileType) async {
    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$apiUrl/transcribe_$fileType"),
    );
    request.files.add(
      http.MultipartFile.fromBytes(fileType, bytes, filename: fileName),
    );
    var response = await request.send();
    _handleResponse(response);
  }

  Future<void> _handleResponse(http.StreamedResponse response) async {
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(await response.stream.bytesToString());
      setState(() {
        _transcription = jsonResponse.toString();
      });
    } else {
      setState(() {
        _transcription = "Error during transcription";
      });
    }
  }

  Future<void> _transcribeMicrophone() async {
    var response = await http.post(Uri.parse("$apiUrl/transcribe_microphone"));
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      setState(() {
        _transcription = jsonResponse.toString();
      });
    } else {
      setState(() {
        _transcription = "Error transcribing from microphone";
      });
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
            image: AssetImage(bgList[selectedIndex]),
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
                        text: "Transcriber App",
                        weight: true,
                        size: 30,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () => _pickFile("audio"),
                      child: const Text("Upload Audio"),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => _pickFile("video"),
                      child: const Text("Upload Video"),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _transcribeMicrophone,
                      child: const Text("Transcribe Microphone Input"),
                    ),
                    const Spacer(),
                    const Text(
                      "Transcription:",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _transcription,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
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
