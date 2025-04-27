import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});
  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {

  late final WebViewController _controller;
  @override
  void initState() {

    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(
        'https://docs.google.com/document/d/1bRDn5foJxjpLC39VXlIayc-JgMQfyoc_47q5KQ8OvSo/edit?usp=sharing',
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context)
                    .colorScheme
                    .inversePrimary
                    .withValues(alpha: 0.2),
                blurRadius: 1,
                offset: const Offset(0, 5), // creates the soft blur effect
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Políticas de privacidad',
              style:
              TextStyle(fontWeight: FontWeight.bold, color: Colors.purple),
              maxLines: 2,
            ),
            iconTheme: const IconThemeData(color: Colors.purple),
          ),
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
