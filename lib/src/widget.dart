import 'package:flutter/material.dart';

import 'custom_code_block.dart';
import 'custom_table.dart';
import 'custom_latex_renderer.dart';
import 'markdown.dart';
import 'nodes.dart';
import 'render.dart';
import 'theme.dart';

/// {@template markdown_widget}
/// A widget that displays Markdown content with mixed rendering:
/// - Regular content uses efficient custom painting
/// - Code blocks use interactive widgets with copy/share/expand functionality
/// - Tables use interactive widgets with CSV export and expand functionality
/// - LaTeX content uses interactive widgets with equation rendering
/// {@endtemplate}
class MarkdownWidget extends StatelessWidget {
  /// Creates a [MarkdownWidget].
  /// {@macro markdown_widget}
  const MarkdownWidget({
    super.key,
    required this.markdown,
  });

  /// The markdown document to display.
  final Markdown markdown;

  @override
  Widget build(BuildContext context) {
    if (markdown.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = MarkdownTheme.of(context);
    final filteredBlocks = theme.blockFilter != null 
        ? markdown.blocks.where(theme.blockFilter!).toList() 
        : markdown.blocks;

    // Group consecutive non-interactive blocks together for efficient painting
    final List<Widget> children = [];
    List<MD$Block> paintingGroup = [];

    void flushPaintingGroup() {
      if (paintingGroup.isNotEmpty) {
        children.add(
          _PaintedMarkdownSection(
            blocks: paintingGroup,
            theme: theme,
          ),
        );
        paintingGroup = [];
      }
    }

    for (final block in filteredBlocks) {
      if (block is MD$Code) {
        // Flush any pending painted blocks
        flushPaintingGroup();
        
        // Add interactive code block widget
        children.add(
          CustomCodeBlock(
            code: block.text,
            language: block.language ?? '',
            fontSize: theme.textStyle.fontSize ?? 14.0,
          ),
        );
      } else if (block is MD$Table) {
        // Flush any pending painted blocks
        flushPaintingGroup();
        
        // Add interactive table widget
        children.add(
          CustomTable(
            markdown: _tableToMarkdown(block),
            fontSize: theme.textStyle.fontSize ?? 14.0,
          ),
        );
      } else if (_isLatexBlock(block)) {
        // Flush any pending painted blocks
        flushPaintingGroup();
        
        // Add interactive LaTeX widget
        children.add(
          CustomLatexRenderer(
            content: _extractLatexContent(block),
            isDisplay: true,
            style: theme.textStyle,
          ),
        );
      } else {
        // Add to painting group
        paintingGroup.add(block);
      }
    }

    // Flush any remaining painted blocks
    flushPaintingGroup();

    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    if (children.length == 1) {
      return children.first;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  /// Convert MD$Table to markdown string format
  String _tableToMarkdown(MD$Table table) {
    final buffer = StringBuffer();
    
    // Header row
    buffer.write('|');
    for (var cell in table.header.cells) {
      final cellText = cell.map((span) => span.text).join();
      buffer.write(' $cellText |');
    }
    buffer.writeln();
    
    // Separator row
    buffer.write('|');
    for (var i = 0; i < table.header.cells.length; i++) {
      buffer.write(' --- |');
    }
    buffer.writeln();
    
    // Data rows
    for (var row in table.rows) {
      buffer.write('|');
      for (var i = 0; i < table.header.cells.length; i++) {
        if (i < row.cells.length) {
          final cellText = row.cells[i].map((span) => span.text).join();
          buffer.write(' $cellText |');
        } else {
          buffer.write(' |');
        }
      }
      buffer.writeln();
    }
    
    return buffer.toString();
  }

  /// Check if a block contains LaTeX content
  bool _isLatexBlock(MD$Block block) {
    if (block is MD$Code) {
      // Check for LaTeX language indicators
      final language = block.language?.toLowerCase();
      if (language == 'latex' || language == 'tex') {
        return true;
      }
      
      // Check for LaTeX content patterns
      final text = block.text;
      final latexPatterns = [
        RegExp(r'\\documentclass'),
        RegExp(r'\\begin\{.*?\}'),
        RegExp(r'\\end\{.*?\}'),
        RegExp(r'\\\[.*?\\\]', dotAll: true),
        RegExp(r'\$\$.*?\$\$', dotAll: true),
        RegExp(r'\\[a-zA-Z]+\{.*?\}'),
      ];
      
      return latexPatterns.any((pattern) => pattern.hasMatch(text));
    }
    
    // Check for LaTeX in paragraph blocks
    if (block is MD$Paragraph) {
      final text = block.spans.map((span) => span.text).join();
      return text.contains(RegExp(r'\$\$.*?\$\$', dotAll: true)) ||
             text.contains(RegExp(r'\\\[.*?\\\]', dotAll: true));
    }
    
    return false;
  }

  /// Extract LaTeX content from a block
  String _extractLatexContent(MD$Block block) {
    if (block is MD$Code) {
      return block.text;
    }
    
    if (block is MD$Paragraph) {
      final text = block.spans.map((span) => span.text).join();
      
      // Extract display math $$...$$ or \[...\]
      final displayMathPattern = RegExp(r'\$\$(.*?)\$\$|\\\[(.*?)\\\]', dotAll: true);
      final match = displayMathPattern.firstMatch(text);
      
      if (match != null) {
        return match.group(1) ?? match.group(2) ?? text;
      }
      
      return text;
    }
    
    return '';
  }
}

/// A widget that paints a group of markdown blocks using the efficient painting system
class _PaintedMarkdownSection extends StatelessWidget {
  const _PaintedMarkdownSection({
    required this.blocks,
    required this.theme,
  });

  final List<MD$Block> blocks;
  final MarkdownThemeData theme;

  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty) {
      return const SizedBox.shrink();
    }

    // Create a temporary markdown document with just these blocks
    final tempMarkdown = Markdown(
      markdown: '', // We don't need the original text since we have the blocks
      blocks: blocks,
    );

    return _LegacyMarkdownWidget(markdown: tempMarkdown);
  }
}

/// The original painting-based markdown widget for non-interactive content
class _LegacyMarkdownWidget extends LeafRenderObjectWidget {
  const _LegacyMarkdownWidget({
    required this.markdown,
  });

  final Markdown markdown;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MarkdownRenderObject(
      markdown: markdown,
      theme: MarkdownTheme.of(context),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    MarkdownRenderObject renderObject,
  ) {
    renderObject.update(
      markdown: markdown,
      theme: MarkdownTheme.of(context),
    );
  }
}
