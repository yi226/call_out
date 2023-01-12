import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdatePage extends StatefulWidget {
  const UpdatePage({Key? key}) : super(key: key);

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  final Uri _sourceUrl = Uri.parse('https://github.com/yi226/CallOut');

  Future<void> _launchUrl() async {
    if (!await launchUrl(_sourceUrl)) {
      throw 'Could not launch $_sourceUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于'),
        actions: [
          IconButton(
              onPressed: _launchUrl, icon: const Icon(Icons.open_in_browser))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text('当前版本: 2.0.8'),
          ],
        ),
      ),
    );
  }
}
