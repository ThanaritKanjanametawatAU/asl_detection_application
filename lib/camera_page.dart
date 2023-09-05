import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'history.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  late tfl.Interpreter interpreter;
  late List<CameraDescription> cameras;

  String detectedAlphabets = "";
  String currentWord = "Current Word: ";

  // Customizable Parameters
  double cameraHeight = 0.5;
  double whiteAreaHeight = 0.5;
  double buttonWidth = 100;
  double buttonHeight = 50;
  double fontSizeCurrentWord = 24;
  double fontSizeDetectedAlphabets = 20;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    _cameraController.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  Future<void> _loadModel() async {
    interpreter = await tfl.Interpreter.fromAsset('assets/model_unquant.tflite');
  }

  @override
  void dispose() {
    _cameraController.dispose();
    interpreter.close();
    super.dispose();
  }

  void _reset() {
    setState(() {
      detectedAlphabets = "";
      currentWord = "Current Word: ";
    });
  }

  void _nextWord() {
    setState(() {
      // Placeholder logic to append detected alphabets to current word
      currentWord += " " + detectedAlphabets;
      detectedAlphabets = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Camera Preview
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).size.height * whiteAreaHeight,
            child: !_cameraController.value.isInitialized
                ? Container()
                : CameraPreview(_cameraController),
          ),
          // White Area
          Positioned(
            top: 10,
            right: 10,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HistoryPage()),
                );
              },
              child: Text(
                'History',
                style: TextStyle(fontSize: 18), // Customizable
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(buttonWidth, buttonHeight),
              ),
            ),
          ),
          // Reset Button
          Positioned(
            top: 10,
            left: 10,
            child: ElevatedButton(
              onPressed: _reset,
              child: Text(
                'Reset',
                style: TextStyle(fontSize: 18), // Customizable
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(buttonWidth, buttonHeight),
              ),
            ),
          ),
          // Next Word Button
          Center(
            child: Container(
              width: 100, // Customizable
              height: 100, // Customizable
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2),
              ),
            ),
          ),
          // Current Word and Detected Alphabets
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            top: MediaQuery.of(context).size.height * cameraHeight,
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    currentWord,
                    style: TextStyle(fontSize: fontSizeCurrentWord),
                  ),
                  Text(
                    detectedAlphabets,
                    style: TextStyle(fontSize: fontSizeDetectedAlphabets),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: ElevatedButton(
                      onPressed: () {
                        _nextWord();
                      },
                      child: Text('Next Word'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(buttonWidth, buttonHeight),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
