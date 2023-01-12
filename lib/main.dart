import 'update/view.dart' if (dart.library.html) 'update/view_web.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'unselect.dart';
import 'namelist.dart';
import 'searchwidget.dart';
import 'modifylist.dart';

void main() {
  runApp(const CheckHome());
}

class CheckHome extends StatefulWidget {
  const CheckHome({Key? key}) : super(key: key);

  @override
  State<CheckHome> createState() => _CheckHomeState();
}

class _CheckHomeState extends State<CheckHome> {
  List<UserInfo> userMapList = <UserInfo>[];
  List<UserInfo> unselectUser = <UserInfo>[];
  List<UserInfo> searchUser = <UserInfo>[];
  List<String> saved = <String>[];
  List<String> edittingList = <String>[];

  var nameString = '';
  var nameList = [];
  var firstOpen = false;
  int total = 0;
  String barText = '点名器';
  var focus = FocusNode();
  ThemeMode themeMode = ThemeMode.light;
  bool autoSave = false;

  @override
  void dispose() {
    focus.dispose();
    super.dispose();
  }

  _CheckHomeState() {
    _get('firstOpen').then((value) {
      if (value == 'f') {
        _get("Dark").then((value) {
          if (value != null && value == 'dark') {
            themeMode = ThemeMode.dark;
            setState(() {});
          }
        });
        _get("saved").then((value) {
          if (value != null && value != '') {
            String saveNames = value;
            var saveNamesList = saveNames.split('\n');
            _get(saveNamesList[0]).then(((value) {
              setState(() {
                barText = saveNamesList[0];
                saved = saveNames.split('\n');
                if (value != null) {
                  nameString = value;
                  nameList = nameString.split('\n');
                } else {
                  nameList = ['学生1', '学生2'];
                }
                addUser();
              });
            }));
          } else {
            setState(() {
              barText = '示例';
              nameList = ['学生1', '学生2'];
              addUser();
            });
          }
        });
      } else {
        firstOpen = true;
        setState(() {});
      }
    });
  }

  addUser() {
    userMapList.clear();
    unselectUser.clear();
    searchUser.clear();
    total = nameList.length;
    for (var i = 0; i < total; i++) {
      userMapList.add(UserInfo(name: nameList[i], id: i));
      unselectUser.add(userMapList[i]);
    }
    searchUser.addAll(userMapList);
  }

  Future<String?> _get(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userName = prefs.getString(key);
    return userName;
  }

  Future _save(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  search(value) {
    searchUser.clear();
    setState(() {
      if (value == '') {
        searchUser.addAll(userMapList);
      } else if (value != null) {
        for (var i = 0; i < total; i++) {
          if (userMapList[i].name.contains(value)) {
            searchUser.add(userMapList[i]);
          }
        }
      }
    });
  }

  saveList(String saveString) {
    var saveSringList = saveString.split('+');
    String saveName = saveSringList[0];
    String saveValue = saveSringList[1];

    _save(saveName, saveValue);
    if (!saved.contains(saveName)) {
      saved.add(saveName);
      _save("saved", saved.join('\n'));
    }

    setState(() {
      search(null);
      barText = saveName;
      nameString = saveValue;
      nameList = saveValue.split('\n');
      addUser();
    });
  }

  changeList(String saveName) {
    _get(saveName).then((value) {
      if (value != null) {
        setState(() {
          search(null);
          nameString = value;
          nameList = nameString.split('\n');
          addUser();
        });
      }
    });
  }

  deleteList(String removeName) {
    search('');
    saved.remove(removeName);
    _save("saved", saved.join('\n'));
    _save(removeName, "");
    setState(() {
      if (removeName == barText) {
        if (saved.isNotEmpty) {
          _get(saved[0]).then((value) {
            setState(() {
              barText = saved[0];
              if (value != null) {
                nameString = value;
                nameList = nameString.split('\n');
              } else {
                nameList = ['学生1', '学生2'];
              }
              addUser();
            });
          });
        } else {
          setState(() {
            barText = '示例';
            nameList = ['学生1', '学生2'];
            addUser();
          });
        }
      }
    });
  }

  Future<bool?> _showConfirmDialog(String text, BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('提示'),
            content: Text(text),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('确定'),
              ),
            ],
          );
        });
  }

  Widget _firstOpenWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("初始设置"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '欢迎使用本软件',
              style: TextStyle(fontSize: 20, color: Colors.blue),
            ),
            Container(
              height: 50,
            ),
            ElevatedButton(
              child: const Text('初始化人员名单'),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: ((context) => GetNameList(
                              onEditingComplete: saveList,
                            ))))
                    .then((value) {
                  if (value != null) {
                    setState(() {
                      firstOpen = false;
                    });
                    _save('firstOpen', 'f');
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _leftDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Row(
            children: const [
              Expanded(
                child: DrawerHeader(
                  child: Text(
                    '设置',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
          InkWell(
            child: const ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.home),
              ),
              title: Text('学委快乐收作业器'),
            ),
            onTap: () => Navigator.of(context).pop(),
          ),
          const Divider(),
          InkWell(
            child: const ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.list_alt),
              ),
              title: Text('解析人员名单'),
            ),
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: ((context) => GetNameList(
                            onEditingComplete: saveList,
                          ))))
                  .then((value) {
                Navigator.of(context).pop();
              });
            },
          ),
          const Divider(),
          const Spacer(),
          const Divider(),
          SwitchListTile(
            secondary: const CircleAvatar(
              child: Icon(Icons.dark_mode),
            ),
            title: const Text('暗黑模式'),
            onChanged: (bool value) async {
              if (themeMode != ThemeMode.dark) {
                themeMode = ThemeMode.dark;
              } else {
                themeMode = ThemeMode.light;
              }
              setState(() {});
              await _save('Dark', themeMode.name);
            },
            value: themeMode == ThemeMode.dark,
          ),
          const Divider(),
          InkWell(
            child: const ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.clear_all),
              ),
              title: Text('清空'),
            ),
            onTap: () {
              setState(() {
                userMapList.clear();
                unselectUser.clear();
                addUser();
              });
              Navigator.of(context).pop();
            },
          ),
          const Divider(),
          InkWell(
            child: const ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.info),
              ),
              title: Text('关于'),
            ),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: ((context) => const UpdatePage())));
            },
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _rightDrawer(BuildContext context) {
    return Drawer(
      width: 200,
      child: Column(children: <Widget>[
        Row(
          children: const <Widget>[
            Expanded(
              child: DrawerHeader(
                child: Text(
                  "切换名单",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
        Expanded(
            child: ListView(
          children: saved.map((e) {
            return Container(
              color: e == barText
                  ? Colors.grey[(themeMode == ThemeMode.light ? 200 : 500)]
                  : (themeMode == ThemeMode.light
                      ? Colors.white
                      : Colors.grey[800]),
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Row(
                children: [
                  TextButton(
                    child: SizedBox(
                        width: 80,
                        child: Text(e,
                            style: TextStyle(
                                color: themeMode == ThemeMode.light
                                    ? Colors.black
                                    : Colors.white,
                                fontSize: 20),
                            overflow: TextOverflow.ellipsis)),
                    onPressed: () async {
                      final state = Navigator.of(context);
                      bool? result =
                          await _showConfirmDialog("是否切换到$e", context);
                      if (result == true) {
                        changeList(e);
                        barText = e;
                        state.pop();
                      }
                    },
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    padding: const EdgeInsets.all(0),
                    onPressed: () {
                      _get(e).then((value) {
                        if (value != null) {
                          edittingList = value.split('\n');
                        }
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: ((context) {
                          return ModifyListPage(
                            data: edittingList,
                          );
                        }))).then((v) {
                          if (v != null) {
                            _save(e, v).then((_) {
                              setState(() {
                                barText = e;
                                nameList = v.split('\n');
                                addUser();
                              });
                            });
                          }
                          Navigator.of(context).pop();
                        });
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    padding: const EdgeInsets.all(0),
                    onPressed: () async {
                      final state = Navigator.of(context);
                      bool? result =
                          await _showConfirmDialog("是否删除$e", context);
                      if (result == true) {
                        state.pop();
                        deleteList(e);
                      }
                    },
                  ),
                ],
              ),
            );
          }).toList(),
        )),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        locale: const Locale('zh', 'CH'),
        debugShowCheckedModeBanner: false,
        title: "call_out",
        themeMode: themeMode,
        theme: ThemeData.light(useMaterial3: true),
        darkTheme: ThemeData.dark(useMaterial3: true),
        home: Builder(builder: (context) {
          return firstOpen
              ? _firstOpenWidget(context)
              : Scaffold(
                  appBar: AppBar(
                    title: Text(barText),
                    centerTitle: true,
                  ),
                  body: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 10),
                        child: SearchWidget(onEditingComplete: search),
                      ),
                      Focus(focusNode: focus, child: Container()),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () => focus.requestFocus(),
                          child: ListView(
                              padding: const EdgeInsets.only(
                                  right: 15, left: 15, bottom: 15),
                              children: searchUser.map((e) {
                                return Column(
                                  children: [
                                    CheckboxListTile(
                                        title: Text(e.name,
                                            overflow: TextOverflow.ellipsis,
                                            style: e.isSelected
                                                ? const TextStyle(
                                                    color: Colors.grey,
                                                    decoration:
                                                        TextDecoration
                                                            .lineThrough)
                                                : TextStyle(
                                                    color: themeMode ==
                                                            ThemeMode.light
                                                        ? Colors.black
                                                        : Colors.white,
                                                  )),
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        value: e.isSelected,
                                        onChanged: (bool? v) {
                                          focus.requestFocus();
                                          setState(() {
                                            e.isSelected = v!;
                                            // 保存未选中的
                                            if (!e.isSelected) {
                                              if (!unselectUser
                                                  .contains(e)) {
                                                unselectUser.add(e);
                                              }
                                            } else {
                                              if (unselectUser
                                                  .contains(e)) {
                                                unselectUser.remove(e);
                                              }
                                            }
                                          });
                                        })
                                  ],
                                );
                              }).toList()),
                        ),
                      )
                    ],
                  ),
                  drawer: _leftDrawer(context),
                  endDrawer: _rightDrawer(context),
                  floatingActionButton: FloatingActionButton(
                    onPressed: () {
                      if (unselectUser.isNotEmpty) {
                        unselectUser.sort((a, b) => (a.id).compareTo(b.id));
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: ((context) =>
                                UnSelectPage(unselectUser: unselectUser))));
                      } else {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: const Text('恭喜'),
                                  content: const Text(('作业已交齐')),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text("确定"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                ));
                      }
                    },
                    tooltip: '是否交齐',
                    backgroundColor:
                        unselectUser.isEmpty ? Colors.blue : Colors.red,
                    child: unselectUser.isEmpty
                        ? const Icon(Icons.check)
                        : Text(unselectUser.length.toString()),
                  ),
                );
        }));
  }
}

class UserInfo {
  String name;
  int id;
  bool isSelected;
  UserInfo({required this.name, required this.id, this.isSelected = false});
}
