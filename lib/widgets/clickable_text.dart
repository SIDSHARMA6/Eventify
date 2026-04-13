import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// FIX L-04/L-05: StatefulWidget to properly dispose TapGestureRecognizers
class ClickableText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  const ClickableText({super.key, required this.text, this.style});

  @override
  State<ClickableText> createState() => _ClickableTextState();
}

class _ClickableTextState extends State<ClickableText> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();

    final s = widget.style ?? Theme.of(context).textTheme.bodyLarge!;
    final spans = <TextSpan>[];
    final reg = RegExp(
        r'(https?://[^\s]+)|\*\*(.+?)\*\*|(?<!\*)\*(?!\*)(.+?)(?<!\*)\*(?!\*)');

    int last = 0;
    reg.allMatches(widget.text).forEach((m) {
      if (m.start > last) {
        spans.add(TextSpan(text: widget.text.substring(last, m.start), style: s));
      }
      if (m.group(1) != null) {
        final url = m.group(1)!;
        final recognizer = TapGestureRecognizer()
          ..onTap = () async {
            try {
              await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
            } catch (_) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Could not open link.')),
                );
              }
            }
          };
        _recognizers.add(recognizer);
        spans.add(TextSpan(
            text: url,
            style: s.copyWith(color: Colors.blue, decoration: TextDecoration.underline),
            recognizer: recognizer));
      } else if (m.group(2) != null) {
        spans.add(TextSpan(text: m.group(2), style: s.copyWith(fontWeight: FontWeight.bold)));
      } else if (m.group(3) != null) {
        spans.add(TextSpan(text: m.group(3), style: s.copyWith(fontStyle: FontStyle.italic)));
      }
      last = m.end;
    });
    if (last < widget.text.length) {
      spans.add(TextSpan(text: widget.text.substring(last), style: s));
    }

    return RichText(text: TextSpan(children: spans));
  }
}
