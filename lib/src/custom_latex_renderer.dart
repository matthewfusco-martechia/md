import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_math_fork/flutter_math.dart';

/// A stateful copy button widget for LaTeX content
class _LatexCopyButton extends StatefulWidget {
  final String latexContent;

  const _LatexCopyButton({Key? key, required this.latexContent}) : super(key: key);

  @override
  State<_LatexCopyButton> createState() => _LatexCopyButtonState();
}

class _LatexCopyButtonState extends State<_LatexCopyButton> {
  bool isCopied = false;

  void handleCopy() async {
    try {
      if (widget.latexContent.isNotEmpty) {
        HapticFeedback.lightImpact();
        await Clipboard.setData(ClipboardData(text: widget.latexContent));
        setState(() {
          isCopied = true;
        });
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              isCopied = false;
            });
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to copy: ${e.toString()}'),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: handleCopy,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          isCopied ? Icons.check : Icons.copy_outlined,
          color: isCopied ? const Color(0xFF4CAF50) : const Color(0xFFA0A0A0),
          size: 18,
        ),
      ),
    );
  }
}

/// A share button widget for LaTeX content
class _LatexShareButton extends StatelessWidget {
  final String latexContent;
  final String displayType;

  const _LatexShareButton({
    Key? key,
    required this.latexContent,
    required this.displayType,
  }) : super(key: key);

  void handleShare(BuildContext context) async {
    try {
      if (latexContent.isEmpty) return;
      HapticFeedback.lightImpact();

      // Show immediate user feedback
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Preparing LaTeX file for sharing...'),
              ],
            ),
            duration: Duration(seconds: 1),
          ),
        );
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'latex_${displayType.toLowerCase()}_$timestamp.tex';

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');

      await file.writeAsString(latexContent);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: '$displayType LaTeX file',
        subject: '$displayType LaTeX',
      );
    } catch (e) {
      debugPrint('LaTeX share failed: ${e.toString()}');
      // Fallback to text sharing
      if (context.mounted) {
        try {
          await Share.share(
            latexContent,
            subject: '$displayType LaTeX',
          );
        } catch (fallbackError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to share: ${fallbackError.toString()}'),
              backgroundColor: Colors.red[700],
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => handleShare(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: const Icon(
          Icons.share_outlined,
          color: Color(0xFFA0A0A0),
          size: 18,
        ),
      ),
    );
  }
}

class CustomLatexRenderer extends StatelessWidget {
  const CustomLatexRenderer({
    Key? key,
    this.width,
    this.height,
    required this.content,
    required this.isDisplay,
    required this.style,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String content;
  final bool isDisplay;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final displayType = _getLatexDisplayType(content);
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with badge and buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // LaTeX badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    displayType.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF8A8A8A),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                // Expand button
                InkWell(
                  onTap: () => _showLatexExpandedView(context, content, displayType),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      Icons.open_in_full,
                      color: Color(0xFFA0A0A0),
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Share button
                _LatexShareButton(latexContent: content, displayType: displayType),
                const SizedBox(width: 12),
                // Copy button
                _LatexCopyButton(latexContent: content),
              ],
            ),
          ),
          // Separator
          Container(
            height: 1,
            color: const Color(0xFF2A2A2A),
          ),
          // Content area - rendered LaTeX
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: _buildLatexContent(content, style),
            ),
          ),
        ],
      ),
    );
  }

  // Get appropriate display type label
  String _getLatexDisplayType(String content) {
    if (content.contains(RegExp(r'\\begin\{equation\}'))) return 'LaTeX Equation';
    if (content.contains(RegExp(r'\\begin\{align\}'))) return 'LaTeX Alignment';
    if (content.contains(RegExp(r'\\documentclass'))) return 'LaTeX Document';
    if (content.contains(RegExp(r'\\\[')) && content.contains(RegExp(r'\\\]'))) return 'LaTeX Display Math';
    if (content.contains(RegExp(r'\$\$'))) return 'LaTeX Math';
    return 'LaTeX Code';
  }

  // Show expanded view for LaTeX content
  void _showLatexExpandedView(BuildContext context, String latexData, String displayType) {
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext modalContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, controller) {
            return Column(
              children: [
                // Modal Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      // LaTeX badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          displayType.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF8A8A8A),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Share button
                      _LatexShareButton(latexContent: latexData, displayType: displayType),
                      const SizedBox(width: 12),
                      // Copy button
                      _LatexCopyButton(latexContent: latexData),
                      const SizedBox(width: 12),
                      // Close button
                      InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.of(modalContext).pop();
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.close,
                            color: Color(0xFFA0A0A0),
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Separator
                Container(
                  height: 1,
                  color: const Color(0xFF2A2A2A),
                ),
                // Expanded content
                Expanded(
                  child: SingleChildScrollView(
                    controller: controller,
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F0F0F),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF2A2A2A)),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: _buildLatexContent(latexData, style, isExpanded: true),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Build LaTeX content with proper rendering
  Widget _buildLatexContent(String content, TextStyle style, {bool isExpanded = false}) {
    try {
      // Clean the LaTeX content
      String cleanContent = content.trim();
      
      // Remove various LaTeX display math delimiters
      // Handle \[ ... \] delimiters
      if (cleanContent.startsWith('\\[') && cleanContent.endsWith('\\]')) {
        cleanContent = cleanContent.substring(2, cleanContent.length - 2).trim();
      }
      // Handle $$ ... $$ delimiters
      else if (cleanContent.startsWith('\$\$') && cleanContent.endsWith('\$\$')) {
        cleanContent = cleanContent.substring(2, cleanContent.length - 2).trim();
      }
      // Handle single $ ... $ delimiters (inline math)
      else if (cleanContent.startsWith('\$') && cleanContent.endsWith('\$') && cleanContent.length > 2) {
        cleanContent = cleanContent.substring(1, cleanContent.length - 1).trim();
      }
      
      // Also remove any remaining \[ or \] that might be in the content
      cleanContent = cleanContent.replaceAll('\\[', '').replaceAll('\\]', '');
      
      // Remove any leading/trailing whitespace again
      cleanContent = cleanContent.trim();
      
      // Skip if content is empty after cleaning
      if (cleanContent.isEmpty) {
        return const Text('Empty LaTeX content', style: TextStyle(color: Colors.grey));
      }
      
      // Try to render the LaTeX
      return Math.tex(
        cleanContent,
        textStyle: TextStyle(
          color: style.color ?? Colors.white,
          fontSize: isExpanded ? (style.fontSize ?? 14.0) * 1.2 : (style.fontSize ?? 14.0),
        ),
        mathStyle: MathStyle.display,
      );
    } catch (e) {
      // Fallback to displaying raw LaTeX if rendering fails
      debugPrint('LaTeX rendering failed: $e');
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF3A3A3A)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LaTeX Rendering Error',
              style: TextStyle(
                color: Colors.red[300],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Error: $e',
              style: TextStyle(
                color: Colors.red[400],
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 8),
            SelectableText(
              content,
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: style.fontSize ?? 14.0,
                color: const Color(0xFFE1E1E1),
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }
  }
} 