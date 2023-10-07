import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(
    const MaterialApp(
      home: BeestatWidget(),
    ),
  );
}

class BeestatWidget extends StatefulWidget {
  const BeestatWidget({super.key});

  @override
  State<BeestatWidget> createState() => BeestatWidgetState();
}

class BeestatWidgetState extends State<BeestatWidget> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..loadRequest(Uri.parse('https://app.beestat.io'))
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(
        controller: controller
      )
    );
  }
}
