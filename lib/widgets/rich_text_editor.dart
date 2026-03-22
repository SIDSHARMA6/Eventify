import 'package:flutter/material.dart';
import 'clickable_text.dart';

class RichTextEditor extends StatefulWidget {
  final TextEditingController controller;
  final String? label, hint;
  final int maxLines;
  const RichTextEditor({super.key, required this.controller, this.label, this.hint, this.maxLines = 5});

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  final _node = FocusNode();

  void _fmt(String p, String s) {
    final t = widget.controller.text;
    final sel = widget.controller.selection;
    if (sel.start == -1) {
      widget.controller.text += p + s;
    } else {
      widget.controller.text = t.replaceRange(sel.start, sel.end, '$p${t.substring(sel.start, sel.end)}$s');
    }
    _node.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (widget.label != null) Text(widget.label!, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
        child: Row(children: [
          IconButton(icon: const Icon(Icons.format_bold), onPressed: () => _fmt('**', '**')),
          IconButton(icon: const Icon(Icons.format_italic), onPressed: () => _fmt('*', '*')),
        ]),
      ),
      TextField(
        controller: widget.controller,
        focusNode: _node,
        maxLines: widget.maxLines,
        decoration: InputDecoration(hintText: widget.hint, border: const OutlineInputBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)))),
      ),
      const SizedBox(height: 10),
      const Text('Preview:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      Container(
        width: double.infinity, margin: const EdgeInsets.only(top: 4), padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
        child: ValueListenableBuilder(valueListenable: widget.controller, builder: (_, val, __) => ClickableText(text: val.text)),
      ),
    ]);
  }
}
