import 'package:flutter/widgets.dart';

/// Marka logo DanaPintar (panah pertumbuhan + percikan) digambar secara
/// vektor agar tajam di segala ukuran & bisa diberi efek 3D / gradien.
class LogoMark extends StatelessWidget {
  final double size;
  const LogoMark({super.key, this.size = 160});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _LogoMarkPainter());
  }
}

class _LogoMarkPainter extends CustomPainter {
  // Warna merek.
  static const _hijauTerang = Color(0xFF86EFAC);
  static const _hijau = Color(0xFF4ADE80);
  static const _hijauTua = Color(0xFF16A34A);

  // Titik garis dalam ruang 1024 (sama dgn ikon aplikasi).
  static const _pts = <Offset>[
    Offset(300, 690),
    Offset(440, 560),
    Offset(560, 620),
    Offset(715, 360),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // Petakan ruang-1024 → kanvas, pusatkan marka dgn sedikit padding.
    const cx = 542.0, cy = 501.0, span = 555.0;
    final k = size.width * 0.9 / span;
    Offset m(Offset p) => Offset(
      size.width / 2 + (p.dx - cx) * k,
      size.height / 2 + (p.dy - cy) * k,
    );

    final pts = _pts.map(m).toList();
    final markRect = Rect.fromLTRB(
      0,
      size.height * 0.06,
      size.width,
      size.height * 0.94,
    );
    final shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [_hijauTerang, _hijau, _hijauTua],
      stops: [0.0, 0.5, 1.0],
    ).createShader(markRect);

    // Garis pertumbuhan (stroke gradien).
    final stroke = Paint()
      ..shader = shader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 78 * k
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, stroke);

    // Kepala panah di ujung.
    final p2 = pts[2], p3 = pts[3];
    final dir = (p3 - p2);
    final len = dir.distance;
    final u = Offset(dir.dx / len, dir.dy / len);
    final perp = Offset(-u.dy, u.dx);
    final tip = p3 + u * (95 * k);
    final back = p3 - u * (26 * k);
    final b1 = back + perp * (112 * k);
    final b2 = back - perp * (112 * k);
    final fill = Paint()
      ..shader = shader
      ..style = PaintingStyle.fill;
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(b1.dx, b1.dy)
        ..lineTo(b2.dx, b2.dy)
        ..close(),
      fill,
    );

    // Percikan (sparkle) — kilau cerdas.
    final spark = Paint()..color = _hijauTerang;
    _sparkle(canvas, m(const Offset(372, 400)), 78 * k, spark);
    _sparkle(canvas, m(const Offset(812, 300)), 42 * k, spark);
  }

  void _sparkle(Canvas c, Offset o, double r, Paint p) {
    final s = r * 0.32;
    c.drawPath(
      Path()
        ..moveTo(o.dx, o.dy - r)
        ..lineTo(o.dx + s, o.dy - s)
        ..lineTo(o.dx + r, o.dy)
        ..lineTo(o.dx + s, o.dy + s)
        ..lineTo(o.dx, o.dy + r)
        ..lineTo(o.dx - s, o.dy + s)
        ..lineTo(o.dx - r, o.dy)
        ..lineTo(o.dx - s, o.dy - s)
        ..close(),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
