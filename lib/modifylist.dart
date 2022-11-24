import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ModifyListPage extends StatefulWidget {
  final List<String> data;
  const ModifyListPage({required this.data, Key? key}) : super(key: key);

  @override
  State<ModifyListPage> createState() => _ModifyListPageState();
}

class _ModifyListPageState extends State<ModifyListPage> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('修改信息'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                widget.data.add('');
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.question_mark),
            onPressed: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      title: const Text('提示'),
                      content: const Text("长按拖拽进行换位\n双击更改名称\n滑动删除"),
                      actions: <Widget>[
                        TextButton(
                          child: const Text("确定"),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    )),
          )
        ],
      ),
      body: ReorderableListView(
        onReorder: _handleReorder,
        proxyDecorator: (Widget child, int index, Animation<double> animation) {
          return child;
        },
        children: [
          for (var i = 0; i < widget.data.length; i++)
            Dismissible(
              key: UniqueKey(),
              onDismissed: (direction) {
                setState(() {
                  widget.data.removeAt(i);
                });
              },
              background: Container(
                alignment: const Alignment(-0.9, 0.0),
                child: const Icon(Icons.close, color: Colors.red),
              ),
              secondaryBackground: Container(
                alignment: const Alignment(0.9, 0.0),
                child: const Icon(Icons.block, color: Colors.green),
              ),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  return true;
                } else {
                  return false;
                }
              },
              child: GestureDetector(
                onDoubleTap: () {
                  _nameController.text = widget.data[i];
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: const Text('填写姓名'),
                            content: TextField(
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      _nameController.clear();
                                    }),
                                border: const OutlineInputBorder(
                                  gapPadding: 0,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(4)),
                                  borderSide: BorderSide(
                                    width: 1,
                                    style: BorderStyle.none,
                                  ),
                                ),
                                hintText: '请输入姓名',
                              ),
                              controller: _nameController,
                              autofocus: true,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r"[0-9,a-z,A-Z,\u4e00-\u9fa5]"))
                              ],
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text("确定"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  setState(() {
                                    widget.data[i] = _nameController.text;
                                  });
                                },
                              ),
                            ],
                          ));
                },
                child: Card(
                  child: Container(
                    // width: double.infinity,
                    height: 50,
                    alignment: Alignment.center,
                    child: Text(
                      widget.data[i],
                      style: const TextStyle(fontSize: 20),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pop(context, widget.data.join('\n'));
          },
          tooltip: '确定',
          backgroundColor: Colors.blue,
          child: const Icon(Icons.check)),
    );
  }

  void _handleReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    setState(() {
      final element = widget.data.removeAt(oldIndex);
      widget.data.insert(newIndex, element);
    });
  }
}
