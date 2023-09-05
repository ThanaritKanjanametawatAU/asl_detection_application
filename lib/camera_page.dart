import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'history_page.dart';  // Make sure you have this file in your project
import 'dart:ui';
import 'camera_focusbox.dart';
import 'camera_backend.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;



class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  late tfl.Interpreter interpreter;

  String detectedAlphabets = "";
  String currentWord = "Current Word: ";
  List<File> capturedImages = [];

  // Customizable Parameters
  double cameraHeight = 0.7; // Height of camera preview
  double whiteAreaHeight = 0.3; // Height of white area
  double buttonWidth = 120; // Customizable button width
  double buttonHeight = 50; // Customizable button height
  double fontSizeCurrentWord = 24; // Customizable font size for current word
  double fontSizeDetectedAlphabets = 20; // Customizable font size for detected alphabets
  double focusBoxSize = 275;  // Customizable focus box size
  double buttonVerticalOffset = 40;  // Customizable button vertical offset
  double buttonBorderDistance = 50; // Customizable distance between button and border
  double nextButtonBorderDistance = 25; // Customizable distance between next button and border
  double focusBoxCenterOffset = 60; // Customizable distance between focus box and center
  Color overlayColor = Colors.black.withOpacity(0.5);  // Color of the overlay



  @override
  void initState() {
    super.initState();
    _requestPermission();
    _initializeCamera();
    _loadModel();
  }


  // Initialize camera
  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.medium, );
    _cameraController.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    });
    Timer.periodic(Duration(seconds: 10), (Timer t) => _captureImage());
  }

  Future<void> _captureImage() async {
    if (_cameraController.value.isInitialized) {
      // Generate the file path
      final dir = await getTemporaryDirectory();
      final String path = p.join(
        dir.path,
        'image_${DateTime.now()}.jpg',
      );

      try {
        // Capture the image and save it to the given path
        XFile file = await _cameraController.takePicture();
        File savedFile = File(path);

        // Move the file to the new path
        await file.saveTo(path);

        // Add to your capturedImages list
        capturedImages.add(savedFile);
      } catch (e) {
        print('Error capturing image: $e');
      }
    }
  }

  Future<void> _requestPermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    if (status.isGranted) {
      // Pop up a dialog to inform user that you will be using storage
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Storage Permission Granted"),
          content: Text("This app will now be able to store images in your device"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
    } else {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Storage Permission Denied"),
          content: Text("This app will not be able to store images in your device"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  // Load TFLite model
  Future<void> _loadModel() async {
    interpreter = await tfl.Interpreter.fromAsset('assets/model_unquant.tflite');
  }

  // Dispose camera controller and interpreter
  @override
  void dispose() {
    _cameraController.dispose();
    interpreter.close();
    super.dispose();
  }

  // Reset the detected alphabets
  void _reset() {
    setState(() {
      detectedAlphabets = "";
      currentWord = "Current Word: ";
    });
  }

  // Append detected alphabets to current word
  void _nextWord() {
    setState(() {
      currentWord = "Current Word: ";
      detectedAlphabets = "";
    });
  }

  // Run inference on each frame
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

          // Overlay
          Positioned.fill(
            child: CustomPaint(
              painter: FocusBoxPainter(
                focusBoxSize: focusBoxSize,
                focusBoxOffset: focusBoxCenterOffset,
                overlayColor: Colors.black.withOpacity(0.5),
              ),
            ),
          ),

          // History Button
          Positioned(
            top: buttonVerticalOffset,  // Customizable
            right: buttonBorderDistance, // Customizable
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryPage(capturedImages: capturedImages),
                  )
              ),
              child: Text('History', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(buttonWidth, buttonHeight),  // Customizable
              ),
            ),
          ),

          // Reset Button
          Positioned(
            top: buttonVerticalOffset,  // Customizable
            left: buttonBorderDistance, // Customizable
            child: ElevatedButton(
              onPressed: _reset,
              child: Text('Reset', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(buttonWidth, buttonHeight),  // Customizable
              ),
            ),
          ),

          // Focus Box
          Positioned(
            top: MediaQuery.of(context).size.height * 0.5 - focusBoxSize / 2 - focusBoxCenterOffset,
            left: MediaQuery.of(context).size.width * 0.5 - focusBoxSize / 2,
            child: Container(
              width: focusBoxSize,
              height: focusBoxSize,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 4),
              ),
            ),
          ),

          // White Area for detected alphabets and current word
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
                  // Current Word
                  Align(
                    alignment: Alignment.center,
                    child: Text(currentWord, style: TextStyle(fontSize: fontSizeCurrentWord)),
                  ),

                  // Detected Alphabets
                  Text(detectedAlphabets, style: TextStyle(fontSize: fontSizeDetectedAlphabets)),  // Customizable

                  // Next Word Button
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: EdgeInsets.all(nextButtonBorderDistance),  // Customizable
                      child: ElevatedButton(
                        onPressed: _nextWord,
                        child: Text('Next Word'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(buttonWidth, buttonHeight),  // Customizable
                        ),
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