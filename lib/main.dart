import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'Recipe.dart';

void main() {
  runApp(MaterialApp(
    home: MyHomePage(),
  ));
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}
// Placeholder for RecipeSuggestionsPage widget

class _MyHomePageState extends State<MyHomePage> {
  late ImagePicker imagePicker;
  File? _image;
  String result = '';
  var image;
  late List<DetectedObject> objects;
  //TODO declare detector
  dynamic objectDetector;
  List<String> uniqueLabelsList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imagePicker = ImagePicker();
    //TODO initialize detector
    createObjectDetector();
  }

  @override
  void dispose() {
    super.dispose();
    objectDetector.close();
  }

  //TODO capture image using camera
  _imgFromCamera() async {
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      doObjectDetection();
    }
  }

  //TODO choose image using gallery
  _imgFromGallery() async {
    XFile? pickedFile =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _image = File(pickedFile.path);
      doObjectDetection();
    }
  }

  Future<String> _getModel(String assetPath) async {
    if (Platform.isAndroid) {
      return 'flutter_assets/$assetPath';
    }
    final path = '${(await getApplicationSupportDirectory()).path}/$assetPath';
    await Directory(dirname(path)).create(recursive: true);
    final file = File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(assetPath);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }

  createObjectDetector() async {
    final modelPath = await _getModel('assets/ml/mobilenet_metadata.tflite');
    final options = LocalObjectDetectorOptions(
        modelPath: modelPath,
        classifyObjects: true,
        multipleObjects: true,
        mode: DetectionMode.single);
    objectDetector = ObjectDetector(options: options);
  }

  //TODO object detection code here
  doObjectDetection() async {
    final inputImage = InputImage.fromFile(_image!);
    objects = await objectDetector.processImage(inputImage);
    Set<String> uniqueLabels = Set();

    for (var obj in objects) {
      for (var label in obj.labels) {
        uniqueLabels.add(label.text);
      }
    }

    setState(() {
      uniqueLabelsList = uniqueLabels.toList();
    });

    drawRectanglesAroundObjects();
  }

  //TODO draw rectangles
  drawRectanglesAroundObjects() async {
    image = await _image?.readAsBytes();
    image = await decodeImageFromList(image);
    setState(() {
      image;
      objects;
      result;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/bg.jpg'), fit: BoxFit.cover),
        ),
        child: Column(
          children: [
            const SizedBox(
              width: 100,
            ),
            Container(
              margin: const EdgeInsets.only(top: 100),
              child: Stack(children: <Widget>[
                Center(
                  child: ElevatedButton(
                    onPressed: _imgFromGallery,
                    onLongPress: _imgFromCamera,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent),
                    child: Container(
                      width: 350,
                      height: 350,
                      margin: const EdgeInsets.only(
                        top: 45,
                      ),
                      child: image != null
                          ? Center(
                              child: FittedBox(
                                child: SizedBox(
                                  width: image.width.toDouble(),
                                  height: image.width.toDouble(),
                                  child: CustomPaint(
                                    painter: ObjectPainter(
                                        objectList: objects, imageFile: image),
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              color: Colors.pinkAccent,
                              width: 350,
                              height: 350,
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.black,
                                size: 53,
                              ),
                            ),
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // When the "Generate" button is pressed, navigate to the RecipeSuggestionsPage.
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) =>
                          RecipeSuggestionsPage(ingredients: uniqueLabelsList)),
                );
              },
              child: Text('Generate'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green, // Button text color
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: uniqueLabelsList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(uniqueLabelsList[index],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontFamily: 'finger_paint',
                            fontSize: 24,
                            color: Colors.white)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ObjectPainter extends CustomPainter {
  List<DetectedObject> objectList;
  dynamic imageFile;
  Set<String> uniqueLabels =
      Set(); // Declare a Set to keep track of unique labels

  ObjectPainter({required this.objectList, required this.imageFile});

  @override
  void paint(Canvas canvas, Size size) {
    if (imageFile != null) {
      canvas.drawImage(imageFile, Offset.zero, Paint());
    }
    Paint p = Paint();
    p.color = Colors.red;
    p.style = PaintingStyle.stroke;
    p.strokeWidth = 4;

    for (DetectedObject obj in objectList) {
      canvas.drawRect(obj.boundingBox, p);
      for (Label label in obj.labels) {
        // Check if the label text is already in the set
        if (!uniqueLabels.contains(label.text)) {
          // If not, print the label and add it to the set
          print("${label.text}   ${label.confidence.toStringAsFixed(2)}");
          uniqueLabels.add(label.text); // Add the label text to the set

          TextSpan span = TextSpan(
              text: label.text,
              style: const TextStyle(fontSize: 25, color: Colors.blue));
          TextPainter tp = TextPainter(
              text: span,
              textAlign: TextAlign.left,
              textDirection: TextDirection.ltr);
          tp.layout();
          tp.paint(canvas, Offset(obj.boundingBox.left, obj.boundingBox.top));
          break; // Assuming you only want to print the first label per object
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
