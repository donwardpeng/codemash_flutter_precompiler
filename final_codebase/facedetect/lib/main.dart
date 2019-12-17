import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:image_picker/image_picker.dart';
import 'detector_painters.dart';
import 'dart:io';
import 'dart:async';
import 'dart:ui';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Detection Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: MyHomePage(title: 'Face Detection Demo'),
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the MyHomePage widget.
        '/': (context) => MyHomePage(title: 'Face Detection Demo'),
        // When navigating to the "/second" route, build the SecondScreen widget.
        //'/faceDetectCamera': (context) => FaceDetectScreen(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _imageFile;
  Size _imageSize;
  dynamic _scanResults;
  Detector _currentDetector = Detector.text;
  final FaceDetector _faceDetector = FirebaseVision.instance.faceDetector(
      FaceDetectorOptions(
          mode: FaceDetectorMode.fast,
          enableLandmarks: true,
          enableContours: true));

/* back button handler */
  Future<bool> _onWillPop() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to exit the App?'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              setState(() {
                _imageFile = null;
                _imageSize = null;
              });
              Navigator.of(context).pop(false);
            },
            child: new Text('No'),
          ),
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: new Text('Yes'),
          ),
        ],
      ),
    ) ??
        false;
  }

/* _getAndScanImage method */
  Future<void> _getAndScanImage({bool selectedFromCamera}) async {
    print('_getAndScanImage method called');
    setState(() {
      _imageFile = null;
      _imageSize = null;
    });

    final File imageFile = await ImagePicker.pickImage(
        source: selectedFromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000);

    print('here');
    if (imageFile != null) {
      _getImageSize(imageFile);
      _scanImage(imageFile);
    }
    print('here1');

    setState(() {
      _imageFile = imageFile;
      print('here2');
    });
  }

/* _getImageSize method */
  Future<void> _getImageSize(File imageFile) async {
    print('_getImageSize method called');
    final Completer<Size> completer = Completer<Size>();

    final Image image = Image.file(imageFile);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }),
    );

    final Size imageSize = await completer.future;
    setState(() {
      _imageSize = imageSize;
    });
  }

/* _scanImage method */
  Future<void> _scanImage(File imageFile) async {
    print('_scanImage method called');
    setState(() {
      _scanResults = null;
    });

    final FirebaseVisionImage visionImage =
    FirebaseVisionImage.fromFile(imageFile);

    dynamic results;
    switch (_currentDetector) {
      case Detector.face:
        results = await _faceDetector.processImage(visionImage);
        break;
      default:
        return;
    }

    setState(() {
      _scanResults = results;
    });
  }

/* _buildResults method */
  CustomPaint _buildResults(Size imageSize, dynamic results) {
    print('_buildResults method called');
    CustomPainter painter;

    switch (_currentDetector) {
      case Detector.face:
        painter = FaceDetectorPainter(_imageSize, results);
        break;
      default:
        break;
    }

    return CustomPaint(
      painter: painter,
    );
  }

/* _buildImage() method - build the image to display in body of the app */
  Widget _buildImage() {
    print('_buildImage method called');
    return Stack(children: <Widget>[
      Positioned.fill(
          child: Container(
            constraints: BoxConstraints.expand(),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: Image.file(_imageFile).image,
                fit: BoxFit.fitWidth,
              ),
            ),
            child: _imageSize == null || _scanResults == null
                ? const Center(child: CircularProgressIndicator())
                : _buildResults(_imageSize, _scanResults),
          )),
      Positioned(
          bottom: 25,
          width: MediaQuery.of(context).size.width,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  child: Text('Save Image'),
                  onPressed: () {},
                )
              ]))
    ]);
  }

  @override
  Widget build(BuildContext context) {
    _currentDetector = Detector.face;
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: _imageFile == null
            ? Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('No image selected.'),
                  RaisedButton(
                      child: Text("Detect Faces from Gallery Image"),
                      onPressed: () {
                        _getAndScanImage(selectedFromCamera: false);
                      }),
                  RaisedButton(
                      child: Text("Detect Faces from Camera"),
                      onPressed: () {
                        _getAndScanImage(selectedFromCamera: true);
                      })
                ]))
            : _buildImage(),
      ),
      onWillPop: _onWillPop,
    );
  }

  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }
}
