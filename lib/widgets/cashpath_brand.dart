import 'package:flutter/material.dart';
import 'package:cashpath_app/theme/app_theme.dart';

class CashPathMark extends StatelessWidget {
  const CashPathMark({super.key, this.size = 44, this.dark = false});

  final double size;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: dark ? AppTheme.lime : AppTheme.forest,
        borderRadius: BorderRadius.circular(size * .31),
      ),
      padding: EdgeInsets.all(size * .19),
      child: CustomPaint(painter: _PathMarkPainter(dark: dark)),
    );
  }
}

class CashPathWordmark extends StatelessWidget {
  const CashPathWordmark({super.key, this.dark = false, this.markSize = 42});

  final bool dark;
  final double markSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CashPathMark(size: markSize, dark: dark),
        const SizedBox(width: 11),
        Text(
          'CashPath',
          style: TextStyle(
            color: dark ? Colors.white : AppTheme.forest,
            fontSize: markSize * .48,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.7,
          ),
        ),
      ],
    );
  }
}

class _PathMarkPainter extends CustomPainter {
  const _PathMarkPainter({required this.dark});
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final color = dark ? AppTheme.forest : AppTheme.lime;
    final pathPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * .12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(size.width * .08, size.height * .78)
      ..lineTo(size.width * .38, size.height * .51)
      ..lineTo(size.width * .57, size.height * .64)
      ..lineTo(size.width * .91, size.height * .22);
    canvas.drawPath(path, pathPaint);
    final arrow = Path()
      ..moveTo(size.width * .58, size.height * .22)
      ..lineTo(size.width * .91, size.height * .22)
      ..lineTo(size.width * .91, size.height * .55);
    canvas.drawPath(arrow, pathPaint);
  }

  @override
  bool shouldRepaint(covariant _PathMarkPainter oldDelegate) =>
      dark != oldDelegate.dark;
}
