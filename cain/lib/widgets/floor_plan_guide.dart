import 'package:flutter/material.dart';

import '../app_strings.dart';
import '../app_theme.dart';

/// 건물 층별 배치도 위에 현위치 → 목적지 경로를 그려주는 안내 위젯.
///
/// - 대피 안내도처럼 파란 점(현위치)에서 빨간 점(목적지)까지 움직이는 점선으로 길을 보여준다.
/// - [route] 좌표는 배치도 이미지 기준 0~1 비율 (x: 왼→오, y: 위→아래). 첫 점이 현위치, 마지막 점이 목적지.
/// - 배치도를 누르면 전체 화면으로 열려 두 손가락으로 확대할 수 있다.
class FloorPlanGuide extends StatelessWidget {
  final String imagePath;

  /// 배치도 이미지의 가로/세로 비율
  final double aspectRatio;
  final String floorLabel;
  final List<Offset> route;
  final String locale;

  const FloorPlanGuide({
    super.key,
    required this.imagePath,
    required this.aspectRatio,
    required this.floorLabel,
    required this.route,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(locale);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () => _openFullScreen(context),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.divider),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                _PlanWithRoute(imagePath: imagePath, aspectRatio: aspectRatio, route: route),
                // 층 표시
                Positioned(
                  left: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      floorLabel,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.zoom_out_map, size: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 14,
          runSpacing: 6,
          children: [
            _LegendItem(color: _youAreHereColor, label: strings.floorPlanYouAreHere),
            _LegendItem(color: _destinationColor, label: strings.floorPlanKiosk),
            _LegendItem(color: _routeColor, label: strings.floorPlanRoute, isLine: true),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          strings.floorPlanZoomHint,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  void _openFullScreen(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                maxScale: 5,
                child: _PlanWithRoute(imagePath: imagePath, aspectRatio: aspectRatio, route: route),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: SafeArea(
                child: IconButton.filled(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: IconButton.styleFrom(backgroundColor: Colors.white24),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const Color _youAreHereColor = Color(0xFF1E5BD8);
const Color _destinationColor = Color(0xFFE53935);
const Color _routeColor = Color(0xFFE53935);

/// 배치도 이미지 + 애니메이션 경로 오버레이
class _PlanWithRoute extends StatefulWidget {
  final String imagePath;
  final double aspectRatio;
  final List<Offset> route;

  const _PlanWithRoute({required this.imagePath, required this.aspectRatio, required this.route});

  @override
  State<_PlanWithRoute> createState() => _PlanWithRouteState();
}

class _PlanWithRouteState extends State<_PlanWithRoute> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(widget.imagePath, fit: BoxFit.fill),
          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) => CustomPaint(
              painter: _RoutePainter(route: widget.route, progress: _controller.value),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  final List<Offset> route;

  /// 0~1 반복 값 (점선 이동·목적지 깜빡임)
  final double progress;

  _RoutePainter({required this.route, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (route.length < 2) return;
    final unit = size.shortestSide;
    final points = [for (final p in route) Offset(p.dx * size.width, p.dy * size.height)];

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }

    // 경로 바탕선 (흰 테두리로 배치도 위에서도 잘 보이게)
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withOpacity(0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = unit * 0.026
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // 앞으로 흘러가는 점선
    final dash = unit * 0.035;
    final gap = unit * 0.025;
    final period = dash + gap;
    final dashPaint = Paint()
      ..color = _routeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = unit * 0.014
      ..strokeCap = StrokeCap.round;
    for (final metric in path.computeMetrics()) {
      var start = -period + progress * period;
      while (start < metric.length) {
        final s = start.clamp(0.0, metric.length);
        final e = (start + dash).clamp(0.0, metric.length);
        if (e > s) canvas.drawPath(metric.extractPath(s, e), dashPaint);
        start += period;
      }
    }

    // 현위치 (파란 점)
    final origin = points.first;
    canvas.drawCircle(origin, unit * 0.028, Paint()..color = Colors.white);
    canvas.drawCircle(origin, unit * 0.02, Paint()..color = _youAreHereColor);

    // 목적지 (빨간 점 + 퍼지는 원)
    final dest = points.last;
    final pulse = Curves.easeOut.transform(progress);
    canvas.drawCircle(
      dest,
      unit * (0.03 + 0.06 * pulse),
      Paint()..color = _destinationColor.withOpacity(0.45 * (1 - pulse)),
    );
    canvas.drawCircle(dest, unit * 0.032, Paint()..color = Colors.white);
    canvas.drawCircle(dest, unit * 0.024, Paint()..color = _destinationColor);
  }

  @override
  bool shouldRepaint(_RoutePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.route != route;
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isLine;

  const _LegendItem({required this.color, required this.label, this.isLine = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        isLine
            ? Container(width: 16, height: 3, color: color)
            : Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary)),
      ],
    );
  }
}
