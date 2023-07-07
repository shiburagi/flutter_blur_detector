import 'dart:typed_data';

import 'package:blur_detect/helper/tfflite_helper_base.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_web/tflite_web.dart';

class PlatformTFLiteHelper implements BaseTFLiteHelper {
  @override
  void close() {}

  @override
  void initialize() {
    // TODO: implement initialize
  }
  TFLiteModel? _tfLieModel = null;

  @override
  Future<String?> load({required String model, String? labelsPath}) {
    TFLiteWeb.initialize().then((value) async {
      _tfLieModel = await TFLiteModel.fromUrl(model);
      print("initilize");
    }).catchError((e) {
      print(e);
    });

    return Future.value("");
  }

  final labels = ["BLUR", "SHARP"];
  @override
  Future<List?> predictBytes(Uint8List bytes) async {
    img.Image? _decodedImg = img.decodeImage(bytes);
    img.Image? decodedImg = _decodedImg == null
        ? null
        : img.copyResize(_decodedImg, width: 600, height: 600);

    Uint8List rgbs =
        decodedImg?.getBytes(format: img.Format.rgb) ?? Uint8List(0);
    Float32List list =
        Float32List.fromList(rgbs.map((e) => e / 255.0).toList());
    debugPrint("size: ${list.length} , ${rgbs.length}");

    final width = decodedImg?.width ?? 0;
    final height = decodedImg?.height ?? 0;
    debugPrint("w h: ${decodedImg?.width ?? 0}, ${decodedImg?.height}");
    debugPrint("dimension: ${width * height}, ${rgbs.length / 3}");

    final tensor = createTensor(
      list,
      shape: [1, width, height, 3],
      type: TFLiteDataType.float32,
    );
    final result = _tfLieModel?.predict<Tensor>(tensor);
    final data = await result?.dataSync<Future<List<double>>>();
    debugPrint("data: ${data}");
    int i = 0;
    return data
        ?.map((e) => ({
              "label": labels[i++],
              "confidence": e,
            }))
        .fold(
            [],
            (value, element) => value.isNotEmpty &&
                    value[0]["confidence"] > element["confidence"]
                ? value
                : [element]).toList();
  }

  @override
  Future<List?> predict(PickedFile image) async {
    // TODO: implement predict
    return predictBytes(await image.readAsBytes());
  }
}
