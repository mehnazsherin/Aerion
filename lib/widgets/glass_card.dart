import 'package:flutter/material.dart';
import '../../core/theme/aerion_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Border? border;
  final Gradient? gradient;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.border,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient != null
            ? null
            : (isDark ? AerionColors.darkCard : AerionColors.lightCard),
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        border: border ??
            Border.all(
              color: isDark ? AerionColors.darkCardBorder : AerionColors.lightCardBorder,
              width: 1.2,
            ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: content,
        ),
      );
    }

    return content;
  }
}
