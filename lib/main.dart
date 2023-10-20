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

    /**
     * The beestat bluegray_light color. This is the background color for most
     * things and is applied to the status and navigation bar backgrounds.
     */
    final color = Color.fromRGBO(55, 71, 79, 1);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: color,
        systemNavigationBarColor: color,
        systemNavigationBarDividerColor: color
      )
    );

    /**
     * Determine the current platform, used to add in a query parameter.
     */
    String platform = Platform.isAndroid
      ? 'android'
      : Platform.isIOS
        ? 'ios'
        : 'undefined';

    this.controller = WebViewController()
      ..loadRequest(Uri.parse('https://app.beestat.io/welcome/?platform=$platform'))
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            print(request.url);
            if (request.url.startsWith('data:')) {
              /**
               * This forces chart image downloads (data URLs) to save the file
               * and open it.
               */
              saveBase64StringToFile(request.url, 'beestat.png');
              return NavigationDecision.prevent;
            } else if (request.url.startsWith('mailto:')) {
              /**
               * This ensures the default mail app is launched when opening any
               * mailto links (ex: contact footer).
               */
              launchUrl(Uri(
                scheme: 'mailto',
                path: request.url.replaceFirst('mailto:', '')
              ));
              return NavigationDecision.prevent;
            } else if (
              request.url.startsWith('https://app.beestat.io/api/?resource=ecobee&method=authorize') ||
              request.url.startsWith('https://api.ecobee.com') || // https://api.ecobee.com/authorize...
              request.url.startsWith('https://auth.ecobee.com') || // https://auth.ecobee.com/authorize..., https://auth.ecobee.com/u/login...
              request.url.startsWith('https://app.beestat.io/api/ecobee_initialize.php') ||
              request.url.startsWith('https://app.beestat.io/api/?resource=ecobee&method=initialize') ||
              request.url.startsWith('https://app.beestat.io/?platform=')
            ) {
              /**
               * These are mostly special navigation steps that happen when
               * authorizing beestat. These are all caught manually and allowed
               * to navigate in the current WebView.
               */
              return NavigationDecision.navigate;
            } else if (
              request.url == 'https://demo.beestat.io/'
            ) {
              /**
               * Allow demo logins to navigate in the WebView for app store
               * reviews.
               */
              this.controller.loadRequest(Uri.parse('https://demo.beestat.io/?platform=$platform'));
              return NavigationDecision.prevent;
            } else if (
              request.url == 'https://app.beestat.io/'
            ) {
              /**
               * The original platform query paramater is lost after ecobee
               * sends the authorization code back to me. The final navigation
               * request redirects the browser to the main beestat app. This
               * catches that, and puts the platform back on.
               */
              this.controller.loadRequest(Uri.parse('https://app.beestat.io/?platform=$platform'));
              return NavigationDecision.prevent;
            } else if (request.url.startsWith('https://app.beestat.io/?platform=')) {
              /**
               * Generic catch-all to ensure navigating to "self" is allowed.
               */
              return NavigationDecision.navigate;
            }

            // If no special case, attempt opening the URL in the browser ex: Notion, Amazon, etc.
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
