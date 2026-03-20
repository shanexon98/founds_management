import 'package:flutter/material.dart';

class BankBackground extends StatelessWidget {
  final Widget child;
  const BankBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    scheme.primary.withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: -40,
          right: -40,
          child: _Blob(
            size: 280,
            colors: [
              scheme.primary.withValues(alpha: 0.18),
              scheme.primaryContainer.withValues(alpha: 0.12),
            ],
          ),
        ),
        Positioned(
          bottom: -60,
          left: -60,
          child: _Blob(
            size: 320,
            colors: [
              scheme.secondary.withValues(alpha: 0.16),
              scheme.secondaryContainer.withValues(alpha: 0.1),
            ],
          ),
        ),
        Positioned(
          top: 140,
          right: -100,
          child: _Blob(
            size: 200,
            colors: [
              scheme.tertiary.withValues(alpha: 0.12),
              scheme.tertiaryContainer.withValues(alpha: 0.08),
            ],
          ),
        ),
        child,
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final List<Color> colors;
  const _Blob({required this.size, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: colors,
          stops: const [0.2, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.22),
            blurRadius: 36,
            spreadRadius: 4,
            offset: const Offset(0, 12),
          ),
        ],
      ),
    );
  }
}
