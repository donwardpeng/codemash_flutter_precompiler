import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:image_picker/image_picker.dart';
import 'detector_painters.dart';
import 'dart:io';
import 'dart:async';
import 'dart:ui';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:screenshot/screenshot.dart';

// main method
void main() => runApp(MyApp());

// MyApp class for the app - root of the application
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Detection Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // set the only route for the app - you could add more here
      initialRoute: '/',
      routes: {
        '/': (context) => FirstScreen(title: 'Face Detection Demo'),
      },
    );
  }
}

// First Screen extends the StatefulWidget class
class FirstScreen extends StatefulWidget {
  FirstScreen({Key key, this.title}) : super(key: key);
  // title string
  final String title;
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

// State for the First Screen
class _FirstScreenState extends State<FirstScreen> {
  File _imageFile;
  Size _imageSize;
  dynamic _scanResults;

  // setup the face detector instance for FirebaseVision with options
  final FaceDetector _faceDetector = FirebaseVision.instance.faceDetector(
      FaceDetectorOptions(
          mode: FaceDetectorMode.fast,
          enableLandmarks: true,
          enableContours: true));

  // declare the screenshot controller to grab a screenshot of the screen when saving the image
  ScreenshotController screenshotController = ScreenshotController();

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

    if (imageFile != null) {
      _getImageSize(imageFile);
      _scanImage(imageFile);
    }

    setState(() {
      _imageFile = imageFile;
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
    results = await _faceDetector.processImage(visionImage);

    setState(() {
      _scanResults = results;
    });
  }

/* _buildResults method */
  CustomPaint _buildResults(Size imageSize, dynamic results) {
    print('_buildResults method called');
    CustomPainter painter;
    painter = FaceDetectorPainter(_imageSize, results);

    return CustomPaint(
      painter: painter,
    );
  }

/* _buildImage() method - build the image to display in body of the app */
  Widget _buildImage() {
    print('_buildImage method called');
    return Stack(children: <Widget>[
      Positioned.fill(
          child: Screenshot(
        controller: screenshotController,
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
      ))),
      Positioned(
          bottom: 25,
          width: MediaQuery.of(context).size.width,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  child: Text('Save Image'),
                  onPressed: () {},
                ),
                RaisedButton(
                  child: Text('Back'),
                  onPressed: () {
                    setState(() {
                      _imageFile = null;
                      _scanResults = null;
                    });
                  },
                )
              ]))
    ]);
  }

  // the build method to draw the entire screen
  @override
  Widget build(BuildContext context) {
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
                    Container(
                        padding: EdgeInsets.all(16),
                        color: Colors.blue,
                        constraints: BoxConstraints.expand(
                            width: MediaQuery.of(context).size.width,
                            height: 225),
                        child: Column(children: <Widget>[
                          Text('Detect Faces',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 32)),
                          Padding(
                            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                          ),
                          RaisedButton(
                              child: Text("Detect Faces from Gallery Image",
                                  style: TextStyle(fontSize: 20)),
                              onPressed: () {
                                _getAndScanImage(selectedFromCamera: false);
                              }),
                          RaisedButton(
                              child: Text("Detect Faces from Camera",
                                  style: TextStyle(fontSize: 20)),
                              onPressed: () {
                                _getAndScanImage(selectedFromCamera: true);
                              })
                        ]))
                  ]))
            : _buildImage(),
      ),
      onWillPop: _onWillPop,
    );
  }

  // clean up
  @override
  void dispose() {
    _faceDetector.close();
    super.dispose();
  }
}
