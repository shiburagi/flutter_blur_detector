import 'dart:io';
import 'package:blur_detect/camera.dart';
import 'package:blur_detect/helper/tfflite_helper.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Blur Detect',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Classify(),
    );
  }
}

class Classify extends StatefulWidget {
  @override
  _ClassifyState createState() => _ClassifyState();
}

class _ClassifyState extends State<Classify>
    with TickerProviderStateMixin, CameraHelper {
  PickedFile? _image;

  bool _busy = false;
  double _containerHeight = 0;

  late List _recognitions;
  ImagePicker _picker = ImagePicker();

  late AnimationController _controller;
  static const List<IconData> icons = const [Icons.camera_alt, Icons.image];

  Map<String, int> _ingredients = {};
  String _selected0 = "";
  String _selected1 = "";
  String val0 = "";
  String val1 = "";

  bool _isLoading = false;

  void _setLoading(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _busy = true;

    loadModel().then((val) {
      setState(() {
        _busy = false;
      });
    });

    _controller = new AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  loadModel() async {
    TFLiteHelper.instance.close();
    try {
      String res = await TFLiteHelper.instance.load(
            model: "assets/tflite/model.tflite",
            labelsPath: "assets/tflite/labels.txt",
          ) ??
          '';
    } on PlatformException {
      print("Failed to load the model");
    }
  }

  selectFromImagePicker({required bool fromCamera}) async {
    if (fromCamera) {
      setState(() {
        _image == null;
      });
      return;
    }
    PickedFile? pickedFile = fromCamera
        ? await _picker.getImage(source: ImageSource.camera)
        : await _picker.getImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    setState(() {
      _busy = true;
    });
    predictImage(pickedFile);
  }

  predictImage(PickedFile image) async {
    _setLoading(true);

    await classify(image);

    setState(() {
      _image = image;
      _busy = false;
    });

    closeCamera();
    _setLoading(false);
  }

  classify(PickedFile image) async {
    var recognitions = await TFLiteHelper.instance.predict(image);
    updateStateInfo(recognitions);
  }

  updateStateInfo(List<dynamic>? recognitions) {
    setState(() {
      _recognitions = recognitions ?? [];
      print("_recognitions: $_recognitions");
      if (_recognitions.length <= 0) return;
      print("_recognitions[0]: ${_recognitions[0]}");

      if (_recognitions[0]['label'].toString() == "BLUR") {
        _selected0 = "BLUR";
        val0 = '${(_recognitions[0]["confidence"] * 100).toStringAsFixed(0)}%';
      } else {
        _selected0 = '';
        val0 =
            '${(100 - (_recognitions[0]["confidence"] * 100)).toStringAsFixed(0)}%';
      }

      if (_recognitions[0]['label'].toString() == "SHARP") {
        _selected1 = "SHARP";
        val1 = '${(_recognitions[0]["confidence"] * 100).toStringAsFixed(0)}%';
      } else {
        _selected1 = "";
        val1 =
            '${(100 - (_recognitions[0]["confidence"] * 100)).toStringAsFixed(0)}%';
      }
    });
  }

  _imagePreview(PickedFile? image) {
    _controller.reverse();

    return Stack(children: [
      Positioned.fill(
        child: [
          if (image != null)
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    flex: 7,
                    child: FutureBuilder<Uint8List>(
                      future: image.readAsBytes(),
                      builder: (context, snapshot) {
                        final data = snapshot.data;
                        if (data == null) return Container();
                        return Image.memory(data);
                      },
                    ),
                  ),
                ],
              ),
            )
          else if (controller != null)
            Container(child: CameraPreview(controller!))
          else
            noImage()
        ].first,
      ),
      Positioned(
        top: 16,
        left: 32,
        right: 32,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.all(Radius.circular(16))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_selected0 != "BLUR")
                    const Icon(
                      Icons.check_box_outline_blank,
                      color: Colors.white,
                    )
                  else
                    const Icon(
                      Icons.check_box,
                      color: Colors.amber,
                    ),
                  Text("BLUR : ",
                      style: (Theme.of(context).textTheme.bodyMedium ??
                              const TextStyle())
                          .copyWith(color: Colors.white)),
                  Text(
                    val0,
                    style: (Theme.of(context).textTheme.bodyMedium ??
                            const TextStyle())
                        .copyWith(
                            color: Colors.white, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_selected1 != "SHARP")
                    const Icon(
                      Icons.check_box_outline_blank,
                      color: Colors.white,
                    )
                  else
                    const Icon(
                      Icons.check_box,
                      color: Colors.amber,
                    ),
                  Text("SHARP : ",
                      style: (Theme.of(context).textTheme.bodyMedium ??
                              const TextStyle())
                          .copyWith(color: Colors.white)),
                  Text(val1,
                      style: (Theme.of(context).textTheme.bodyMedium ??
                              const TextStyle())
                          .copyWith(
                              color: Colors.white, fontWeight: FontWeight.bold))
                ],
              ),
            ],
          ),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _isLoading,
      progressIndicator:
          SpinKitWanderingCubes(color: Theme.of(context).primaryColor),
      child: Scaffold(
          appBar: AppBar(
            title: Text('Blur Detect'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.image,
                    color: Theme.of(context).secondaryHeaderColor),
                onPressed: () {
                  selectFromImagePicker(fromCamera: false);
                },
              ),
              IconButton(
                icon: Icon(Icons.camera_alt,
                    color: Theme.of(context).secondaryHeaderColor),
                onPressed: () {
                  selectFromImagePicker(fromCamera: true);
                },
              ),
            ],
            backgroundColor: Colors.blue,
            elevation: 0.0,
          ),
          body: _content(_image)),
    );
  }

  noImage() {
    return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.image, size: 100.0, color: Colors.grey),
          ),
          Center(
              child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('No Image',
                style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
          )),
          Center(
            child: Text('Please take or select a photo for blur detection.',
                style: TextStyle(color: Colors.grey)),
          )
        ]);
  }

  _content(PickedFile? image) {
    return _imagePreview(image);
//      returxsdn Container();
  }

  @override
  void onImage(CameraImage image) {
    super.onImage(image);
    TFLiteHelper.instance.predictBytes(image.planes.first.bytes);
  }

  @override
  Future onTake(XFile? image) async {
    super.onTake(image);
    if (image != null) {
      updateStateInfo(
          await TFLiteHelper.instance.predictBytes(await image.readAsBytes()));
    }
  }
}
