import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:image_picker/image_picker.dart';
import 'package:keep_screen_on/keep_screen_on.dart';

import 'package:cooking/view_media.dart';
import 'package:cooking/view_website.dart';
import 'package:cooking/choose_website.dart';
import 'package:cooking/core/cache.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final List<String> acceptedFileTypes = ['.pdf', '.jpg', '.jpeg', '.png'];
  List<dynamic> recentFiles = [];

  void _enableFullscreen() {
    KeepScreenOn.turnOn();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('doubletap to exit view'),
        duration: Duration(seconds: 5),
      ),
    );
  }

  void _disableFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    KeepScreenOn.turnOff();
  }

  Future<void> _addRecentFile(String filename, String filepath) async {
    var recentFilesCache = Cache.of('recentFiles.json');
    List<dynamic> localRecentFiles = [];
    if (await recentFilesCache.exists) {
      String data = await recentFilesCache.read();
      localRecentFiles = jsonDecode(data);
      print(filepath);
      print(localRecentFiles);
      localRecentFiles.removeWhere((element) => element[0] == filename);
      if (localRecentFiles.length > 4) {
        localRecentFiles.removeLast();
      }
    }
    localRecentFiles.insert(0, [filename, filepath]);
    recentFilesCache.write(jsonEncode(localRecentFiles));
  }

  Future<void> _getRecentFiles() async {
    var recentFilesCache = Cache.of('recentFiles.json');
    if (await recentFilesCache.exists) {
      String data = await recentFilesCache.read();
      recentFiles = jsonDecode(data);
    }
  }

  Future<void> _openLastFile(String filename, String path) async {
    if (path.startsWith('http')) {
      _openWebsite(path);
    } else {
      _openFile(filename, path);
    }
  }

  Future<void> _openFile(String filename, String filepath) async {
    _enableFullscreen();
    _addRecentFile(filename, filepath);
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewMedia(
            filePath: filepath,
          ),
        )).then((value) {
      _disableFullscreen();
      setState(() {});
    });
  }

  Future<void> _openWebsite(String url) async {
    try {
      Uri.parse(url);
      _enableFullscreen();
      _addRecentFile(
          RegExp(r'www\.[^/]*').firstMatch(url)!.group(0).toString(), url);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewWebsite(url: url),
          )).then((value) {
        _disableFullscreen();
        setState(() {});
      });
    } on Exception catch (_) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error! Url not valid.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _pickFile() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickMedia();
    if (pickedFile != null) {
      if (acceptedFileTypes.any(pickedFile.path.endsWith)) {
        _openFile(pickedFile.name, pickedFile.path);
      } else {
        ScaffoldMessenger.of(_getContext()).showSnackBar(
          const SnackBar(
            content: Text('Error! Wrong filetype.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _chooseWebsite() async {
    final String url = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ChooseWebsite(),
        ));
    if (url != '') {
      _openWebsite(url);
    }
  }

  BuildContext _getContext() {
    return context;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: FutureBuilder(
            future: _getRecentFiles(),
            builder: (context, snapshot) => Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/home_background.jpg"),
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.cover,
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 50),
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 0),
                          child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(180),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20))),
                              child: const Column(children: [
                                Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 100),
                                    child: Text(
                                      'View your Recipes',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold),
                                    )),
                                Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    child: Text(
                                      'without the screen turning off',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    )),
                              ]))),
                      GridView.count(
                          shrinkWrap: true,
                          childAspectRatio: 8 / 9,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 1,
                          mainAxisSpacing: 1,
                          children: [
                            Padding(
                                padding: const EdgeInsets.only(
                                    right: 5, left: 10, top: 0, bottom: 10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withAlpha(180),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20)),
                                  ),
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 10),
                                      child: Column(children: [
                                        const Text(
                                          'PDF and Image',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                        Expanded(
                                            child: Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: ElevatedButton(
                                                  onPressed: _pickFile,
                                                  style: ElevatedButton.styleFrom(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                      minimumSize: const Size(
                                                          double.infinity, 90)),
                                                  child:
                                                      const Text('select file'),
                                                )))
                                      ])),
                                )),
                            Padding(
                                padding: const EdgeInsets.only(
                                    right: 10, left: 5, top: 0, bottom: 10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withAlpha(180),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20)),
                                  ),
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 10),
                                      child: Column(children: [
                                        const Text(
                                          'Website',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                        Expanded(
                                            child: Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: ElevatedButton(
                                                    onPressed: _chooseWebsite,
                                                    style: ElevatedButton.styleFrom(
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10)),
                                                        minimumSize: const Size(
                                                            double.infinity,
                                                            90)),
                                                    child: const Text(
                                                        'open Website'))))
                                      ])),
                                ))
                          ]),
                      Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(180),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20))),
                              child: Column(children: [
                                const Padding(
                                    padding: EdgeInsets.only(top: 10),
                                    child: Text(
                                      'recent used files',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    )),
                                ListView.builder(
                                  itemCount: recentFiles.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) => ListTile(
                                      title: Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .buttonTheme
                                                .colorScheme
                                                ?.background
                                                .withAlpha(150),
                                            boxShadow: [
                                              BoxShadow(
                                                blurRadius: 5,
                                                spreadRadius: 0,
                                                blurStyle: BlurStyle.outer,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ],
                                            border: Border.fromBorderSide(
                                                BorderSide(
                                                    width: 1,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary)),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: ListTile(
                                            title: Text(
                                              recentFiles[index][0],
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                            onTap: () => _openLastFile(
                                                recentFiles[index][0],
                                                recentFiles[index][1]),
                                          ))),
                                ),
                                Visibility(
                                    visible: recentFiles.isEmpty,
                                    child: const Text(
                                      'no recently used files',
                                      style: TextStyle(fontSize: 16),
                                    ))
                              ])))
                    ],
                  ),
                ))));
  }
}
