// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MaterialApp(home: WebViewExample()));

class WebViewExample extends StatefulWidget {
  @override
  _WebViewState createState() => _WebViewState();
}

class _WebViewState extends State<WebViewExample> {
  final Completer<WebViewController> _controller =
  Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We're using a Builder here so we have a context that is below the Scaffold
      // to allow calling Scaffold.of(context) so we can show a snackbar.
      body: new Container(
          margin: MediaQuery
              .of(context)
              .padding,
          child: new WillPopScope(
            onWillPop: _onWillPop,
            child: Builder(builder: (BuildContext context) {
              return WebView(
                initialUrl: 'http://192.168.1.5:8080',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller.complete(webViewController);
                },
                javascriptChannels: <JavascriptChannel>[
                  _phoneCallJavascriptChannel(context),
                  _openGalleryJavascriptChannel(context, _controller)
                ].toSet(),
              );
            }),)
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final WebViewController controller = await _controllerFuture();

    if (await controller.canGoBack()) {
      controller.goBack();
      return Future.value(false);
    } else {
      Navigator.pop(context, true);
      return Future.value(true);
    }
  }

  Future<dynamic> _controllerFuture() async {
    return await _controller.future;
  }

  JavascriptChannel _openGalleryJavascriptChannel(BuildContext context, controller) {
    return JavascriptChannel(
        name: 'flutterOpenGalleryApp',
        onMessageReceived: (JavascriptMessage message) {

        });
  }

  JavascriptChannel _phoneCallJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'flutterOpenPhoneCallApp',
        onMessageReceived: (JavascriptMessage message) {
          _launchURL(message.message);
        });
  }

  _launchURL(String phone) async {
    if (phone.isNotEmpty) {
      var telUrl = 'tel:$phone';
      if (await canLaunch(telUrl)) {
        await launch(telUrl);
      } else {
        throw 'Could not launch $telUrl';
      }
    }
  }
}
