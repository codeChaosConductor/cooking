import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ViewWebsite extends StatefulWidget {
  final String url;

  const ViewWebsite({super.key, required this.url});

  @override
  State<ViewWebsite> createState() => _ViewWebsiteState();
}

class _ViewWebsiteState extends State<ViewWebsite> {
  late InAppWebViewController controller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onDoubleTap: () {
          Navigator.pop(context);
          controller.webStorage.sessionStorage.clear();
        },
        child: InAppWebView(
          onWebViewCreated: (controller) {
            this.controller = controller;
          },
          initialSettings: InAppWebViewSettings(
            forceDark: ForceDark.ON,
            algorithmicDarkeningAllowed: true,
          ),
          initialUrlRequest: URLRequest(url: WebUri(widget.url)),
        ),
      ),
    );
  }
}
