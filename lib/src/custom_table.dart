import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:math' as math;

/// A stateful copy button widget that handles copy state properly
class _CopyButton extends StatefulWidget {
  final String code;

  const _CopyButton({Key? key, required this.code}) : super(key: key);

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool isCopied = false;

  void handleCopy() async {
    final String codeToCopy = widget.code;
    try {
      if (codeToCopy.isNotEmpty) {
        HapticFeedback.lightImpact();
        await Clipboard.setData(ClipboardData(text: codeToCopy));
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

/// A share button widget for tables
class _ShareButton extends StatelessWidget {
  final String markdown;

  const _ShareButton({Key? key, required this.markdown}) : super(key: key);

  // Convert markdown table to CSV format (optimized)
  String _tableToCSV(String markdown) {
    try {
      final lines = markdown.trim().split('\n');
      final List<String> csvLines = [];

      for (final line in lines) {
        if (line.trim().isEmpty) continue;

        // Skip separator lines (lines with only dashes and pipes) - optimized check
        if (RegExp(r'^[|\-\s]+$').hasMatch(line)) continue;

        // Parse table row - more efficient splitting
        final cells = line
            .split('|')
            .map((cell) => cell.trim())
            .where((cell) => cell.isNotEmpty)
            .toList();

        if (cells.isNotEmpty) {
          // Clean up cells and escape quotes for CSV - optimized processing
          final cleanCells = cells.map((cell) {
            // Remove markdown formatting like **text** - single regex for better performance
            // Properly strip **bold** markdown by capturing inner text.
            String cleanCell = cell.replaceAllMapped(
              RegExp(r'\*\*(.*?)\*\*'),
              (match) => match.group(1) ?? '',
            );

            // Escape quotes and wrap in quotes if contains comma, quotes, or newlines
            if (cleanCell.contains(',') ||
                cleanCell.contains('"') ||
                cleanCell.contains('\n')) {
              cleanCell = '"${cleanCell.replaceAll('"', '""')}"';
            }
            return cleanCell;
          }).toList();

          csvLines.add(cleanCells.join(','));
        }
      }

      return csvLines.join('\n');
    } catch (e) {
      debugPrint('CSV conversion failed: $e');
      // Fallback: return original markdown
      return markdown;
    }
  }

  void handleShare(BuildContext context) async {
    try {
      if (markdown.isEmpty) return;
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
                Text('Converting table to CSV...'),
              ],
            ),
            duration: Duration(seconds: 1),
          ),
        );
      }

      // Convert markdown table to CSV (moved after user feedback)
      final csvContent = _tableToCSV(markdown);

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final fileName = 'table_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File('${tempDir.path}/$fileName');

      // Write CSV content to file
      await file.writeAsString(csvContent);

      // Share the CSV file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Table data',
        subject: 'Table Export',
      );
    } catch (e) {
      debugPrint('Table share failed: ${e.toString()}');
      // Fallback to text sharing
      await Share.share(
        'Table:\n\n$markdown',
        subject: 'Table Data',
      );
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

class CustomTable extends StatelessWidget {
  const CustomTable({
    Key? key,
    this.width,
    this.height,
    required this.markdown,
    required this.fontSize,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String markdown;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final tableData = _parseTableData(markdown);
    if (tableData.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with table badge and buttons
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
                // Table badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'TABLE',
                    style: TextStyle(
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
                  onTap: () => _showExpandedView(context, tableData),
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
                _ShareButton(markdown: markdown),
                const SizedBox(width: 12),
                // Copy button
                _CopyButton(code: markdown),
              ],
            ),
          ),
          // Separator
          Container(
            height: 1,
            color: const Color(0xFF2A2A2A),
          ),
          // Table content
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
              child: _buildTableContent(tableData, isModal: false),
            ),
          ),
        ],
      ),
    );
  }

  List<List<String>> _parseTableData(String markdown) {
    // Handle escaped newlines
    final processedMarkdown = markdown.replaceAll('\\n', '\n');

    final lines = processedMarkdown.trim().split('\n');

    final List<List<String>> tableData = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      if (line.trim().isEmpty) {
        continue;
      }

      // Skip separator lines (lines with only dashes, pipes, colons, and spaces)
      if (RegExp(r'^[\|\-\s:]+$').hasMatch(line.trim())) {
        continue;
      }

      // Parse table row
      final cells = line
          .split('|')
          .map((cell) => cell.trim())
          .where((cell) => cell.isNotEmpty)
          .map((cell) {
        // Handle <br> tags in table cells
        return cell.replaceAll('<br>', '\n').replaceAll('<BR>', '\n');
      }).toList();

      if (cells.isNotEmpty) {
        tableData.add(cells);
      }
    }

    return tableData;
  }

  void _showExpandedView(BuildContext context, List<List<String>> tableData) {
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Table badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'TABLE',
                          style: TextStyle(
                            color: Color(0xFF8A8A8A),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Spacer(),
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
                      const SizedBox(width: 12),
                      // Share button
                      _ShareButton(markdown: markdown),
                      const SizedBox(width: 12),
                      // Copy button
                      _CopyButton(code: markdown),
                    ],
                  ),
                ),
                Container(height: 1, color: const Color(0xFF2A2A2A)),
                // Modal Content
                Expanded(
                  child: Container(
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
                      controller: controller,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: _buildTableContent(tableData, isModal: true),
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

  Widget _buildTableContent(List<List<String>> tableData,
      {bool isModal = false}) {
    if (tableData.isEmpty) return const SizedBox.shrink();

    final headers = tableData.first;
    final rows = tableData.length > 1 ? tableData.sublist(1) : <List<String>>[];

    // Calculate column widths for better alignment
    final List<double> columnWidths = [];
    for (int i = 0; i < headers.length; i++) {
      double maxWidth = 120; // minimum width

      // Check header width
      final headerText = _processMarkdownText(headers[i]);
      maxWidth = math.max(maxWidth, headerText.length * 8.0 + 32);

      // Check data cell widths
      for (final row in rows) {
        if (i < row.length) {
          final cellText = _processMarkdownText(row[i]);
          maxWidth = math.max(maxWidth, cellText.length * 8.0 + 32);
        }
      }

      // Cap maximum width to prevent extreme cases
      columnWidths.add(math.min(maxWidth, isModal ? 300 : 200));
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF2A2A2A)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF2A2A2A),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: headers.asMap().entries.map((entry) {
                final index = entry.key;
                final header = entry.value;

                return Container(
                  width: columnWidths[index],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: index > 0
                        ? const Border(
                            left:
                                BorderSide(color: Color(0xFF2A2A2A), width: 1),
                          )
                        : null,
                  ),
                  child: _processCellContent(header, 14.0, isHeader: true),
                );
              }).toList(),
            ),
          ),
          // Data rows
          ...rows.asMap().entries.map((rowEntry) {
            final rowIndex = rowEntry.key;
            final row = rowEntry.value;
            return Container(
              decoration: BoxDecoration(
                color: rowIndex.isEven
                    ? const Color(0xFF1A1A1A)
                    : const Color(0xFF1F1F1F),
                border: const Border(
                  top: BorderSide(color: Color(0xFF2A2A2A), width: 1),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: row.asMap().entries.map((cellEntry) {
                  final cellIndex = cellEntry.key;
                  final cell = cellEntry.value;

                  return Container(
                    width: cellIndex < columnWidths.length
                        ? columnWidths[cellIndex]
                        : 120,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: cellIndex > 0
                          ? const Border(
                              left: BorderSide(
                                  color: Color(0xFF2A2A2A), width: 1),
                            )
                          : null,
                    ),
                    child: _processCellContent(cell, fontSize),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // Helper function to process markdown in cell text (for bold headers)
  String _processMarkdownText(String text) {
    // Convert **text** to just text (we'll apply bold styling separately).
    return text.replaceAllMapped(
      RegExp(r'\*\*(.*?)\*\*'),
      (match) => match.group(1) ?? '',
    );
  }

  // Helper function to check if text should be bold
  bool _shouldBeBold(String originalText) {
    return originalText.contains('**');
  }

  // Helper function to process markdown in cell text (for embedded code blocks)
  Widget _processCellContent(String text, double fontSize,
      {bool isHeader = false}) {
    // Check if cell contains code blocks
    final codeBlockPattern = RegExp(r'```(\w*)\n?(.*?)\n?```', dotAll: true);
    final match = codeBlockPattern.firstMatch(text);

    if (match != null) {
      // Cell contains a code block
      final code = match.group(2) ?? '';

      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          code,
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: fontSize * 0.85,
            color: Colors.white,
            height: 1.4,
          ),
        ),
      );
    }

    // Regular text cell
    final cleanText = _processMarkdownText(text);
    final isBold = _shouldBeBold(text);

    return Text(
      cleanText,
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: isHeader
            ? (isBold ? FontWeight.bold : FontWeight.w600)
            : (isBold ? FontWeight.bold : FontWeight.normal),
        height: 1.4,
      ),
    );
  }
} 