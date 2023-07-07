import 'dart:typed_data';

import 'package:blur_detect/helper/tfflite_helper_base.dart';
import 'package:blur_detect/helper/tfflite_helper_mobile.dart'
    if (dart.library.html) 'package:blur_detect/helper/tfllite_helper_web_2.dart';
import 'package:image_picker/image_picker.dart';

class TFLiteHelper implements BaseTFLiteHelper {
  BaseTFLiteHelper helper = PlatformTFLiteHelper();
  static TFLiteHelper instance = TFLiteHelper();

  @override
  void close() {
    helper.close();
  }

  @override
  void initialize() {
    helper.initialize();
  }

  @override
  Future<String?> load({required String model, String? labelsPath}) {
    return helper.load(model: model, labelsPath: labelsPath);
  }

  @override
  Future<List?> predict(PickedFile image) {
    return helper.predict(image);
  }

  @override
  Future<List?> predictBytes(Uint8List bytes) {
    return helper.predictBytes(bytes);
  }
}
