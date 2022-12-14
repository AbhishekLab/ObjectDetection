import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';

import 'bndbox.dart';
import 'camera.dart';
import 'models.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();

}



class _HomePageState extends State<HomePage> {
  List<CameraDescription>? cameras;
  List<dynamic>? _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  String _model = "";


  @override
  void initState() {
    super.initState();
    initCamera();
  }


  loadModel() async {
    String? res;
    switch (_model) {
      case yolo:
        res = await Tflite.loadModel(
          model: "assets/yolov2_tiny.tflite",
          labels: "assets/yolov2_tiny.txt",
        );
        break;

      case mobilenet:
        res = await Tflite.loadModel(
            model: "assets/mobilenet_v1_1.0_224.tflite",
            labels: "assets/mobilenet_v1_1.0_224.txt");
        break;

      case posenet:
        res = await Tflite.loadModel(
            model: "assets/posenet_mv1_075_float_from_checkpoints.tflite");
        break;

      default:
        res = await Tflite.loadModel(
            model: "assets/ssd_mobilenet.tflite",
            labels: "assets/ssd_mobilenet.txt");
    }
    print(res);
  }

  onSelect(model) {
    setState(() {
      _model = model;
    });
    loadModel();
  }

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.cyanAccent,
      appBar: AppBar(
        backgroundColor: Colors.cyan[600],
        elevation: 0.0,
        title: Center(
            child: Text(
              'Odetlite',
              style: TextStyle(
                  fontFamily: 'Source Sans Pro',
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                  letterSpacing: 2.5),
            )),
      ),
      body: _model == ""
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            InkWell(
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 50.0,
                child: Icon(
                  Icons.offline_bolt,
                  color: Colors.cyanAccent,
                  size: 50.0,
                ),
              ),
              onTap: () => onSelect(ssd),
            ),
            Padding(
              padding: EdgeInsets.only(top: 50.0),
            ),
            InkWell(
              child: const Text("Start Detection",
                  style: TextStyle(
                      fontFamily: 'Pacifico',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.5)),
              onTap: () => onSelect(ssd),
            ),
            /* FlatButton(
                    child: const Text(yolo,
                        style: TextStyle(
                            fontFamily: 'Pacifico',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.5)),
                    color: Colors.teal[600],
                    onPressed: () => onSelect(yolo),
                  ),
                  FlatButton(
                    child: const Text(mobilenet,
                        style: TextStyle(
                            fontFamily: 'Pacifico',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.5)),
                    color: Colors.teal[600],
                    onPressed: () => onSelect(mobilenet),
                  ),
                  FlatButton(
                    child: const Text(posenet,
                        style: TextStyle(
                            fontFamily: 'Pacifico',
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.5)),
                    color: Colors.teal[600],
                    onPressed: () => onSelect(posenet),
                  ),*/
          ],
        ),
      )
          : Stack(
        children: [
          Camera(
            cameras!,
            _model,
            setRecognitions,
          ),
          BndBox(
              _recognitions == null ? [] : _recognitions!,
              math.max(_imageHeight, _imageWidth),
              math.min(_imageHeight, _imageWidth),
              screen.height,
              screen.width,
              _model),
        ],
      ),
    );
  }

  initCamera() async {
    cameras = await availableCameras();
  }
}