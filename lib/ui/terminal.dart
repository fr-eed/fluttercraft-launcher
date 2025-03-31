import 'package:flutter/material.dart';

class TerminalOutput extends StatelessWidget {
  final List<String> lines;
  final Color textColor;
  final double fontSize;
  final bool showCursor;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  const TerminalOutput({
    Key? key,
    this.lines = const [],
    this.textColor = const Color(0xFFE0E0E0),
    this.fontSize = 14.0,
    this.showCursor = false,
    this.padding = const EdgeInsets.all(16.0),
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: borderRadius,
      ),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...lines.map((line) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  line,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontFamily: 'monospace',
                  ),
                ),
              )),
          if (showCursor)
            Row(
              children: [
                Text(
                  '> ',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontFamily: 'monospace',
                  ),
                ),
                _BlinkingCursor(color: textColor, fontSize: fontSize),
              ],
            ),
        ],
      ),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  final Color color;
  final double fontSize;

  const _BlinkingCursor({required this.color, required this.fontSize});

  @override
  _BlinkingCursorState createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 10.0,
        height: 10,
        color: widget.color,
      ),
    );
  }
}
