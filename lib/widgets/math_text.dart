import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class MathText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const MathText({
    super.key,
    required this.text,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    // Split text by LaTeX math delimiters if present (e.g. $...$ or \(...\))
    final parts = _parseLatex(text);

    if (parts.length == 1 && !parts.first.isMath) {
      return Text(text, style: style);
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: parts.map((part) {
        if (part.isMath) {
          try {
            return Math.tex(
              part.content,
              textStyle: style,
              onErrorFallback: (err) => Text(
                part.content,
                style: style?.copyWith(color: Colors.red),
              ),
            );
          } catch (_) {
            return Text(part.content, style: style);
          }
        } else {
          return Text(part.content, style: style);
        }
      }).toList(),
    );
  }

  List<_TextSegment> _parseLatex(String input) {
    final List<_TextSegment> segments = [];
    final RegExp regex = RegExp(r'\$([^$]+)\$|\\\[(.*?)\\\]');
    int lastMatchEnd = 0;

    for (final Match match in regex.allMatches(input)) {
      if (match.start > lastMatchEnd) {
        segments.add(_TextSegment(
          content: input.substring(lastMatchEnd, match.start),
          isMath: false,
        ));
      }

      final mathContent = match.group(1) ?? match.group(2) ?? '';
      segments.add(_TextSegment(
        content: mathContent.trim(),
        isMath: true,
      ));

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < input.length) {
      segments.add(_TextSegment(
        content: input.substring(lastMatchEnd),
        isMath: false,
      ));
    }

    return segments.isEmpty ? [_TextSegment(content: input, isMath: false)] : segments;
  }
}

class _TextSegment {
  final String content;
  final bool isMath;

  _TextSegment({required this.content, required this.isMath});
}
