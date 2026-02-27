import 'package:flutter/material.dart';

/// Rich text editor with Bold and Italic formatting buttons
class RichTextEditor extends StatefulWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final int maxLines;

  const RichTextEditor({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.maxLines = 5,
  });

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  bool _isBold = false;
  bool _isItalic = false;
  final FocusNode _focusNode = FocusNode();
  String _lastPreviewText = '';
  Widget? _cachedPreview;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _insertFormatting(String prefix, String suffix) {
    final text = widget.controller.text;
    final selection = widget.controller.selection;

    if (selection.start == -1) {
      // No selection, insert at end
      widget.controller.text = text + prefix + suffix;
      widget.controller.selection = TextSelection.collapsed(
        offset: text.length + prefix.length,
      );
    } else if (selection.start == selection.end) {
      // Cursor position, no text selected
      final newText = text.substring(0, selection.start) +
          prefix +
          suffix +
          text.substring(selection.start);
      widget.controller.text = newText;
      widget.controller.selection = TextSelection.collapsed(
        offset: selection.start + prefix.length,
      );
    } else {
      // Text is selected
      final selectedText = text.substring(selection.start, selection.end);
      final newText = text.substring(0, selection.start) +
          prefix +
          selectedText +
          suffix +
          text.substring(selection.end);
      widget.controller.text = newText;
      widget.controller.selection = TextSelection.collapsed(
        offset: selection.start +
            prefix.length +
            selectedText.length +
            suffix.length,
      );
    }

    _focusNode.requestFocus();
  }

  void _toggleBold() {
    setState(() {
      _isBold = !_isBold;
    });
    _insertFormatting('**', '**');
  }

  void _toggleItalic() {
    setState(() {
      _isItalic = !_isItalic;
    });
    _insertFormatting('*', '*');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.label!,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),

        // Formatting toolbar
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              // Bold button
              IconButton(
                icon: const Icon(Icons.format_bold),
                color: _isBold
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).iconTheme.color,
                onPressed: _toggleBold,
                tooltip: 'Bold (**text**)',
                style: IconButton.styleFrom(
                  backgroundColor: _isBold
                      ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                      : null,
                ),
              ),

              // Italic button
              IconButton(
                icon: const Icon(Icons.format_italic),
                color: _isItalic
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).iconTheme.color,
                onPressed: _toggleItalic,
                tooltip: 'Italic (*text*)',
                style: IconButton.styleFrom(
                  backgroundColor: _isItalic
                      ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                      : null,
                ),
              ),

              const Spacer(),

              // Help text
              Text(
                'Bold: **text**  Italic: *text*',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withValues(alpha: 0.6),
                    ),
              ),
            ],
          ),
        ),

        // Text field
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          maxLines: widget.maxLines,
          onChanged: (_) {
            // Invalidate cache on text change
            setState(() {
              _cachedPreview = null;
            });
          },
          decoration: InputDecoration(
            hintText: widget.hint,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(12)),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(12)),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
          ),
          style: Theme.of(context).textTheme.bodyLarge,
        ),

        // Preview section
        const SizedBox(height: 8),
        Text(
          'Preview:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: _buildPreview(context),
        ),
      ],
    );
  }

  Widget _buildPreview(BuildContext context) {
    final text = widget.controller.text;

    // Cache preview if text hasn't changed
    if (text == _lastPreviewText && _cachedPreview != null) {
      return _cachedPreview!;
    }

    _lastPreviewText = text;

    if (text.isEmpty) {
      _cachedPreview = Text(
        'Preview will appear here...',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontStyle: FontStyle.italic,
            ),
      );
      return _cachedPreview!;
    }

    _cachedPreview = _buildFormattedText(text, context);
    return _cachedPreview!;
  }

  Widget _buildFormattedText(String text, BuildContext context) {
    final spans = <TextSpan>[];
    final boldPattern = RegExp(r'\*\*(.+?)\*\*');
    final italicPattern = RegExp(r'(?<!\*)\*(?!\*)(.+?)(?<!\*)\*(?!\*)');

    int lastIndex = 0;
    final allMatches = <_FormatMatch>[];

    // Find bold matches
    for (final match in boldPattern.allMatches(text)) {
      allMatches
          .add(_FormatMatch(match.start, match.end, 'bold', match.group(1)!));
    }

    // Find italic matches (not part of bold)
    for (final match in italicPattern.allMatches(text)) {
      // Check if this match is not inside a bold match
      final isInsideBold = allMatches.any((m) =>
          m.type == 'bold' && match.start >= m.start && match.end <= m.end);
      if (!isInsideBold) {
        allMatches.add(
            _FormatMatch(match.start, match.end, 'italic', match.group(1)!));
      }
    }

    // Sort by start position
    allMatches.sort((a, b) => a.start.compareTo(b.start));

    for (final match in allMatches) {
      // Add text before match
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: Theme.of(context).textTheme.bodyMedium,
        ));
      }

      // Add formatted text
      if (match.type == 'bold') {
        spans.add(TextSpan(
          text: match.content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ));
      } else if (match.type == 'italic') {
        spans.add(TextSpan(
          text: match.content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
        ));
      }

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: Theme.of(context).textTheme.bodyMedium,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}

class _FormatMatch {
  final int start;
  final int end;
  final String type;
  final String content;

  _FormatMatch(this.start, this.end, this.type, this.content);
}
