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
  
  String foo = '';

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
            
            showAlertDialog(this.foo, context);
            if (request.url.startsWith('data:')) {
              // Download data urls from chart downloads
              saveBase64StringToFile(request.url, 'beestat.png');
              return NavigationDecision.prevent;
            } else if (request.url.startsWith('mailto:')) {
              final Uri emailLaunchUri = Uri(
                scheme: 'mailto',
                path: request.url.replaceFirst('mailto:', '')
              );
              launchUrl(emailLaunchUri);              
              return NavigationDecision.prevent;
            } else if (
              request.url.startsWith('https://app.beestat.io/api/?resource=ecobee&method=authorize') ||
              request.url.startsWith('https://app.beestat.io/api/?resource=ecobee&method=initialize') ||
              request.url.startsWith('https://app.beestat.io/api/ecobee_initialize.php') ||
              request.url.startsWith('https://api.ecobee.com') ||
              request.url.startsWith('https://auth.ecobee.com') ||
              request.url == 'https://app.beestat.io/?platform='
            ) {
              this.foo += '|A:' + request.url;
              // Navigate to these special URLs directly in the WebView
              return NavigationDecision.navigate;
            }

            this.foo += '|B:' + request.url;

            return NavigationDecision.navigate;
            // If no special case, attempt opening the URL in the browser ex: Notion, Amazon, etc.
            // launchUrl(Uri.parse(request.url), mode: LaunchMode.externalApplication);
            // return NavigationDecision.prevent;
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

showAlertDialog(String text, BuildContext context) {

  // set up the button
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () { },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Debug"),
    content: Text(text),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
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