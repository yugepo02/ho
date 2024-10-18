import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fleather/fleather.dart';
import 'package:url_launcher/url_launcher.dart'; // 追加
import 'dart:convert';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  EditorScreenState createState() => EditorScreenState();
}

class EditorScreenState extends State<EditorScreen> {
  FleatherController? _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    // フォーカスノードを作成
    _focusNode = FocusNode();
    // ドキュメントをロード
    _loadDocument().then((document) {
      setState(() {
        // コントローラを作成
        _controller = FleatherController(document: document);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveDocument(context),
          ),
        ],
      ),
      // コントローラがnullの場合はCircularProgressIndicatorを表示
      body: _controller == null
          ? const Center(child: CircularProgressIndicator())
          // コントローラがnullでない場合はFleatherEditorを表示
          : Column(
              children: [
                // ツールバーを表示
                if (!Platform.isAndroid && !Platform.isIOS)
                  FleatherToolbar.basic(controller: _controller!),
                // ツールバーを表示
                if (Platform.isAndroid || Platform.isIOS)
                  FleatherToolbar.basic(controller: _controller!),
                const Divider(),
                Expanded(
                  // FleatherEditorを表示
                  child: FleatherEditor(
                    padding: const EdgeInsets.all(16),
                    controller: _controller!,
                    focusNode: _focusNode,
                  ),
                ),
                // リンクの追加
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: InkWell(
                    onTap: _launchURL, // タップ時にURLを開く
                    child: const Text(
                      'Visit Flutter Website',
                      style: TextStyle(
                        color: Colors.blue, // リンクっぽい色
                        decoration: TextDecoration.underline, // 下線
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // ロード
  Future<ParchmentDocument> _loadDocument() async {
    // ファイル名を決める
    final file = File(Directory.systemTemp.path + "/quick_start.json");

    // ファイルがあるかどうかを確認
    if (await file.exists()) {
      final contents = await file.readAsString();
      return ParchmentDocument.fromJson(jsonDecode(contents));
    }
    final Delta delta = Delta()..insert("Fleather Quick Start\n");

    // ドキュメントを作成
    return ParchmentDocument.fromDelta(delta);
  }

  void _saveDocument(BuildContext context) {
    // contentsにドキュメントデータを入れる（jsonEncodeでエンコード）
    final contents = jsonEncode(_controller!.document);

    // ファイル名をquick_start.jsonにする
    final file = File('${Directory.systemTemp.path}/quick_start.json');

    // Savedの文字を表示
    file.writeAsString(contents).then(
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved.')),
        );
      },
    );
  }

  // リンクを開くための関数
  void _launchURL() async {
    const url = 'https://flutter.dev';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
