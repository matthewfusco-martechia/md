// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_md/flutter_md.dart';

void main() => runZonedGuarded<void>(
      () => runApp(const App()),
      (e, s) => print(e),
    );

/// {@template app}
/// App widget.
/// {@endtemplate}
class App extends StatelessWidget {
  /// {@macro app}
  const App({super.key});

  /// Light theme for the app.
  static final ThemeData theme = ThemeData.light();

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Markdown',
        themeMode: ThemeMode.light,
        theme: theme,
        darkTheme: theme,
        home: const MainTabView(),
        builder: (context, child) => MarkdownTheme(
          data: MarkdownThemeData(
            textStyle: const TextStyle(fontSize: 14.0, color: Colors.black),
            textDirection: TextDirection.ltr,
            textScaler: TextScaler.noScaling,
            // Exclude images from the markdown rendering,
            // so they are not rendered in the output.
            // Because image spans are not supported yet.
            spanFilter: (span) => !span.style.contains(MD$Style.image),
            onLinkTap: (title, url) {
              ScaffoldMessenger.maybeOf(context)
                ?..clearSnackBars()
                ..showSnackBar(
                  SnackBar(
                    content: Text('Link "$title" tapped: $url'),
                    duration: const Duration(seconds: 2),
                  ),
                );
            },
          ),
          child: child!,
        ),
      );
}

/// {@template main_tab_view}
/// Main tab view widget showing different markdown examples.
/// {@endtemplate}
class MainTabView extends StatelessWidget {
  /// {@macro main_tab_view}
  const MainTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Markdown Examples'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'General'),
              Tab(text: 'Inline Code Styling'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            HomeScreen(),
            InlineCodeDemoScreen(),
          ],
        ),
      ),
    );
  }
}

/// {@template inline_code_demo_screen}
/// Demo screen showing customizable inline code styling.
/// {@endtemplate}
class InlineCodeDemoScreen extends StatelessWidget {
  /// {@macro inline_code_demo_screen}
  const InlineCodeDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Default styling example
            _buildStyledExample(
              title: 'Default Styling',
              style: null, // Use default
              markdown: 'Here is some `default inline code` with standard styling.',
            ),
            const SizedBox(height: 24),
            
            // Blue background example
            _buildStyledExample(
              title: 'Blue Background',
              style: const InlineCodeStyle(
                backgroundColor: Color(0xFFE3F2FD),
                textColor: Color(0xFF1565C0),
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
                padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
              ),
              markdown: 'Blue styled `console.log("Hello World");` inline code.',
            ),
            const SizedBox(height: 24),
            
            // Green background example  
            _buildStyledExample(
              title: 'Green Success Theme',
              style: const InlineCodeStyle(
                backgroundColor: Color(0xFFE8F5E8),
                textColor: Color(0xFF2E7D32),
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                border: Border.fromBorderSide(
                  BorderSide(color: Color(0xFF4CAF50), width: 1.0)),
              ),
              markdown: 'Success theme `npm install flutter_md` with border.',
            ),
            const SizedBox(height: 24),
            
            // Orange warning theme
            _buildStyledExample(
              title: 'Orange Warning Theme',
              style: const InlineCodeStyle(
                backgroundColor: Color(0xFFFFF3E0),
                textColor: Color(0xFFE65100),
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                fontSize: 15.0,
              ),
              markdown: 'Warning styled `import "package:flutter_md/flutter_md.dart";` code.',
            ),
            const SizedBox(height: 24),
            
            // Dark theme example
            _buildStyledExample(
              title: 'Dark Theme',
              style: const InlineCodeStyle(
                backgroundColor: Color(0xFF2D2D2D),
                textColor: Color(0xFF00FF00),
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
                padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
                fontFamily: 'Courier New',
                fontSize: 14.0,
              ),
              markdown: 'Dark theme `git commit -m "Add inline code styling"` with green text.',
            ),
            const SizedBox(height: 24),
            
            // Pill shape example
            _buildStyledExample(
              title: 'Pill Shape',
              style: const InlineCodeStyle(
                backgroundColor: Color(0xFFF3E5F5),
                textColor: Color(0xFF7B1FA2),
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              ),
              markdown: 'Pill shaped `rounded.corners = true` inline code.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledExample({
    required String title,
    required InlineCodeStyle? style,  
    required String markdown,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            MarkdownTheme(
              data: MarkdownThemeData(
                textStyle: const TextStyle(fontSize: 16.0, color: Colors.black87),
                inlineCodeStyle: style,
                spanFilter: (span) => !span.style.contains(MD$Style.image),
              ),
              child: MarkdownWidget(
                markdown: Markdown.fromString(markdown),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// {@template home_screen}
/// HomeScreen widget.
/// {@endtemplate}
class HomeScreen extends StatefulWidget {
  /// {@macro home_screen}
  const HomeScreen({
    super.key, // ignore: unused_element
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// State for widget HomeScreen.
class _HomeScreenState extends State<HomeScreen> {
  final MultiChildLayoutDelegate _layoutDelegate = _HomeScreenLayoutDelegate();
  final TextEditingController _inputController =
      TextEditingController(text: _markdownExample);
  final ValueNotifier<Markdown> _outputController =
      ValueNotifier<Markdown>(const Markdown.empty());

  @override
  void initState() {
    super.initState();
    final initialMarkdown = Markdown.fromString(_inputController.text);
    _outputController.value = initialMarkdown;
    _inputController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    super.dispose();
    _inputController.dispose();
    _outputController.dispose();
  }

  void _onInputChanged() {
    // Handle input changes
    final text = _inputController.text;
    if (text.isEmpty && _outputController.value.isNotEmpty) {
      _outputController.value = const Markdown.empty();
    } else if (text == _outputController.value.markdown) {
      return; // No change, no need to update
    } else {
      final markdown = Markdown.fromString(text);
      _outputController.value = markdown;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Markdown'),
        ),
        body: SafeArea(
          child: CustomMultiChildLayout(
            delegate: _layoutDelegate,
            children: <Widget>[
              LayoutId(
                id: 0,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        Positioned.fill(
                          child: TextField(
                            controller: _inputController,
                            expands: true,
                            maxLines: null,
                            minLines: null,
                            keyboardType: TextInputType.multiline,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: '____________________________________\n'
                                  '______________________________\n'
                                  '__________________________\n'
                                  '______________________________\n'
                                  '____________________________________\n'
                                  '________________________\n'
                                  '________________________________________\n'
                                  '______________________________\n'
                                  '________________________\n'
                                  '__________________________________________\n'
                                  '______________________________\n',
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                IconButton.filledTonal(
                                  icon: const Icon(
                                    Icons.refresh,
                                  ),
                                  onPressed: () =>
                                      _inputController.text = _markdownExample,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              LayoutId(
                id: 1,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Card(
                    child: SingleChildScrollView(
                      primary: false,
                      padding: const EdgeInsets.all(8.0),
                      child: ValueListenableBuilder(
                        valueListenable: _outputController,
                        builder: (context, value, child) => MarkdownWidget(
                          markdown: value,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _HomeScreenLayoutDelegate extends MultiChildLayoutDelegate {
  _HomeScreenLayoutDelegate();

  @override
  void performLayout(Size size) {
    if (size.width >= size.height) {
      final width = size.width / 2;
      final constraints =
          BoxConstraints.tightFor(width: width, height: size.height);
      layoutChild(0, constraints);
      layoutChild(1, constraints);
      positionChild(0, Offset.zero);
      positionChild(1, Offset(width, 0));
    } else {
      final height = size.height / 2;
      final constraints =
          BoxConstraints.tightFor(width: size.width, height: height);
      layoutChild(0, constraints);
      layoutChild(1, constraints);
      positionChild(0, Offset.zero);
      positionChild(1, Offset(0, height));
    }
  }

  @override
  bool shouldRelayout(covariant _HomeScreenLayoutDelegate oldDelegate) => false;
}

const String _markdownExample = r'''
# Markdown syntax guide

## Headers

# This is a Heading h1
## This is a Heading h2
### This is a Heading h3
#### This is a Heading h4
##### This is a Heading h5
###### This is a Heading h6

---

## Emphasis

*This text will be italic*
_This will also be italic_

**This text will be bold**

__This will be underline__

`This is inline code`

~~This text will be strikethrough~~

==This text will be highlighted==

_`You` **can** __combine__ ~~them~~_

---

## Paragraphs

  **Lorem ipsum** dolor sit amet, consectetur adipiscing elit.
Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
Ut enim ad minim veniam, quis ~~nostrud exercitation~~ ullamco laboris nisi ut aliquip ex ea commodo consequat.
Duis aute irure dolor in _reprehenderit in voluptate velit esse_ cillum dolore eu fugiat nulla pariatur.
**Excepteur sint occaecat cupidatat non proident**, sunt in culpa qui __officia deserunt mollit__ anim id `est laborum`.

---

## Lists

### Unordered

* Item 1
* Item 2
* Item 2a
* Item 2b
    * Item 3a
    * Item 3b

### Ordered

1. Item **1**
2. Item **2**
3. Item **3**
    1. Item **3a** with [link](https://example.com)
    2. Item **3b**

---

## Links

You may be using [Markdown Live Preview](https://markdownlivepreview.com/).

---

## Blockquotes

> Markdown is a lightweight markup language with plain-text-formatting syntax, created in 2004 by John Gruber with Aaron Swartz.
>
> Markdown is often used to format readme files, for writing messages in online discussion forums, and to create rich text using a plain text editor.

---

## Tables

| Left columns  | Right columns |
| ------------- |:-------------:|
| left foo      | right foo     |
| left bar      | right bar     |
| left baz      | right baz     |

---

## Blocks of code

```
let message = 'Hello world';
alert(message);
```

---

## Inline code

This example is using `package:flutter_md/flutter_md.dart`.
''';
