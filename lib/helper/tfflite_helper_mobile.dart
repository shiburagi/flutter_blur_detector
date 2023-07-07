import 'dart:typed_data';

import 'package:blur_detect/helper/tfflite_helper_base.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class PlatformTFLiteHelper implements BaseTFLiteHelper {
  @override
  void initialize() {}

  @override
  void close() {
    Tflite.close();
  }

  @override
  Future<String?> load({required String model, String? labelsPath}) {
    return Tflite.loadModel(
      model: model,
      labels: labelsPath ?? "",
    );
  }

  @override
  Future<List<dynamic>?> predict(PickedFile image) {
    return Tflite.runModelOnImage(
        path: image.path, // required
        imageMean: 0.0, // defaults to 117.0
        imageStd: 255.0, // defaults to 1.0
        numResults: 2, // defaults to 5
        threshold: 0.2, // defaults to 0.1
        asynch: true // defaults to true
        );
  }

  @override
  Future<List?> predictBytes(Uint8List bytes) {
    // TODO: implement predictBytes
    throw UnimplementedError();
  }
}
