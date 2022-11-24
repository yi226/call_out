import 'package:flutter/material.dart';

/// @author longzipeng
/// @创建时间：2022/3/29
/// 查询组件
class SearchWidget extends StatefulWidget {
  final double? height; // 高度
  final double? width; // 宽度
  final String? hintText; // 输入提示
  final ValueChanged<String>? onEditingComplete; // 编辑完成的事件回调

  const SearchWidget(
      {Key? key,
      this.height,
      this.width,
      this.hintText,
      this.onEditingComplete})
      : super(key: key);

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  var controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  /// 清除查询关键词
  clearKeywords() {
    controller.text = '';
    widget.onEditingComplete?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constrains) {
      var width = widget.width ?? constrains.maxWidth / 1.5; // 父级宽度
      return SizedBox(
        width: width,
        child: TextFormField(
            controller: controller,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
                hintText: widget.hintText ?? "请输入搜索词",
                hintStyle: const TextStyle(color: Colors.grey),
                isDense: true,
                border: const OutlineInputBorder(),
                icon: const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Icon(Icons.search, size: 18)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: clearKeywords,
                  splashColor: Colors.grey,
                )),
            onChanged: (v) {
              widget.onEditingComplete?.call(controller.text);
            }),
      );
    });
  }
}
