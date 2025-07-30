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
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Markdown Examples'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'General'),
              Tab(text: 'Inline Code'),
              Tab(text: 'Interactive Code'),
              Tab(text: 'Interactive Tables'),
              Tab(text: 'LaTeX Math'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            HomeScreen(),
            InlineCodeDemoScreen(),
            InteractiveCodeBlockDemoScreen(),
            InteractiveTableDemoScreen(),
            LatexDemoScreen(),
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
              title: 'Default Styling (Modern Dark Theme)',
              style: null, // Use default
              markdown: 'Here is some `default inline code` with the new '
                  'modern dark styling.',
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
              markdown: 'Blue styled `console.log("Hello World");` inline '
                  'code.',
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
              markdown: 'Dark theme `git commit -m "Add inline code styling"` '
                  'with green text.',
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
                textStyle: const TextStyle(
                  fontSize: 16.0, 
                  color: Colors.black87,
                ),
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

## Code Blocks (NEW ADVANCED STYLING!)

Here's a JavaScript code block with the new advanced styling:

```javascript
function greetUser(name, age) {
  // Check if user is old enough
  if (age >= 18) {
    console.log(`Hello ${name}! Welcome to our platform.`);
    return true;
  } else {
    console.log(`Sorry ${name}, you must be 18 or older.`);
    return false;
  }
}

// Usage example
const user = { name: "John", age: 25 };
const isAllowed = greetUser(user.name, user.age);
```

And here's a Python example:

```python
def calculate_fibonacci(n):
    """Calculate the nth Fibonacci number."""
    if n <= 1:
        return n
    
    a, b = 0, 1
    for i in range(2, n + 1):
        a, b = b, a + b
    
    return b

# Generate first 10 Fibonacci numbers
for i in range(10):
    print(f"F({i}) = {calculate_fibonacci(i)}")
```

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

## More Code Examples

Dart code with the new styling:

```dart
class MarkdownWidget extends StatelessWidget {
  const MarkdownWidget({
    Key? key,
    required this.markdown,
  }) : super(key: key);

  final Markdown markdown;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MarkdownPainter(
        markdown: markdown,
        theme: MarkdownTheme.of(context),
      ),
    );
  }
}
```

---

## Inline code

This example is using `package:flutter_md/flutter_md.dart` with enhanced styling.
''';

/// {@template interactive_code_block_demo_screen}
/// Demo screen showing the new interactive code block features.
/// {@endtemplate}
class InteractiveCodeBlockDemoScreen extends StatelessWidget {
  /// {@macro interactive_code_block_demo_screen}
  const InteractiveCodeBlockDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🚀 Interactive Code Blocks',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Code blocks now have full interactive functionality:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              '📋 Copy button with feedback\n'
              '📤 Share as file\n'
              '🔍 Expand to full view\n'
              '🎨 Syntax highlighting\n'
              '🏷️ Language badges',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            
            MarkdownWidget(
              markdown: Markdown.fromString('''
# Interactive Code Blocks Demo

## JavaScript with Full Features
Try the buttons on this code block:

```javascript
// Advanced JavaScript example with multiple features
class MarkdownProcessor {
  constructor(options = {}) {
    this.syntaxHighlighting = options.syntax || true;
    this.interactiveMode = options.interactive || false;
  }

  processCodeBlock(code, language) {
    const features = {
      copy: true,
      share: true,
      expand: true,
      highlight: this.syntaxHighlighting
    };
    
    return {
      processed: this.highlightSyntax(code, language),
      features,
      metadata: {
        language,
        lines: code.split('\\n').length,
        characters: code.length
      }
    };
  }

  highlightSyntax(code, language) {
    // Syntax highlighting implementation
    return code.replace(/\\/\\/(.*)/g, '<comment>\$1</comment>');
  }
}

// Usage example
const processor = new MarkdownProcessor({
  syntax: true,
  interactive: true
});

const result = processor.processCodeBlock(codeString, 'javascript');
console.log('Processed:', result);
```

## Python Data Science Example
This shows syntax highlighting for Python:

```python
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
import matplotlib.pyplot as plt

def analyze_data(dataset_path):
    """
    Comprehensive data analysis pipeline
    """
    # Load and explore data
    df = pd.read_csv(dataset_path)
    print(f"Dataset shape: {df.shape}")
    
    # Feature engineering
    numeric_features = df.select_dtypes(include=[np.number]).columns
    categorical_features = df.select_dtypes(include=['object']).columns
    
    # Handle missing values
    df[numeric_features] = df[numeric_features].fillna(df[numeric_features].median())
    df[categorical_features] = df[categorical_features].fillna('Unknown')
    
    # Model training
    X = df.drop('target', axis=1)
    y = df['target']
    
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )
    
    model = RandomForestClassifier(
        n_estimators=100,
        max_depth=10,
        random_state=42
    )
    
    model.fit(X_train, y_train)
    accuracy = model.score(X_test, y_test)
    
    return {
        'model': model,
        'accuracy': accuracy,
        'features': list(X.columns),
        'data_shape': df.shape
    }

# Run analysis
results = analyze_data('dataset.csv')
print(f"Model accuracy: {results['accuracy']:.2%}")
```

## Dart/Flutter Code
Perfect for Flutter developers:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';

class InteractiveCodeBlock extends StatefulWidget {
  const InteractiveCodeBlock({
    Key? key,
    required this.code,
    required this.language,
  }) : super(key: key);

  final String code;
  final String language;

  @override
  State<InteractiveCodeBlock> createState() => _InteractiveCodeBlockState();
}

class _InteractiveCodeBlockState extends State<InteractiveCodeBlock>
    with TickerProviderStateMixin {
  late AnimationController _copyController;
  late Animation<double> _copyAnimation;
  bool _isCopied = false;

  @override
  void initState() {
    super.initState();
    _copyController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _copyAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _copyController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _copyController.dispose();
    super.dispose();
  }

  void _handleCopy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    setState(() => _isCopied = true);
    _copyController.forward();
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isCopied = false);
        _copyController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildCodeContent(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildLanguageBadge(),
          const Spacer(),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _copyAnimation,
          builder: (context, child) {
            return IconButton(
              onPressed: _handleCopy,
              icon: Icon(
                _isCopied ? Icons.check : Icons.copy,
                color: _isCopied ? Colors.green : Colors.grey,
              ),
            );
          },
        ),
        // More buttons...
      ],
    );
  }
}
```

## Try It Out!
Click the buttons on any code block above to:
- 📋 **Copy** the code to your clipboard
- 📤 **Share** the code as a file
- 🔍 **Expand** to see it in full screen

The syntax highlighting and interactive features make this perfect for documentation, tutorials, and technical content!
              '''),
            ),
          ],
        ),
      ),
    );
  }
}

/// {@template interactive_table_demo_screen}
/// Demo screen showing the new interactive table features.
/// {@endtemplate}
class InteractiveTableDemoScreen extends StatelessWidget {
  /// {@macro interactive_table_demo_screen}
  const InteractiveTableDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Interactive Tables',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tables now have full interactive functionality:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              '📋 Copy table as markdown\n'
              '📤 Export as CSV file\n'
              '🔍 Expand to full view\n'
              '🎨 Professional dark theme\n'
              '📏 Auto-sizing columns',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            
            MarkdownWidget(
              markdown: Markdown.fromString('''
# Interactive Tables Demo

## Simple Data Table
Basic table with interactive features:

| Feature | Status | Priority |
| --- | --- | --- |
| **Copy to Clipboard** | ✅ Complete | High |
| **CSV Export** | ✅ Complete | High |
| **Expand View** | ✅ Complete | Medium |
| **Dark Theme** | ✅ Complete | High |
| **Responsive** | ✅ Complete | Medium |

## Technology Comparison Table
Compare different technologies:

| Technology | **Performance** | **Learning Curve** | **Community** | **Use Case** |
| --- | --- | --- | --- | --- |
| **Flutter** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | Mobile & Web Apps |
| **React Native** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Cross-platform Apps |
| **SwiftUI** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ | iOS Native Apps |
| **Jetpack Compose** | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | Android Native Apps |

## Project Timeline Table
Track project milestones:

| Phase | **Start Date** | **End Date** | **Status** | **Deliverables** |
| --- | --- | --- | --- | --- |
| **Planning** | 2024-01-01 | 2024-01-15 | ✅ Complete | Requirements Doc |
| **Design** | 2024-01-15 | 2024-02-01 | ✅ Complete | UI/UX Mockups |
| **Development** | 2024-02-01 | 2024-03-15 | 🔄 In Progress | Working Prototype |
| **Testing** | 2024-03-15 | 2024-04-01 | ⏳ Pending | QA Report |
| **Deployment** | 2024-04-01 | 2024-04-15 | ⏳ Pending | Live Application |

## Code Samples in Tables
Tables can even contain code blocks:

| Language | **Example** | **Use Case** |
| --- | --- | --- |
| **Dart** | ```flutter<br>Widget build(context) {<br>  return Text('Hello');<br>}``` | Flutter Development |
| **JavaScript** | ```js<br>const hello = () => {<br>  console.log('World');<br>};``` | Web Development |
| **Python** | ```python<br>def greet(name):<br>    return f"Hello {name}!"``` | Data Science |

## Try It Out!
Click the buttons on any table above to:
- 📋 **Copy** the table markdown to your clipboard
- 📤 **Export** as CSV file for spreadsheet applications
- 🔍 **Expand** to see it in full screen mode

Perfect for documentation, data presentation, and technical comparisons!
              '''),
            ),
          ],
        ),
      ),
    );
  }
}

/// {@template latex_demo_screen}
/// Demo screen showing LaTeX mathematical equation rendering.
/// {@endtemplate}
class LatexDemoScreen extends StatelessWidget {
  /// {@macro latex_demo_screen}
  const LatexDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🧮 LaTeX Mathematics',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Mathematical equations with full LaTeX support:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              '📋 Copy LaTeX source code\n'
              '📤 Share as .tex file\n'
              '🔍 Expand to full view\n'
              '⚡ Real-time rendering\n'
              '📖 Document support',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 24),
            
            MarkdownWidget(
              markdown: Markdown.fromString('''
# LaTeX Mathematics Demo

## Simple Math Expressions
Inline math: The quadratic formula is \$x = \\frac{-b \\pm \\sqrt{b^2-4ac}}{2a}\$.

Display math:
\$\$E = mc^2\$\$

## Complex Equations
The Schrödinger equation:

```latex
\\begin{equation}
i\\hbar\\frac{\\partial}{\\partial t}\\Psi(\\mathbf{r},t) = \\hat{H}\\Psi(\\mathbf{r},t)
\\end{equation}
```

## Matrix Operations
Linear algebra expressions:

```latex
\\begin{align}
\\mathbf{A} &= \\begin{pmatrix}
a_{11} & a_{12} & a_{13} \\\\
a_{21} & a_{22} & a_{23} \\\\
a_{31} & a_{32} & a_{33}
\\end{pmatrix} \\\\
\\det(\\mathbf{A}) &= a_{11}(a_{22}a_{33} - a_{23}a_{32}) - a_{12}(a_{21}a_{33} - a_{23}a_{31}) + a_{13}(a_{21}a_{32} - a_{22}a_{31})
\\end{align}
```

## Calculus Examples
Integration and differentiation:

```latex
\\begin{gather}
\\frac{d}{dx}\\left[\\int_a^x f(t)\\,dt\\right] = f(x) \\\\
\\int_0^{\\infty} e^{-x^2} dx = \\frac{\\sqrt{\\pi}}{2} \\\\
\\lim_{n \\to \\infty} \\left(1 + \\frac{1}{n}\\right)^n = e
\\end{gather}
```

## Statistics & Probability
Normal distribution and more:

```latex
\\begin{equation}
f(x) = \\frac{1}{\\sigma\\sqrt{2\\pi}} e^{-\\frac{1}{2}\\left(\\frac{x-\\mu}{\\sigma}\\right)^2}
\\end{equation}
```

## LaTeX Documents
Full document example:

```latex
\\documentclass{article}
\\usepackage{amsmath}
\\usepackage{amsfonts}

\\title{Mathematical Expressions}
\\author{Flutter MD}
\\date{\\today}

\\begin{document}
\\maketitle

\\section{Introduction}
This document demonstrates LaTeX support in Flutter MD.

\\section{Equations}
The famous Euler's identity:
\\begin{equation}
e^{i\\pi} + 1 = 0
\\end{equation}

\\end{document}
```

## Try It Out!
Click the buttons on any LaTeX block above to:
- 📋 **Copy** the LaTeX source code
- 📤 **Share** as .tex file for LaTeX editors
- 🔍 **Expand** to see equations in full screen

Perfect for academic papers, technical documentation, and mathematical content!
              '''),
            ),
          ],
        ),
      ),
    );
  }
}
