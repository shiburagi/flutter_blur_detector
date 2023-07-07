// import 'dart:io';
// import 'dart:math';

// import 'package:blur_detect/helper/tfflite_helper_base.dart';
// import 'package:collection/collection.dart';
// import 'package:image/image.dart';
// import 'package:tflite_flutter_helper_plus/tflite_flutter_helper_plus.dart';
// import 'package:tflite_flutter_plus/tflite_flutter_plus.dart';
// import 'package:logger/logger.dart';

// class WebTFLiteHelper implements BaseTFLiteHelper {
//   late Interpreter interpreter;
//   late InterpreterOptions _interpreterOptions;

//   var logger = Logger();

//   late List<int> _inputShape;
//   late List<int> _outputShape;

//   late TensorImage _inputImage;
//   late TensorBuffer _outputBuffer;

//   late TfLiteType _inputType;
//   late TfLiteType _outputType;

//   final int _labelsLength = 1001;

//   late var _probabilityProcessor;

//   late List<String> labels;

//   NormalizeOp get preProcessNormalizeOp => NormalizeOp(0, 1);

//   NormalizeOp get postProcessNormalizeOp => NormalizeOp(0, 255);

//   @override
//   void close() {}

//   @override
//   void initialize() {
//     // TODO: implement initialize
//   }

//   @override
//   Future<String?> load({required String model, String? labelsPath}) async {
//     try {
//       interpreter =
//           await Interpreter.fromAsset(model, options: _interpreterOptions);
//       print('Interpreter Created Successfully');

//       _inputShape = interpreter.getInputTensor(0).shape;
//       _outputShape = interpreter.getOutputTensor(0).shape;
//       _inputType = interpreter.getInputTensor(0).type;
//       _outputType = interpreter.getOutputTensor(0).type;

//       _outputBuffer = TensorBuffer.createFixedSize(_outputShape, _outputType);
//       _probabilityProcessor =
//           TensorProcessorBuilder().add(postProcessNormalizeOp).build();
//     } catch (e) {
//       print('Unable to create interpreter, Caught Exception: ${e.toString()}');
//     }

//     labels = await FileUtil.loadLabels(labelsPath ?? "");
//     if (labels.length == _labelsLength) {
//       print('Labels loaded successfully');
//     } else {
//       print('Unable to load labels');
//     }

//     return Future.value("");
//   }

//   TensorImage _preProcess() {
//     int cropSize = min(_inputImage.height, _inputImage.width);
//     return ImageProcessorBuilder()
//         .add(ResizeWithCropOrPadOp(cropSize, cropSize))
//         .add(ResizeOp(
//             _inputShape[1], _inputShape[2], ResizeMethod.nearestneighbour))
//         .add(preProcessNormalizeOp)
//         .build()
//         .process(_inputImage);
//   }

//   MapEntry<String, double> getTopProbability(Map<String, double> labeledProb) {
//     var pq = PriorityQueue<MapEntry<String, double>>(compare);
//     pq.addAll(labeledProb.entries);

//     return pq.first;
//   }

//   int compare(MapEntry<String, double> e1, MapEntry<String, double> e2) {
//     if (e1.value > e2.value) {
//       return -1;
//     } else if (e1.value == e2.value) {
//       return 0;
//     } else {
//       return 1;
//     }
//   }

//   @override
//   Future<List?> predict(File image) async {
//     Image imageInput = decodeImage(image.readAsBytesSync())!;

//     final pres = DateTime.now().millisecondsSinceEpoch;
//     _inputImage = TensorImage(_inputType);
//     _inputImage.loadImage(Image.from(imageInput));
//     _inputImage = _preProcess();
//     final pre = DateTime.now().millisecondsSinceEpoch - pres;

//     print('Time to load image: $pre ms');

//     final runs = DateTime.now().millisecondsSinceEpoch;
//     interpreter.run(_inputImage.buffer, _outputBuffer.getBuffer());
//     final run = DateTime.now().millisecondsSinceEpoch - runs;

//     print('Time to run inference: $run ms');

//     Map<String, double> labeledProb = TensorLabel.fromList(
//             labels, _probabilityProcessor.process(_outputBuffer))
//         .getMapWithFloatValue();
//     final pred = getTopProbability(labeledProb);

//     Category(pred.key, pred.value);
//     return Future.value(null);
//   }
// }
