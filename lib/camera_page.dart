import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'history_page.dart';  // Make sure you have this file in your project
import 'camera_focusbox.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';


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
  List<String> capturedAlphabets = [];
  List<String> labels = [];

  // Customizable Parameters
  double cameraHeight = 0.7; // Height of camera preview
  double whiteAreaHeight = 0.3; // Height of white area
  double buttonWidth = 120; // Customizable button width
  double buttonHeight = 50; // Customizable button height
  double fontSizeCurrentWord = 24; // Customizable font size for current word
  double fontSizeDetectedAlphabets = 26; // Customizable font size for detected alphabets
  double focusBoxSize = 275;  // Customizable focus box size
  double buttonVerticalOffset = 40;  // Customizable button vertical offset
  double buttonBorderDistance = 50; // Customizable distance between button and border
  double nextButtonBorderDistance = 25; // Customizable distance between next button and border
  double focusBoxCenterOffset = 60; // Customizable distance between focus box and center
  Color overlayColor = Colors.black.withOpacity(0.5);  // Color of the overlay

  int imageInputWidth = 480;
  int imageInputHeight = 270;

  int labelBufferSize = 6;



  @override
  void initState() {
    _initializeCamera();
    super.initState();
    _requestPermission();
    loadLabels();
    _loadModel();
  }


  // Initialize camera
  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
      await _cameraController.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      print("Error initializing camera: $e");
    }

    // set Camera Interval
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _captureImage());
  }

  // Load Labels from labels.txt
  Future<void> loadLabels() async {
    final labelData = await rootBundle.loadString('assets/model/labels.txt');
    labels = labelData.split('\n');
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

        // Delete the first image if the list length is greater than 5
        if (capturedImages.length > labelBufferSize) {

          // if all element in capturedAlphabets is the same, add to detectedAlphabets
          if (capturedAlphabets.every((element) => element == capturedAlphabets[0])) {
            setState(() {
              detectedAlphabets += capturedAlphabets[0];
              // clear capturedAlphabets and clear and delete files in capturedImages
              capturedAlphabets.clear();

              for (int i = 0; i < capturedImages.length; i++) {
                capturedImages[i].delete();
              }
              capturedImages.clear();

            });
          }
          else{
            capturedImages.first.delete();
            capturedImages.removeAt(0);
          };
        }


        // Perform inference on the captured image
        _showInferenceResult();  // Call inference function here



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
  }

  // Load TFLite model
  Future<void> _loadModel() async {
    interpreter = await tfl.Interpreter.fromAsset('assets/model/model_unquant.tflite');
  }



// Perform inference on each image and get predictions
  Future<String> performInference(Uint8List imgBytes) async {
    String result = "";

    img.Image? image = img.decodeImage(imgBytes);
    img.Image resizedImg = img.copyResize(image!, width: imageInputWidth, height: imageInputHeight);

    // Convert to 4D tensor-like structure
    var tensor = Float32List(1 * imageInputWidth * imageInputHeight * 3);
    var index = 0;
    for (int y = 0; y < 29; y++) {
      for (int x = 0; x < 29; x++) {
        final pixel = resizedImg.getPixel(x, y);
        tensor[index++] = img.getRed(pixel) / 255.0;
        tensor[index++] = img.getGreen(pixel) / 255.0;
        tensor[index++] = img.getBlue(pixel) / 255.0;
      }
    }

    final inputShape = [1, imageInputWidth, imageInputHeight, 3];
    final outputShape = [1, 27];

    var output = Float32List(1 * 27).reshape(outputShape);


    var options = tfl.InterpreterOptions()..threads = 1;
    final interpreter = await tfl.Interpreter.fromAsset('assets/model/model_unquant.tflite', options: options);

    interpreter.run(tensor.reshape(inputShape), output);

    double highestProb = 0;
    int labelIndex = 0;

    int minLength = (output[0].length < labels.length) ? output[0].length : labels.length;

    for (int i = 0; i < minLength; i++) {
      print("${labels[i]}: ${output[0][i]}");
      if (output[0][i] > highestProb) {
        highestProb = output[0][i];
        labelIndex = i;
      }
    }

    String label = labels[labelIndex][3];
    result = "$label";

    return result;
  }

  Future<void> _showInferenceResult() async {
    File latestImage = capturedImages.last;

    Uint8List imgBytes = await latestImage.readAsBytes();

    String inferenceResult = await performInference(imgBytes);

    // add result to capturedAlphabets
    capturedAlphabets.add(inferenceResult);

    print("Inference Result: $inferenceResult");
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
            child: _cameraController.value.isInitialized == true
                ? CameraPreview(_cameraController)
                : Container(),
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
              style: ElevatedButton.styleFrom(
                minimumSize: Size(buttonWidth, buttonHeight),  // Customizable
              ),
              child: const Text('History', style: TextStyle(fontSize: 18)),
            ),
          ),

          // Reset Button
          Positioned(
            top: buttonVerticalOffset,  // Customizable
            left: buttonBorderDistance, // Customizable
            child: ElevatedButton(
              onPressed: _reset,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(buttonWidth, buttonHeight),  // Customizable
              ),
              child: const Text('Reset', style: TextStyle(fontSize: 18)),
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
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(buttonWidth, buttonHeight),  // Customizable
                        ),
                        child: const Text('Next Word'),
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