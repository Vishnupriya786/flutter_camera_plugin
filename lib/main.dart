import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
      home: MyHomePage()
  )
  );
}

class MyHomePage extends StatefulWidget {

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  CameraController? _controller;
  Future<void>? _initController;
  var isCameraReady = false;
  XFile? humanImage;

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(firstCamera, ResolutionPreset.high);
    _initController = _controller!.initialize();
    if (!mounted)
      return;
    setState(() {
      isCameraReady = true;
    });
  }

  CaptureImage(BuildContext context) {
    _controller!.takePicture().then((image) {
      setState(() {
        print("image taken");
        humanImage = image;
      });
      if (mounted)
        Navigator.push(context, MaterialPageRoute(builder: (context) => OutputPage(humanImageDetail: humanImage ,key: null,)));
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initCamera();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    if (state == AppLifecycleState.resumed)
      _initController = _controller != null ? _controller?.initialize() : null;
    if (!mounted)
      return;
    setState(() {
      isCameraReady = true;
    });
  }

  Widget cameraWidget(context) {
    var camera = _controller?.value;
    final size = MediaQuery
        .of(context)
        .size;
    var scale = size.aspectRatio * camera!.aspectRatio;
    if (scale < 1) scale = 1 / scale;
    return Transform.scale(scale: scale, child:  Center(child: CameraPreview(_controller!),),);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _initController,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(children: [
              cameraWidget(context),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  color: Color(0XAA333639),
                  child: Row(

                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      IconButton(
                          iconSize: 40,
                          icon: Icon(Icons.camera_alt, color: Colors.white,),
                          onPressed: () => CaptureImage(context),
                      ),
                    ],
                  ),
                ),
              )
            ],);
          }
          else
            return Center(child: CircularProgressIndicator(),);
        },
      ),
    );
  }
}

class OutputPage extends StatelessWidget{

  final XFile? humanImageDetail;

  OutputPage({required Key? key, required this.humanImageDetail,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(humanImageDetail!.name),),
      body:Column(
          children: [
      Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Image.file(File(humanImageDetail!.path),height: 480,width: 440,fit: BoxFit.fill, alignment: Alignment.center)),
      Padding(padding: const EdgeInsets.all(5.0),
      child: MaterialButton(
        color: Color(0xff47a1ad),
        child: const Text("Done",
        style: TextStyle(
        color: Colors.white70, fontWeight: FontWeight.bold
    ),
    ),
    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DisplayText())))
      )]));
  }
}

class DisplayText extends StatelessWidget{

  Future<String> fetchTryOnImageFromAPI() async {
    print("API gonna call");
    var request = http.MultipartRequest('GET', Uri.parse('http://192.168.225.92:8080/'));
    var response = await request.send();
    var responseData = await response.stream.toBytes();

    var result = String.fromCharCodes(responseData);
    print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@2");
    print(result);
    return result;

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("display text from API"),
        centerTitle: true,
      ),

      body: FutureBuilder<String>(
          future: fetchTryOnImageFromAPI(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Center(child:
              Text(snapshot.data.toString(),style: TextStyle(fontSize: 20),),
              );
            }
            return Center(child: CircularProgressIndicator());
          }
      ),
    );
  }
}



