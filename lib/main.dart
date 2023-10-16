import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    // bluegray_light
    final color = Color.fromRGBO(55, 71, 79, 1);

    // Set the top status bar color
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: color,
        systemNavigationBarColor: color,
        systemNavigationBarDividerColor: color
      )
    );
    
    this.controller = WebViewController()
      ..loadRequest(Uri.parse('https://app.beestat.io'))
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(55, 71, 79, 1),
      body: SafeArea(
        child: WebViewWidget(
          controller: controller
        )
      )
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return SafeArea(
  //     child: Scaffold(
  //       backgroundColor: Color.fromRGBO(55, 71, 79, 1),
  //       body: WebViewWidget(
  //         controller: controller
  //       )
  //     )
  //   );
  // }
}
