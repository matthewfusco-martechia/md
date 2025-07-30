import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// {@template think_block}
/// A collapsible widget for displaying "thinking" content in markdown.
/// Supports both incomplete (showing loading animation) and complete states.
/// {@endtemplate}
class ThinkBlock extends StatefulWidget {
  /// Creates a [ThinkBlock].
  /// {@macro think_block}
  const ThinkBlock({
    Key? key,
    this.width,
    this.height,
    required this.content,
    required this.isComplete,
    required this.fontSize,
    required this.onToggle,
    this.contentWidget,
  }) : super(key: key);

  /// The width of the think block.
  final double? width;

  /// The height of the think block.
  final double? height;

  /// The raw text content to display when expanded.
  final String content;

  /// Whether the thinking process is complete.
  final bool isComplete;

  /// The font size to use for text.
  final double fontSize;

  /// Callback when the block is toggled.
  final VoidCallback onToggle;

  /// Pre-rendered content widget to display instead of raw text.
  final Widget? contentWidget;

  @override
  State<ThinkBlock> createState() => _ThinkBlockState();
}

class _ThinkBlockState extends State<ThinkBlock> {
  bool _isExpanded = false;
  static const Color thinkTextColor = Color(0xFF656565);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: widget.isComplete
              ? () {
                  // Add haptic feedback
                  HapticFeedback.selectionClick();

                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                  widget.onToggle();
                }
              : null,
          child: Row(
            children: [
              Icon(
                Icons.psychology_outlined,
                color: thinkTextColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.isComplete ? "Thought Process" : "Thinking...",
                  style: TextStyle(
                    fontFamily: GoogleFonts.openSans().fontFamily,
                    fontSize: widget.fontSize * 0.85,
                    color: thinkTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (!widget.isComplete)
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(thinkTextColor),
                  ),
                )
              else
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: thinkTextColor,
                  size: 16,
                ),
            ],
          ),
        ),
        if (_isExpanded && widget.isComplete) ...[
          const SizedBox(height: 8),
          widget.contentWidget ??
              Text(
                widget.content,
                style: TextStyle(
                  fontFamily: GoogleFonts.openSans().fontFamily,
                  fontSize: widget.fontSize * 0.9,
                  color: thinkTextColor,
                  height: 1.4,
                ),
              ),
        ],
      ],
    );
  }
} 