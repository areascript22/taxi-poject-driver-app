import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermnsAndConditionsPage extends StatefulWidget {
  const TermnsAndConditionsPage({super.key});
  @override
  State<TermnsAndConditionsPage> createState() => _TermnsAndConditionsPageState();
}

class _TermnsAndConditionsPageState extends State<TermnsAndConditionsPage> {

  late final WebViewController _controller;
  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(
        'https://docs.google.com/document/d/1LCK1231eMyHOUhclO-nG0u-dnKgDyKscfLU3V_fOcXY/edit?usp=sharing',
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
              'Términos y condiciones',
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
