import 'dart:collection';

import 'package:flutter/material.dart';

import '../flutter_md.dart';

/// {@template inline_code_style}
/// Style configuration for inline code spans.
/// Allows full customization of inline code appearance including
/// background color, border radius, padding, text color, font size, etc.
/// {@endtemplate}
@immutable
class InlineCodeStyle {
  /// Creates an [InlineCodeStyle] instance.
  /// {@macro inline_code_style}
  const InlineCodeStyle({
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.fontFamily,
    this.borderRadius,
    this.padding,
    this.margin,
    this.border,
  });

  /// Background color of the inline code.
  final Color? backgroundColor;

  /// Text color of the inline code.
  final Color? textColor;

  /// Font size of the inline code.
  final double? fontSize;

  /// Font family of the inline code.
  final String? fontFamily;

  /// Border radius of the inline code background.
  final BorderRadius? borderRadius;

  /// Padding around the inline code text.
  final EdgeInsetsGeometry? padding;

  /// Margin around the inline code container.
  final EdgeInsetsGeometry? margin;

  /// Border around the inline code container.
  final Border? border;

  /// Creates a copy of this style with the given fields replaced by new values.
  InlineCodeStyle copyWith({
    Color? backgroundColor,
    Color? textColor,
    double? fontSize,
    String? fontFamily,
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Border? border,
  }) =>
      InlineCodeStyle(
        backgroundColor: backgroundColor ?? this.backgroundColor,
        textColor: textColor ?? this.textColor,
        fontSize: fontSize ?? this.fontSize,
        fontFamily: fontFamily ?? this.fontFamily,
        borderRadius: borderRadius ?? this.borderRadius,
        padding: padding ?? this.padding,
        margin: margin ?? this.margin,
        border: border ?? this.border,
      );

  /// Creates a default inline code style.
  static const InlineCodeStyle defaultStyle = InlineCodeStyle(
    backgroundColor: Color(0xFF2D2D2D),  // Dark gray background
    textColor: Colors.white,             // White text
    fontFamily: 'monospace',
    borderRadius: BorderRadius.all(Radius.circular(6.0)),  // Rounded corners
    padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),  
    // More padding
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InlineCodeStyle &&
          runtimeType == other.runtimeType &&
          backgroundColor == other.backgroundColor &&
          textColor == other.textColor &&
          fontSize == other.fontSize &&
          fontFamily == other.fontFamily &&
          borderRadius == other.borderRadius &&
          padding == other.padding &&
          margin == other.margin &&
          border == other.border;

  @override
  int get hashCode =>
      backgroundColor.hashCode ^
      textColor.hashCode ^
      fontSize.hashCode ^
      fontFamily.hashCode ^
      borderRadius.hashCode ^
      padding.hashCode ^
      margin.hashCode ^
      border.hashCode;
}

/// {@template markdown_theme_data}
/// Theme data for Markdown widgets.
/// {@endtemplate}
class MarkdownThemeData implements ThemeExtension<MarkdownThemeData> {
  /// Creates a [MarkdownThemeData] instance.
  /// {@macro markdown_theme_data}
  MarkdownThemeData({
    required this.textStyle,
    this.textDirection = TextDirection.ltr,
    this.textScaler = TextScaler.noScaling,
    this.h1Style,
    this.h2Style,
    this.h3Style,
    this.h4Style,
    this.h5Style,
    this.h6Style,
    this.quoteStyle,
    this.inlineCodeStyle,
    this.blockFilter,
    this.spanFilter,
    this.builder,
    this.onLinkTap,
  })  : _headingStyles = List<TextStyle?>.filled(8, null),
        _textStyles = HashMap<int, TextStyle>();

  @override
  Object get type => MarkdownThemeData;

  /// The text direction to use for rendering Markdown widgets.
  final TextDirection textDirection;

  /// The text scaler to use for scaling text in Markdown widgets.
  final TextScaler textScaler;

  /// The default text style to use for Markdown widgets.
  final TextStyle textStyle;

  /// Default text style for headings h1.
  final TextStyle? h1Style;

  /// Default text style for headings h2.
  final TextStyle? h2Style;

  /// Default text style for headings h3.
  final TextStyle? h3Style;

  /// Default text style for headings h4.
  final TextStyle? h4Style;

  /// Default text style for headings h5.
  final TextStyle? h5Style;

  /// Default text style for headings h6.
  final TextStyle? h6Style;

  /// Default text style for quote blocks.
  final TextStyle? quoteStyle;

  /// Style configuration for inline code spans.
  /// Allows full customization of inline code appearance.
  final InlineCodeStyle? inlineCodeStyle;

  /// A filter function to determine whether a block should be rendered.
  /// If the function returns `true`, the block will be rendered.
  ///
  /// For example, you can use this to filter out blocks that are not
  /// relevant to the current context, such as code blocks or tables.
  final bool Function(MD$Block block)? blockFilter;

  /// A filter function to determine whether a span should be rendered.
  /// If the function returns `true`, the span will be rendered.
  ///
  /// For example, you can use this to filter out spans that are not
  /// relevant to the current context, such as links or images.
  /// This can be useful for customizing the rendering of Markdown spans.
  final bool Function(MD$Span span)? spanFilter;

  /// A custom block painter builder function.
  /// It receives a [MD$Block] and returns a [BlockPainter].
  /// If it returns `null`, the default painter will be used.
  /// This allows you to customize the rendering of specific blocks,
  /// such as code blocks, tables, or quote blocks.
  final BlockPainter? Function(
    MD$Block block,
    MarkdownThemeData theme,
  )? builder;

  /// A callback function that is called when a link is tapped.
  /// It receives the link title and URL as parameters.
  final void Function(String title, String url)? onLinkTap;

  final List<TextStyle?> _headingStyles;

  /// Returns a [TextStyle] for the given heading level.
  /// The level should be between 1 and 6, inclusive.
  TextStyle headingStyleFor(int level) =>
      _headingStyles[level] ??= switch (level.clamp(1, 7)) {
        1 => h1Style ??
            textStyle.copyWith(
              fontSize: (textStyle.fontSize ?? 14.0) + 10.0,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.solid,
            ),
        2 => h2Style ??
            textStyle.copyWith(
              fontSize: (textStyle.fontSize ?? 14.0) + 8.0,
              fontWeight: FontWeight.bold,
            ),
        3 => h3Style ??
            textStyle.copyWith(
              fontSize: (textStyle.fontSize ?? 14.0) + 6.0,
              fontWeight: FontWeight.bold,
            ),
        4 => h4Style ??
            textStyle.copyWith(
              fontSize: (textStyle.fontSize ?? 14.0) + 4.0,
              fontWeight: FontWeight.bold,
            ),
        5 => h5Style ??
            textStyle.copyWith(
              fontSize: (textStyle.fontSize ?? 14.0) + 2.0,
              fontWeight: FontWeight.bold,
            ),
        6 => h6Style ??
            textStyle.copyWith(
              fontSize: (textStyle.fontSize ?? 14.0) + 0.0,
              fontWeight: FontWeight.bold,
            ),
        _ => textStyle,
      };

  final HashMap<int, TextStyle> _textStyles;

  /// Returns a [TextStyle] for the given [MD$Style].
  /// For inline code (monospace), uses the custom [inlineCodeStyle] if 
  /// provided.
  TextStyle textStyleFor(MD$Style style) => _textStyles.putIfAbsent(
        style.hashCode,
        () {
          // Handle inline code styling with custom style
          if (style.contains(MD$Style.monospace)) {
            final codeStyle = inlineCodeStyle ?? InlineCodeStyle.defaultStyle;
            return textStyle.copyWith(
              fontFamily: codeStyle.fontFamily,
              color: codeStyle.textColor,
              fontSize: codeStyle.fontSize,
              backgroundColor: codeStyle.backgroundColor,
            );
          }
          
          // Handle other styles as before
          return textStyle.copyWith(
            fontWeight: switch (style) {
              var s when s.contains(MD$Style.bold) => FontWeight.bold,
              var s when s.contains(MD$Style.link) => FontWeight.bold,
              var s when s.contains(MD$Style.highlight) => FontWeight.bold,
              _ => null,
            },
            fontStyle: style.contains(MD$Style.italic) ? 
                FontStyle.italic : null,
            decoration: switch (style) {
              var s when s.contains(MD$Style.underline) =>
                TextDecoration.underline,
              var s when s.contains(MD$Style.strikethrough) =>
                TextDecoration.lineThrough,
              _ => null,
            },
            fontFamily: style.contains(MD$Style.monospace) ? 
                'monospace' : null,
            color: switch (style) {
              var s when s.contains(MD$Style.link) => Colors.indigo,
              var s when s.contains(MD$Style.highlight) => Colors.black,
              var s when s.contains(MD$Style.monospace) => 
                  Colors.white,  // White text for dark background
              _ => null,
            },
            backgroundColor: switch (style) {
              var s when s.contains(MD$Style.highlight) =>
                Colors.deepOrange.withOpacity(0.25),
              var s when s.contains(MD$Style.monospace) =>
                const Color(0xFF2D2D2D),  // Dark background to match default
              _ => null,
            },
          );
        },
      );

  @override
  ThemeExtension<MarkdownThemeData> copyWith({
    TextDirection? textDirection,
    TextScaler? textScaler,
    TextStyle? textStyle,
    TextStyle? h1Style,
    TextStyle? h2Style,
    TextStyle? h3Style,
    TextStyle? h4Style,
    TextStyle? h5Style,
    TextStyle? h6Style,
    TextStyle? quoteStyle,
    InlineCodeStyle? inlineCodeStyle,
    bool Function(MD$Block block)? blockFilter,
    bool Function(MD$Span span)? spanFilter,
  }) =>
      MarkdownThemeData(
        textDirection: textDirection ?? this.textDirection,
        textScaler: textScaler ?? this.textScaler,
        textStyle: textStyle ?? this.textStyle,
        h1Style: h1Style ?? this.h1Style,
        h2Style: h2Style ?? this.h2Style,
        h3Style: h3Style ?? this.h3Style,
        h4Style: h4Style ?? this.h4Style,
        h5Style: h5Style ?? this.h5Style,
        h6Style: h6Style ?? this.h6Style,
        quoteStyle: quoteStyle ?? this.quoteStyle,
        inlineCodeStyle: inlineCodeStyle ?? this.inlineCodeStyle,
        blockFilter: blockFilter ?? this.blockFilter,
        spanFilter: spanFilter ?? this.spanFilter,
      );

  @override
  ThemeExtension<MarkdownThemeData> lerp(
    covariant ThemeExtension<MarkdownThemeData>? other,
    double t,
  ) =>
      other ?? this;

  @override
  String toString() => 'MarkdownThemeData{}';
}

/// {@template theme}
/// MarkdownTheme widget.
/// {@endtemplate}
class MarkdownTheme extends InheritedWidget {
  /// {@macro theme}
  const MarkdownTheme({
    required this.data,
    required super.child,
    super.key, // ignore: unused_element
  });

  /// The state from the closest instance of this class
  /// that encloses the given context, if any.
  /// e.g. `Theme.maybeOf(context)`.
  static MarkdownThemeData? maybeOf(BuildContext context,
          {bool listen = true}) =>
      listen
          ? context.dependOnInheritedWidgetOfExactType<MarkdownTheme>()?.data
          : context.getInheritedWidgetOfExactType<MarkdownTheme>()?.data;

  static Never _notFoundInheritedWidgetOfExactType() => throw ArgumentError(
        'Out of scope, not found inherited widget '
            'a MarkdownTheme of the exact type',
        'out_of_scope',
      );

  /// The state from the closest instance of this class
  /// that encloses the given context.
  /// e.g. `Theme.of(context)`
  static MarkdownThemeData of(BuildContext context, {bool listen = true}) =>
      maybeOf(context, listen: listen) ?? _notFoundInheritedWidgetOfExactType();

  /// The current theme data for Markdown widgets.
  final MarkdownThemeData data;

  @override
  bool updateShouldNotify(covariant MarkdownTheme oldWidget) =>
      !identical(data, oldWidget.data);
}
