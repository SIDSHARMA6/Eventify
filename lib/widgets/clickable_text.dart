import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ClickableText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  const ClickableText({super.key, required this.text, this.style});

  @override
  Widget build(BuildContext context) {
    final s = style ?? Theme.of(context).textTheme.bodyLarge!;
    final spans = <TextSpan>[];
    final reg = RegExp(r'(https?://[^\s]+)|\*\*(.+?)\*\*|(?<!\*)\*(?!\*)(.+?)(?<!\*)\*(?!\*)');
    
    int last = 0;
    reg.allMatches(text).forEach((m) {
      if (m.start > last) spans.add(TextSpan(text: text.substring(last, m.start), style: s));
      if (m.group(1) != null) {
        spans.add(TextSpan(text: m.group(1), style: s.copyWith(color: Colors.blue, decoration: TextDecoration.underline), recognizer: TapGestureRecognizer()..onTap = () => launchUrl(Uri.parse(m.group(1)!))));
      } else if (m.group(2) != null) {
        spans.add(TextSpan(text: m.group(2), style: s.copyWith(fontWeight: FontWeight.bold)));
      } else if (m.group(3) != null) {
        spans.add(TextSpan(text: m.group(3), style: s.copyWith(fontStyle: FontStyle.italic)));
      }
      last = m.end;
    });
    if (last < text.length) spans.add(TextSpan(text: text.substring(last), style: s));
    
    return RichText(text: TextSpan(children: spans));
  }
}
