import 'package:flutter/material.dart';

class OutlineCard extends StatelessWidget {
  final Widget child;
  final double elevation;
  final Color color;
  final ShapeBorder? shape;
  final EdgeInsetsGeometry padding;

  const OutlineCard({
    super.key,
    required this.child,
    this.elevation = 0,
    this.color = Colors.transparent,
    this.shape,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      color: color,
      shape: shape ??
          RoundedRectangleBorder(
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(6.0),
          ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
