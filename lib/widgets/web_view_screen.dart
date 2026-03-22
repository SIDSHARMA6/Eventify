import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'gradient_app_bar.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String titleEn;
  final String titleJa;
  final bool isJa;

  const WebViewScreen({
    super.key,
    required this.url,
    required this.titleEn,
    required this.titleJa,
    required this.isJa,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) => setState(() => _loading = false),
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: Text(
          widget.isJa ? widget.titleJa : widget.titleEn,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
