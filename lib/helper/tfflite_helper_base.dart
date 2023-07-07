import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

class BaseTFLiteHelper {
  void initialize() {}
  Future<String?> load({required String model, String? labelsPath}) {
    return Future.value(null);
  }

  Future<List<dynamic>?> predict(PickedFile image) async {
    return null;
  }

  Future<List<dynamic>?> predictBytes(Uint8List bytes) async {
    return null;
  }

  void close() {}
}
