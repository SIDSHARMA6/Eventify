import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Widget that makes URLs clickable and supports **bold** and *italic* formatting
class ClickableText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const ClickableText({
    super.key,
    required this.text,
    this.style,
  });

  @override
  State<ClickableText> createState() => _ClickableTextState();
}

class _ClickableTextState extends State<ClickableText> {
  String _cachedText = '';
  List<TextSpan>? _cachedSpans;

  @override
  Widget build(BuildContext context) {
    // Only reparse if text changed
    if (widget.text != _cachedText || _cachedSpans == null) {
      _cachedText = widget.text;
      _cachedSpans = _parseText(context);
    }

    return RichText(
      text: TextSpan(children: _cachedSpans!),
    );
  }

  List<TextSpan> _parseText(BuildContext context) {
    final defaultStyle = widget.style ?? Theme.of(context).textTheme.bodyLarge!;
    final linkStyle = defaultStyle.copyWith(
      color: Theme.of(context).primaryColor,
      decoration: TextDecoration.underline,
    );
    final boldStyle = defaultStyle.copyWith(
      fontWeight: FontWeight.bold,
    );
    final italicStyle = defaultStyle.copyWith(
      fontStyle: FontStyle.italic,
    );

    // Parse text for URLs, bold, and italic formatting
    final spans = <TextSpan>[];
    final lines = widget.text.split('\n');

    for (int lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final line = lines[lineIndex];

      // Process formatting in this line
      _processLine(
          line, defaultStyle, linkStyle, boldStyle, italicStyle, spans);

      // Add newline if not last line
      if (lineIndex < lines.length - 1) {
        spans.add(TextSpan(text: '\n', style: defaultStyle));
      }
    }

    return spans;
  }

  void _processLine(
    String line,
    TextStyle defaultStyle,
    TextStyle linkStyle,
    TextStyle boldStyle,
    TextStyle italicStyle,
    List<TextSpan> spans,
  ) {
    // Patterns to match URLs, bold, and italic text
    final urlPattern = RegExp(r'https?://[^\s]+');
    final boldPattern = RegExp(r'\*\*(.+?)\*\*');
    final italicPattern = RegExp(r'(?<!\*)\*(?!\*)(.+?)(?<!\*)\*(?!\*)');

    int lastIndex = 0;

    // Find all patterns
    final allMatches = <_Match>[];

    // Add URL matches
    for (final match in urlPattern.allMatches(line)) {
      allMatches.add(_Match(match.start, match.end, 'url', match.group(0)!));
    }

    // Add bold matches
    for (final match in boldPattern.allMatches(line)) {
      allMatches.add(_Match(match.start, match.end, 'bold', match.group(1)!));
    }

    // Add italic matches (not part of bold)
    for (final match in italicPattern.allMatches(line)) {
      // Check if this match is not inside a bold match
      final isInsideBold = allMatches.any((m) =>
          m.type == 'bold' && match.start >= m.start && match.end <= m.end);
      if (!isInsideBold) {
        allMatches
            .add(_Match(match.start, match.end, 'italic', match.group(1)!));
      }
    }

    // Sort by start position
    allMatches.sort((a, b) => a.start.compareTo(b.start));

    for (final match in allMatches) {
      // Add text before match
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: line.substring(lastIndex, match.start),
          style: defaultStyle,
        ));
      }

      // Add matched content
      if (match.type == 'url') {
        spans.add(TextSpan(
          text: match.content,
          style: linkStyle,
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              final uri = Uri.parse(match.content);
              try {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } catch (_) {}
            },
        ));
      } else if (match.type == 'bold') {
        spans.add(TextSpan(
          text: match.content,
          style: boldStyle,
        ));
      } else if (match.type == 'italic') {
        spans.add(TextSpan(
          text: match.content,
          style: italicStyle,
        ));
      }

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < line.length) {
      spans.add(TextSpan(
        text: line.substring(lastIndex),
        style: defaultStyle,
      ));
    }
  }
}

class _Match {
  final int start;
  final int end;
  final String type;
  final String content;

  _Match(this.start, this.end, this.type, this.content);
}
