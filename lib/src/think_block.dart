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
          child: Container(
            margin: _isExpanded && widget.isComplete
                ? const EdgeInsets.only(top: 4, left: 0, right: 0, bottom: 0)
                : const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
              borderRadius: _isExpanded && widget.isComplete
                  ? const BorderRadius.vertical(top: Radius.circular(8))
                  : BorderRadius.circular(8),
            ),
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
        ),
        if (_isExpanded && widget.isComplete)
          GestureDetector(
            onTap: () {
              // Add haptic feedback
              HapticFeedback.selectionClick();

              setState(() {
                _isExpanded = !_isExpanded;
              });
              widget.onToggle();
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                border: const Border(
                  left: BorderSide(color: Color(0xFF2A2A2A), width: 0.5),
                  right: BorderSide(color: Color(0xFF2A2A2A), width: 0.5),
                  bottom: BorderSide(color: Color(0xFF2A2A2A), width: 0.5),
                ),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(8)),
              ),
              child: widget.contentWidget ??
                  Text(
                    widget.content,
                    style: TextStyle(
                      fontFamily: GoogleFonts.openSans().fontFamily,
                      fontSize: widget.fontSize * 0.9,
                      color: thinkTextColor,
                      height: 1.4,
                    ),
                  ),
            ),
          ),
      ],
    );
  }
} 