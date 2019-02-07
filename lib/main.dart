import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter WebView Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (_) => new WebView()
      },
    );
  }
}

class WebView extends StatefulWidget {

  @override
  _WebViewState createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  final flutterWebviewPlugin = new FlutterWebviewPlugin();

  @override
  initState() {
    super.initState();
    flutterWebviewPlugin.onUrlChanged.listen((String url) async {
      if (url.contains('CALL_PHONE')) {
        flutterWebviewPlugin.stopLoading();
        _launchURL(url);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: 'http://10.12.80.118:8081/',
      withLocalStorage: true,
      allowFileURLs: true
    );
  }

  _launchURL(String url) async {
    var phone = _parsePhone(url);
    if (phone.isNotEmpty) {
      var telUrl = 'tel:$phone';
      print('telUrl $telUrl');
      if (await canLaunch(telUrl)) {
        await launch(telUrl);
      } else {
        throw 'Could not launch $telUrl';
      }
    }
  }

  String _parsePhone(url) {
    RegExp exp = new RegExp(r"CALL_PHONE=(.*)"); // TODO fix regexp
    var matches = exp.allMatches(url);
    var match = matches.elementAt(0);
    return match.group(1);
  }

}
