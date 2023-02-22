import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_xupdate/flutter_xupdate.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdatePage extends StatefulWidget {
  const UpdatePage({Key? key}) : super(key: key);

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  var url =
      'https://github.com/yi226/Config/releases/download/call_out/update.json';
  var _message = '';
  final Uri _sourceUrl = Uri.parse('https://github.com/yi226/CallOut');
  bool _loading = false;

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
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('当前版本: 2.0.9'),
                const SizedBox(height: 20),
                if (Platform.isAndroid)
                  ElevatedButton(
                    child: const Text('在线更新'),
                    onPressed: () {
                      setState(() {
                        _loading = true;
                      });
                      FlutterXUpdate.checkUpdate(
                        url: url,
                        themeColor: '#FFD6E5F0',
                        isCustomParse: true,
                      );
                    },
                  ),
                const SizedBox(height: 20),
                if (!Platform.isAndroid) const Text('在线更新功能只支持Android'),
                const SizedBox(height: 20),
                const SelectableText("https://yi226.github.io/call"),
              ],
            ),
          ),
          if (_loading)
            Container(
              color: Colors.grey.withAlpha(100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const <Widget>[
                  Center(
                    child: SizedBox(
                      height: 60,
                      width: 60,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    initXUpdate();
  }

  //初始化XUpdate
  void initXUpdate() {
    if (Platform.isAndroid) {
      FlutterXUpdate.init(
        //是否输出日志
        debug: true,
        //是否使用post请求
        isPost: false,
        //post请求是否是上传json
        isPostJson: false,
        //请求响应超时时间
        timeout: 4000,
        //是否开启自动模式
        isWifiOnly: false,
        //是否开启自动模式
        isAutoMode: false,
        //需要设置的公共参数
        supportSilentInstall: false,
        //在下载过程中，如果点击了取消的话，是否弹出切换下载方式的重试提示弹窗
        enableRetry: false,
      ).then((value) {
        if (kDebugMode) {
          print("初始化成功: $value");
        }
      }).catchError((error) {
        if (kDebugMode) {
          print(error);
        }
      });

      FlutterXUpdate.setCustomParseHandler(onUpdateParse: (json) async {
        setState(() {
          _loading = false;
        });
        final result = await FlutterXUpdate.defaultUpdateParser(json!);
        return result!;
      });

      FlutterXUpdate.setErrorHandler(
          onUpdateError: (Map<String, dynamic>? message) async {
        _message = message!["message"];
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text(''),
            content: Text(_message),
            actions: <Widget>[
              TextButton(
                child: const Text("确定"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      });
    } else {
      debugPrint("ios暂不支持XUpdate更新");
    }
  }
}
