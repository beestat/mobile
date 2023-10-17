import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

void main() {
  runApp(
    const MaterialApp(
      home: BeestatWidget(),
    )
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

    String platform = Platform.isAndroid
      ? 'android'
      : Platform.isIOS
        ? 'ios'
        : 'undefined';

    this.controller = WebViewController()
      ..loadRequest(Uri.parse('https://app.beestat.io?platform=$platform'))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            print(request.url);
            if (request.url.startsWith('https://app.beestat.io')) {
              return NavigationDecision.navigate;
            } else if (request.url.startsWith('data:')) {
              saveBase64StringToFile(request.url, 'beestat.png');
              return NavigationDecision.prevent;
            } else if (request.url.startsWith('mailto:')) {
              launchUrl(Uri.parse(request.url), mode: LaunchMode.externalNonBrowserApplication);
              return NavigationDecision.prevent;
            } 

            launchUrl(Uri.parse(request.url), mode: LaunchMode.externalApplication);
            return NavigationDecision.prevent;
          }
        )
      );
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
}

Future<void> saveBase64StringToFile(String base64String, String fileName) async {
  final Directory tempDir = await getTemporaryDirectory();
  final filePath = '${tempDir.path}/$fileName';

  base64String = base64String.substring(base64String.indexOf(',') + 1);
  Uint8List bytes = base64.decode(base64String);

  final File file = File(filePath);
  await file.writeAsBytes(bytes);

  OpenFile.open(filePath);
}