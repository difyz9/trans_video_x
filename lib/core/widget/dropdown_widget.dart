import 'package:flutter/material.dart';

class DropdownWidget extends StatefulWidget {
  final String? initialValue; // 初始选中的值
  final Function(String?)? onChanged; // 选择变化时的回调
  final String labelText; // 下拉框标签
  final double width; // 组件宽度
  final List<String> options; // 下拉选项列表

  const DropdownWidget({
    Key? key,
    this.initialValue,
    this.onChanged,
    this.labelText = '音色',
    this.width = 200,
    this.options = const ['英语', '中文'],
  }) : super(key: key);

  @override
  _DropdownWidgetState createState() => _DropdownWidgetState();
}

class _DropdownWidgetState extends State<DropdownWidget> {
  late String? selectedLanguage;

  @override
  void initState() {
    super.initState();
    selectedLanguage = widget.initialValue; // 设置初始值
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: DropdownButtonFormField<String>(
        value: selectedLanguage,
        items: widget.options
            .map((String value) => DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            selectedLanguage = value;
          });
          if (widget.onChanged != null) {
            widget.onChanged!(value); // 调用外部传入的回调
          }
        },
        decoration: InputDecoration(
          labelText: widget.labelText,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}