import 'package:calculator/main.dart';
import 'package:camera/camera.dart';

import 'package:flutter/material.dart';
import 'package:tensorflow_lite_flutter/tensorflow_lite_flutter.dart';

class emotion_detector extends StatefulWidget {
  const emotion_detector({super.key});

  @override
  State<emotion_detector> createState() => _emotion_detectorState();
}

class _emotion_detectorState extends State<emotion_detector> {
  CameraController? cameraController;
  String output = '';
  double? per;

  loadCamera() {
    cameraController = CameraController(cameras![0], ResolutionPreset.high);
    cameraController!.initialize().then((value) {
      if (!mounted) {
        return;
      } else {
        setState(() {
          cameraController!.startImageStream((image) {
            runModel(image);
          });
        });
      }
    });
  }

  runModel(CameraImage img) async {
    dynamic recognitions = await Tflite.runModelOnFrame(
        bytesList: img.planes.map((plane) {
          return plane.bytes;
        }).toList(), // required
        imageHeight: img.height,
        imageWidth: img.width,
        imageMean: 127.5, // defaults to 127.5
        imageStd: 127.5, // defaults to 127.5
        rotation: 90, // defaults to 90, Android only
        numResults: 2, // defaults to 5
        threshold: 0.1, // defaults to 0.1
        asynch: true // defaults to true
        );
    for (var element in recognitions) {
      setState(() {
        output = element['label'];
      });
    }
    ;
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets\model_unquant.tflite', labels: 'assets\labels.txt');
  }

  @override
  void initState() {
    super.initState();
    loadCamera();
    loadModel();
  }

  @override
  void dispose() {
    super.dispose();
    cameraController!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Emotion Detetcor"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: SizedBox(
                width: MediaQuery.of(context).size.height * 0.5,
                height: MediaQuery.of(context).size.width,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: CameraPreview(cameraController!),
                ),
              ),
            ),
            SizedBox(
              height: 35,
            ),
            Text(
              output,
              style: TextStyle(color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
