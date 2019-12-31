import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'dart:ui';

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
      home: MyHomePage(title: 'Face Detection Demo'),
    );
  }
}

// First Screen extends the StatefulWidget class
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  // title string
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

// State for the First Screen
class _MyHomePageState extends State<MyHomePage> {
  File _imageFile;
  Size _imageSize;

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
      // need to do something with the selected image file
    }

    setState(() {
      _imageFile = imageFile;
    });
  }

  // the build method to draw the entire screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
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
            
      );
  }
}
