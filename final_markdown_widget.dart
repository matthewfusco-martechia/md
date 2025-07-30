// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:math' as math;
import 'package:flutter_md/flutter_md.dart'
    as md; // Change alias to avoid conflicts
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class MarkdownWidget extends StatefulWidget {
  const MarkdownWidget({
    super.key,
    this.width,
    this.height,
    required this.data,
    required this.fontSize,
    required this.mdcolor,
  });

  final double? width;
  final double? height;
  final String data;
  final double fontSize;
  final Color mdcolor;

  @override
  State<MarkdownWidget> createState() => _MarkdownWidgetState();
}

class _MarkdownWidgetState extends State<MarkdownWidget> {
  List<bool> _thinkBlockStates = [];

  // Storage for custom components
  Map<int, String> _tables = {};
  Map<int, String> _latexBlocks = {}; // LaTeX blocks storage only

  @override
  void initState() {
    super.initState();
    _initializeThinkBlockStates();
  }

  @override
  void didUpdateWidget(MarkdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      _initializeThinkBlockStates();
    }
  }

  void _initializeThinkBlockStates() {
    final thinkBlockPattern = RegExp(
        r'<think(?:\s+complete="(true|false)")?\s*>(.*?)</think>',
        dotAll: true);
    final matches = thinkBlockPattern.allMatches(widget.data).toList();
    _thinkBlockStates = List.generate(matches.length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    // Clear storage
    _tables.clear();
    _latexBlocks.clear();

    // Extract think content
    final thinkContent = _extractThinkContent(widget.data);
    final mainContent = _removeThinkTags(widget.data);

    final widgets = <Widget>[];

    // Add think block if present
    if (widget.data.contains('<think>')) {
      final isComplete = widget.data.contains('</think>');

      while (_thinkBlockStates.isEmpty) {
        _thinkBlockStates.add(false);
      }

      widgets.add(md.ThinkBlock(
        content: thinkContent,
        isComplete: isComplete,
        fontSize: widget.fontSize,
        onToggle: () {
          if (mounted) {
            setState(() {
              _thinkBlockStates[0] = !_thinkBlockStates[0];
            });
          }
        },
        contentWidget: thinkContent.isNotEmpty
            ? _buildMarkdownWithCustomComponents(thinkContent)
            : null,
      ));
    }

    // Add main content ONLY if it's not empty
    if (mainContent.trim().isNotEmpty) {
      widgets.add(_buildMarkdownWithCustomComponents(mainContent));
    }

    return SizedBox(
      width: widget.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: widgets,
      ),
    );
  }

  String _extractThinkContent(String content) {
    // First try to extract complete think block
    final completeMatch = RegExp(
            r'<think(?:\s+complete="(?:true|false)")?\s*>(.*?)</think>',
            dotAll: true)
        .firstMatch(content);
    
    if (completeMatch != null) {
      final extracted = completeMatch.group(1)?.trim() ?? '';
      return extracted;
    }
    
    // If no complete block, try to extract incomplete think block
    final incompleteMatch = RegExp(
            r'<think(?:\s+complete="(?:true|false)")?\s*>(.*?)$',
            dotAll: true)
        .firstMatch(content);
    
    if (incompleteMatch != null) {
      final extracted = incompleteMatch.group(1)?.trim() ?? '';
      return extracted;
    }
    
    return '';
  }

  String _removeThinkTags(String content) {
    String result = content;
    
    // Remove complete think blocks first
    result = result.replaceAll(
        RegExp(r'<think(?:\s+complete="(?:true|false)")?\s*>.*?</think>',
            dotAll: true),
        '');
    
    // Remove incomplete think blocks (everything from <think> to end of string)
    result = result.replaceAll(
        RegExp(r'<think(?:\s+complete="(?:true|false)")?\s*>.*$',
            dotAll: true),
        '');
    
    final trimmed = result.trim();
    return trimmed;
  }

  Widget _buildMarkdownWithCustomComponents(String content) {
    try {
      
      // Replace code blocks, tables, and LaTeX with placeholders
      String processedContent = _processContent(content);
      
      // Find all placeholders
      final tableMatches = RegExp(r'\[CUSTOM_TABLE_(\d+)\]').allMatches(processedContent);
      final latexMatches = RegExp(r'\[CUSTOM_LATEX_(\d+)\]').allMatches(processedContent);

      if (tableMatches.isEmpty && latexMatches.isEmpty) {
        // No custom components, use flutter_md for clean rendering
        return _buildStyledText(processedContent);
      }

      // Build widgets with custom components
      return _buildWithCustomPainters(
          processedContent, tableMatches, latexMatches);
    } catch (e, stackTrace) {
      print('Markdown rendering error: $e');
      print('Stack trace: $stackTrace');
      return _buildFallbackText(content);
    }
  }

  // Build markdown with custom components (code blocks, tables, LaTeX)
  Widget _buildWithCustomPainters(
      String processedContent,
      Iterable<RegExpMatch> tableMatches,
      Iterable<RegExpMatch> latexMatches) {
    final widgets = <Widget>[];
    final allMatches = <_Match>[];

    // Collect all matches (code blocks, tables, LaTeX)
    for (final match in tableMatches) {
      allMatches.add(
          _Match(match.start, match.end, 'table', int.parse(match.group(1)!)));
    }
    for (final match in latexMatches) {
      allMatches.add(
          _Match(match.start, match.end, 'latex', int.parse(match.group(1)!)));
    }

    // Sort by position
    allMatches.sort((a, b) => a.start.compareTo(b.start));

    int currentPos = 0;

    for (final match in allMatches) {
      // Add text before this match
      if (match.start > currentPos) {
        final textBefore = processedContent.substring(currentPos, match.start);
        if (textBefore.trim().isNotEmpty) {
          widgets.add(_buildStyledText(textBefore));
        }
      }

      // Add custom component using flutter_md built-in components
      if (match.type == 'table') {
        final tableData = _tables[match.index];
        if (tableData != null) {
          widgets.add(md.CustomTable(
            markdown: tableData,
            fontSize: widget.fontSize,
          ));
        }
      } else if (match.type == 'latex') {
        final latexData = _latexBlocks[match.index];
        if (latexData != null) {
          widgets.add(md.CustomLatexRenderer(
            content: latexData,
            isDisplay: true,
            style: TextStyle(
              color: widget.mdcolor,
              fontSize: widget.fontSize,
              height: 1.5,
            ),
          ));
        }
      }

      currentPos = match.end;
    }

    // Add remaining text
    if (currentPos < processedContent.length) {
      final textAfter = processedContent.substring(currentPos);
      if (textAfter.trim().isNotEmpty) {
        widgets.add(_buildStyledText(textAfter));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }

  // Main text building method using flutter_md
  Widget _buildStyledText(String content) {
    try {
      
      if (content.trim().isEmpty) {
        return const SizedBox.shrink();
      }
      
      final markdown = md.Markdown.fromString(content);
      
      return md.MarkdownTheme(
        data: md.MarkdownThemeData(
          textStyle: TextStyle(
            color: widget.mdcolor,
            fontSize: widget.fontSize,
            height: 1.5,
          ),
          h1Style: TextStyle(
            color: widget.mdcolor,
            fontSize: widget.fontSize * 1.2,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
          h2Style: TextStyle(
            color: widget.mdcolor,
            fontSize: widget.fontSize * 1.1,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
          h3Style: TextStyle(
            color: widget.mdcolor,
            fontSize: widget.fontSize * 1.05,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
          h4Style: TextStyle(
            color: widget.mdcolor,
            fontSize: widget.fontSize,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
          h5Style: TextStyle(
            color: widget.mdcolor,
            fontSize: widget.fontSize,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
          h6Style: TextStyle(
            color: widget.mdcolor,
            fontSize: widget.fontSize,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
          // Custom inline code is handled in flutter_md
        ),
        child: md.MarkdownWidget(markdown: markdown),
      );
    } catch (e, stackTrace) {
      print('Flutter_md rendering error: $e');
      print('Stack trace: $stackTrace');
      return _buildFallbackText(content);
    }
  }

  String _processContent(String content) {
    int tableCounter = 0;
    int latexCounter = 0; // LaTeX counter only

    // Handle escaped newlines for better table detection
    String processedContent = content.replaceAll('\\n', '\n');

    // Process LaTeX blocks FIRST to protect their content
    
    // Process inline LaTeX display math \[...\] 
    processedContent = processedContent.replaceAllMapped(
      RegExp(r'\\\[(.*?)\\\]', dotAll: true),
      (match) {
        final latexCode = match.group(1)?.trim() ?? '';
        if (latexCode.isEmpty) return match.group(0)!;

        _latexBlocks[latexCounter] = latexCode;
        return '[CUSTOM_LATEX_${latexCounter++}]';
      },
    );

    // Process inline LaTeX display math $$...$$
    processedContent = processedContent.replaceAllMapped(
      RegExp(r'\$\$(.*?)\$\$', dotAll: true),
      (match) {
        final latexCode = match.group(1)?.trim() ?? '';
        if (latexCode.isEmpty) return match.group(0)!;

        _latexBlocks[latexCounter] = latexCode;
        return '[CUSTOM_LATEX_${latexCounter++}]';
      },
    );

    // Process plain bracket math that looks like LaTeX (fallback for common LaTeX patterns)
    processedContent = processedContent.replaceAllMapped(
      RegExp(r'^\s*\[\s*\n(.*?)\n\s*\]\s*$', dotAll: true, multiLine: true),
      (match) {
        final mathContent = match.group(1)?.trim() ?? '';
        if (mathContent.isEmpty) return match.group(0)!;
        
        // Check if this looks like mathematical content
        final mathIndicators = [
          'times', 'cdot', 'div', 'pm', 'mp',
          'sqrt', 'frac', 'sum', 'int', 'prod',
          'alpha', 'beta', 'gamma', 'theta', 'pi',
          'sin', 'cos', 'tan', 'log', 'ln',
          'boxed', 'text', 'mathbf', 'mathit',
          '\\\\', '&', '=', '+', '-', '*', '/', '^', '_',
          r'\d+\s*[+\-*/=]\s*\d+', // Simple arithmetic
        ];
        
        // If content contains math-like patterns, treat it as LaTeX
        if (mathIndicators.any((indicator) => 
            mathContent.contains(indicator) || 
            RegExp(indicator).hasMatch(mathContent))) {
          
          // Convert common plain text math to LaTeX symbols
          String latexContent = mathContent
              .replaceAll(' times ', r' \times ')
              .replaceAll('boxed{', r'\boxed{')
              .replaceAll('sqrt{', r'\sqrt{')
              .replaceAll('frac{', r'\frac{');
          
          _latexBlocks[latexCounter] = latexContent;
          return '[CUSTOM_LATEX_${latexCounter++}]';
        }
        
        return match.group(0)!; // Return original if not math-like
      },
    );

    // Process LaTeX code blocks with ```latex
    processedContent = processedContent.replaceAllMapped(
      RegExp(r'```latex\n?(.*?)\n?```', dotAll: true),
      (match) {
        final latexCode = match.group(1)?.trim() ?? '';
        if (latexCode.isEmpty) return match.group(0)!;

        _latexBlocks[latexCounter] = latexCode;
        return '[CUSTOM_LATEX_${latexCounter++}]';
      },
    );

    // Process incomplete LaTeX blocks (without closing ```)
    processedContent = processedContent.replaceAllMapped(
      RegExp(r'```latex\n?(.*?)$', dotAll: true),
      (match) {
        final latexCode = match.group(1)?.trim() ?? '';

        // Skip if it ends with closing fence (shouldn't happen but safety check)
        if (latexCode.endsWith('```')) return match.group(0)!;

        _latexBlocks[latexCounter] = latexCode;
        return '[CUSTOM_LATEX_${latexCounter++}]';
      },
    );

    // Regular code blocks are now handled by flutter_md - no extraction needed

    // Process tables - completely rewritten approach
    // More comprehensive table pattern that captures complete tables
    final tablePattern = RegExp(r'(\|[^\r\n]*\|(?:\r?\n|\n))+(?:\|[^\r\n]*\|)?',
        multiLine: true);

    final allMatches = <RegExpMatch>[];
    final allMatchesText = <String>[];

    // Find all potential table matches
    for (final match in tablePattern.allMatches(processedContent)) {
      final matchText = match.group(0) ?? '';

      if (matchText.trim().isEmpty) continue;

      // Split into lines to validate
      final lines = matchText.trim().split(RegExp(r'\r?\n'));

      // Must have at least 2 lines (header + data or header + separator + data)
      if (lines.length < 2) {
        continue;
      }

      // All lines must contain pipes
      if (!lines.every((line) => line.contains('|'))) {
        continue;
      }

      allMatches.add(match);
      allMatchesText.add(matchText);
    }

    // Process matches in reverse order to avoid offset issues
    for (int i = allMatches.length - 1; i >= 0; i--) {
      final match = allMatches[i];
      final matchText = allMatchesText[i];

      // Store the table
      _tables[tableCounter] = matchText.trim();

      // Replace the match with placeholder
      processedContent = processedContent.replaceRange(
          match.start, match.end, '[CUSTOM_TABLE_${tableCounter++}]');
    }

    return processedContent;
  }

  Widget _buildFallbackText(String content) {
    
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Markdown Rendering Fallback',
            style: TextStyle(
              color: Colors.red,
              fontSize: widget.fontSize * 0.8,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content.isNotEmpty ? content : 'Empty content',
            style: TextStyle(
              color: widget.mdcolor,
              fontSize: widget.fontSize,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _Match {
  final int start;
  final int end;
  final String type;
  final int index;

  _Match(this.start, this.end, this.type, this.index);
} 