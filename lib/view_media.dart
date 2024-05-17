import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:photo_view/photo_view.dart';

class ViewMedia extends StatefulWidget {
  final String filePath;

  const ViewMedia({super.key, required this.filePath});

  @override
  State<ViewMedia> createState() => _ViewMediaState();
}

class _ViewMediaState extends State<ViewMedia> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child: GestureDetector(
                onDoubleTap: () {
                  Navigator.pop(context);
                },
                child: widget.filePath.endsWith('.pdf')
                    ? PDFView(
                        filePath: widget.filePath,
                        fitEachPage: true,
                      )
                    : PhotoView(
                        imageProvider: FileImage(File(widget.filePath)),
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered * 2,
                        initialScale: PhotoViewComputedScale.contained,
                        backgroundDecoration: BoxDecoration(
                          color: Colors.black,
                        ),
                      ))));
  }
}
