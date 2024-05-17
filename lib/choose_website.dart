import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ChooseWebsite extends StatefulWidget {
  const ChooseWebsite({super.key});

  @override
  State<ChooseWebsite> createState() => _ChooseWebsiteState();
}

class _ChooseWebsiteState extends State<ChooseWebsite> {
  late InAppWebViewController webViewController;
  TextEditingController searchBar = TextEditingController();
  bool isNewURL = false;
  String newURL = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        final navigator = Navigator.of(context);
        if (await webViewController.canGoBack()) {
          webViewController.goBack();
          return;
        } else {
          webViewController.webStorage.sessionStorage.clear();
          navigator.pop('');
          return;
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.black45,
            ),
            width: double.infinity,
            alignment: Alignment.center,
            height: 30,
            child: TextField(
                textAlignVertical: TextAlignVertical.top,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(bottom: 10),
                ),
                onChanged: (value) {
                  isNewURL = true;
                  newURL = value;
                },
                controller: searchBar,
                style: const TextStyle(fontSize: 15),
                autocorrect: false,
                onSubmitted: (value) {
                  webViewController.loadUrl(
                    urlRequest: URLRequest(url: WebUri(value)),
                  );
                },
            )
          ),
          actions: [
            IconButton(
              onPressed: () {
                if (isNewURL) {
                  webViewController.loadUrl(
                    urlRequest: URLRequest(url: WebUri(newURL)),
                  );
                  isNewURL = false;
                } else {
                  Navigator.pop(context, searchBar.text);
                }
              },
              icon: const Icon(
                Icons.check,
                size: 30,
              ),
            ),
          ],
        ),
        body: InAppWebView(
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
          initialSettings: InAppWebViewSettings(
            forceDark: ForceDark.ON,
            algorithmicDarkeningAllowed: true,
          ),
          initialUrlRequest: URLRequest(url: WebUri('https://www.google.com')),
          onLoadStart: (controller, url) {
            setState(() {
              searchBar.text = url.toString();
            });
          },
        ),
      ),
    );
  }
}
