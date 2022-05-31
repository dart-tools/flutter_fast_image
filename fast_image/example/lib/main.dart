import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:fast_image/fast_image.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _imageSource;
  Image? image;
  Completer<ui.Image> completer = Completer<ui.Image>();
  @override
  void initState() {
    super.initState();
    resetImage();
  }

  @override
  Widget build(BuildContext context) {
    if (_imageSource != null) {
      completer = Completer<ui.Image>();
      image = Image.file(
        File(_imageSource!),
        key: UniqueKey(),
      );

      image!.image
          .resolve(const ImageConfiguration())
          .addListener(ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(info.image);
      }));
    }
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fast Image example app'),
        ),
        body: Column(
          children: [
            if (_imageSource != null) image!,
            FutureBuilder<ui.Image>(
              future: completer.future,
              builder:
                  (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
                if (snapshot.hasData) {
                  return Text(
                      'Image size: ${snapshot.data!.width}x${snapshot.data!.height}');
                } else {
                  return const Text('Loading...');
                }
              },
            ),
            ElevatedButton(
              onPressed: resetImage,
              child: const Text("Reset image"),
            ),
            ElevatedButton(
              onPressed: simpleResize2,
              child: const Text("Resize image to 1000x?"),
            ),
            ElevatedButton(
              onPressed: simpleResize,
              child: const Text("Resize image to 400x400"),
            ),
            ElevatedButton(
              onPressed: simpleResize3,
              child: const Text("Resize image to 4:3"),
            ),
            ElevatedButton(
              onPressed: pickAndResize,
              child: const Text("Pick image from gallery and resize to 4:3"),
            ),
          ],
        ),
      ),
    );
  }

  void resetImage() async {
    const img = AssetImage("assets/image.jpg");
    const config = ImageConfiguration();

    final dir = await path_provider.getTemporaryDirectory();
    AssetBundleImageKey key = await img.obtainKey(config);
    final ByteData data = await key.bundle.load(key.name);
    File file = File("${dir.absolute.path}/pre.jpg");
    file.writeAsBytesSync(data.buffer.asUint8List());

    _imageSource = file.path;

    setState(() {});
  }

  Future<void> simpleResize() async {
    final dir = await path_provider.getTemporaryDirectory();
    final targetPath = dir.absolute.path + "/post.jpg";
    _imageSource = targetPath;
    await FastImage.resizeImage("${dir.absolute.path}/pre.jpg", targetPath,
        width: 400, height: 400);
    setState(() {});
  }

  Future<void> simpleResize2() async {
    final dir = await path_provider.getTemporaryDirectory();
    final targetPath = dir.absolute.path + "/post2.jpg";
    _imageSource = targetPath;
    await FastImage.resizeImage("${dir.absolute.path}/pre.jpg", targetPath,
        width: 1000);
    setState(() {});
  }

  Future<void> simpleResize3() async {
    final dir = await path_provider.getTemporaryDirectory();
    final targetPath = dir.absolute.path + "/post3.jpg";
    _imageSource = targetPath;
    await FastImage.resizeImage("${dir.absolute.path}/pre.jpg", targetPath,
        width: 4000, height: 3000);
    setState(() {});
  }

  Future<void> pickAndResize() async {
    final ImagePicker _picker = ImagePicker();
    // Pick an image
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    final dir = await path_provider.getTemporaryDirectory();
    final targetPath = dir.absolute.path + "/post4.jpg";
    _imageSource = targetPath;
    await FastImage.resizeImage(image!.path, targetPath,
        width: 4000, height: 3000);

    setState(() {
      imageCache?.clear();
      imageCache?.clearLiveImages();
    });
  }
}
