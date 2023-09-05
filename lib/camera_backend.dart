import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;
import 'package:flutter/services.dart';

class Classifier {
  late tfl.Interpreter _interpreter;
  List<String>? _labels;

  Future<void> loadModel() async {
    _interpreter = await tfl.Interpreter.fromAsset('assets/model/model_unquant.tflite');
    _labels = await rootBundle.loadString('assets/model/labels.txt').then((value) => value.split('\n'));
  }

  Future<String> classify(Uint8List imageBytes) async {
    var input = imageBytes.buffer.asFloat32List(); // Convert to appropriate type
    var output = List.filled(_labels!.length, 0.0).reshape([1, _labels!.length]);

    _interpreter.run(input, output);

    final highestProbIndex = output.indexWhere((value) => value == output.reduce((value, element) => value > element ? value : element));
    return _labels![highestProbIndex];
  }
}

