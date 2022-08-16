import 'dart:async';
import 'dart:io';

import 'package:eTrade/components/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  WebViewScreen({required this.link});
  String link;
  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  Completer<WebViewController> _controller = Completer<WebViewController>();
  double webProgress = 0;
  @override
  void initState() {
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("About Us"),
          backgroundColor: eTradeMainColor,
        ),
        body: Column(
          children: [
            webProgress < 1
                ? SizedBox(
                    height: 3,
                    child: LinearProgressIndicator(
                      color: eTradeMainColor,
                      value: webProgress,
                      backgroundColor: Colors.white,
                    ),
                  )
                : SizedBox(),
            Expanded(
              child: WebView(
                initialUrl: widget.link,
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController controller) {
                  _controller.complete(controller);
                },
                onProgress: (int progress) {
                  this.webProgress = progress / 100;
                  print('WebView is loading (progress : $progress%)');
                },
              ),
            ),
          ],
        ));
  }
}
