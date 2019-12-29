import 'package:flutter/material.dart';

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
                                // add code to handle detecting faces from the Gallery here
                              }),
                          RaisedButton(
                              child: Text("Detect Faces from Camera",
                                  style: TextStyle(fontSize: 20)),
                              onPressed: () {
                                // add code to handle detecting faces from the Camera here
                              })
                        ]))
                  ]))            
      );
  }
}
