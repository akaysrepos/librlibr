import 'dart:collection';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:libirlibir/institution/Issue.dart';
import 'package:libirlibir/login.dart';

import '../locator.dart';
import '../services/camera.service.dart';
import '../services/face_detector_service.dart';
import '../services/ml_service.dart';

class Verify extends StatefulWidget {
  const Verify({Key? key}) : super(key: key);

  @override
  _VerifyState createState() => _VerifyState();
}

class _VerifyState extends State<Verify> {
  final MLService _mlService = locator<MLService>();

  bool image = false;
  TextEditingController mobileController = TextEditingController();
  late Future<void> _initializeControllerFuture;
  bool isCameraReady = false;
  bool showCapturedPhoto = false;
  var ImagePath;
  late Face faceDetected;
  late Size imageSize;
  List data = [];
  List faceData = [];

  bool _detectingFaces = false;

  // switchs when the user press the camera
  bool _saving = false;

  final FaceDetectorService _faceDetectorService =
      locator<FaceDetectorService>();
  final CameraService _cameraService = locator<CameraService>();

  @override
  void initState() {
    super.initState();
    // isMarked();
    _mlService.loadModel();
    _faceDetectorService.initialize();
    // getFaceData();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraService.cameraController.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    // final firstCamera = cameras[1];
    var cameraDescription = cameras.firstWhere(
      (CameraDescription camera) =>
          camera.lensDirection == CameraLensDirection.front,
    );
    // _controller = CameraController(firstCamera, ResolutionPreset.high);
    _initializeControllerFuture =
        _cameraService.startService(cameraDescription);
    await _initializeControllerFuture;

    if (!mounted) {
      return;
    }
    setState(() {
      isCameraReady = true;
    });
    _frameFaces();
  }

  _frameFaces() {
    imageSize = _cameraService.getImageSize();

    _cameraService.cameraController.startImageStream((image) async {
      if (_cameraService.cameraController != null) {
        if (_detectingFaces) return;

        _detectingFaces = true;

        try {
          List<Face> faces =
              await _faceDetectorService.getFacesFromImage(image);

          if (faces.length > 0) {
            // setState(() {
            //   print("has a face");
            //   sKey.currentState!
            //       .showSnackBar(const SnackBar(content: Text("Detected!")));
            faceDetected = faces[0];
            // });

            if (_saving) {
              setState(() async {
                faceData =
                    await _mlService.setCurrentPrediction(image, faceDetected);
                // sKey.currentState!.showSnackBar(
                //     SnackBar(content: Text(faceData.length.toString())));
              });
              setState(() {
                _saving = false;
              });
            }
          }
          //  else {
          //   setState(() {
          //     faceDetected = null;
          //   });
          // }

          _detectingFaces = false;
        } catch (e) {
          print(e);
          _detectingFaces = false;
        }
      }
    });
  }

  getFaceData() async {
    firestore
        .collection("maglib")
        .doc("users")
        .collection(mobileController.text.toString())
        .doc("details")
        .get()
        .then((value) async {
      if (value.exists) {
        setState(() {
          data.addAll(value['data']);
          // sKey.currentState!
          //     .showSnackBar(SnackBar(content: Text(data.length.toString())));
        });
      }
    });
  }

  verify(BuildContext context, String number) async {
    bool face = await _mlService.searchResult(data, faceData);
    if (face) {
      // sKey.currentState!.showSnackBar(SnackBar(content: Text(face.toString())));
      // mark();
      Navigator.of(context).push(
          MaterialPageRoute(builder: ((context) => Issue(number: number))));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Try Again')));
    }
  }

  void onCaptureButtonPressed() async {
    //on camera button press
    if (faceDetected != null) {
      try {
        // final path = p.join(
        //   (await getTemporaryDirectory()).path, //Temporary path
        //   '${DateTime.now()}.png',
        // );
        // ImagePath = path;
        _saving = true;
        await Future.delayed(const Duration(milliseconds: 500));
        await _cameraService.cameraController.stopImageStream();
        await Future.delayed(const Duration(milliseconds: 200));
        XFile file = await _cameraService.cameraController.takePicture();
        ImagePath = file.path; //take photo

        setState(() {
          _saving = true;
          showCapturedPhoto = true;
        });
      } catch (e) {
        print(e);
      }
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text('No face detected!'),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        (!image && isCameraReady)
            ? FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    // If the Future is complete, display the preview.
                    return Transform.scale(
                      scale: 1.0,
                      child: AspectRatio(
                        aspectRatio: MediaQuery.of(context).size.aspectRatio,
                        child: OverflowBox(
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.fitHeight,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.width *
                                  _cameraService
                                      .cameraController.value.aspectRatio,
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                fit: StackFit.expand,
                                children: <Widget>[
                                  showCapturedPhoto
                                      ? Center(
                                          child: Image.file(File(ImagePath)))
                                      : CameraPreview(
                                          _cameraService.cameraController),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        showCapturedPhoto && data.isEmpty
                                            ? TextFormField(
                                                keyboardType:
                                                    TextInputType.phone,
                                                textAlign: TextAlign.center,
                                                controller: mobileController,
                                                decoration:
                                                    const InputDecoration(
                                                        hintText:
                                                            "Enter Number"),
                                              )
                                            : Container(),
                                        showCapturedPhoto && data.isEmpty
                                            ? ElevatedButton(
                                                onPressed: getFaceData,
                                                child: const Text("Get"))
                                            : Container(),
                                        !showCapturedPhoto
                                            ? ElevatedButton(
                                                onPressed:
                                                    onCaptureButtonPressed,
                                                child:
                                                    const Text("Add Face data"))
                                            : Container(),
                                        data.isNotEmpty && faceData.isNotEmpty
                                            ? ElevatedButton(
                                                onPressed: () => verify(context,
                                                    mobileController.text),
                                                child: const Text("Verify"))
                                            : Container(),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return const Center(
                        child:
                            CircularProgressIndicator()); // Otherwise, display a loading indicator.
                  }
                },
              )
            : Container(),
      ],
    ));
    // return Scaffold(
    //   body: Center(
    //       child: Column(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     mainAxisSize: MainAxisSize.max,
    //     children: [
    //       TextFormField(
    //         // initialValue: widget.number,
    //         keyboardType: TextInputType.phone,
    //         textAlign: TextAlign.center,
    //         controller: phoneController,
    //         decoration: const InputDecoration(hintText: "Enter Number"),
    //       ),
    //       const SizedBox(
    //         height: 20.0,
    //       ),
    //       TextButton(
    //           onPressed: startBarcodeScanStream, child: const Text("Scan")),
    //       // ListView(
    //       //   shrinkWrap = true,
    //       //   children: books.map((e) => Text(e)).toList(),
    //       // ),
    //       TextButton(onPressed: () {}, child: const Text("Issue")),
    //     ],
    //   )),
    // );
  }
}
