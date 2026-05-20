import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../core/theme/app_colors.dart';

/// 静态轨迹缩略图组件
///
/// 高德瓦片底图 + CustomPainter 绘制路径，性能最优。
/// 非交互，适合分享卡片等导出场景。
class StaticRouteThumbnail extends StatelessWidget {
  final List<LatLng> points;
  final double? width;
  final double? height;

  const StaticRouteThumbnail({
    super.key,
    required this.points,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return _buildEmpty(context);
    }

    final center = _calcCenter();
    final zoom = _calcZoom();

    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: Stack(
        children: [
          // 底层：高德瓦片底图
          FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: zoom,
              maxZoom: 18,
              minZoom: 3,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.none,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://webrd0{s}.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}',
                subdomains: const ['1', '2', '3', '4'],
              ),
            ],
          ),
          // 上层：CustomPainter 绘制路径 + 标记
          Positioned.fill(
            child: CustomPaint(
              painter: _RoutePainter(
                points: points,
                center: center,
                zoom: zoom,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4F8),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  LatLng _calcCenter() {
    double lat = 0, lng = 0;
    for (final p in points) {
      lat += p.latitude;
      lng += p.longitude;
    }
    return LatLng(lat / points.length, lng / points.length);
  }

  double _calcZoom() {
    if (points.length < 2) return 14;
    double minLat = points[0].latitude, maxLat = points[0].latitude;
    double minLng = points[0].longitude, maxLng = points[0].longitude;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    final maxDiff = math.max(maxLat - minLat, maxLng - minLng);
    // 整体降低 zoom 级别，显示更大范围
    if (maxDiff < 0.002) return 15;
    if (maxDiff < 0.005) return 14;
    if (maxDiff < 0.01) return 13;
    if (maxDiff < 0.03) return 12;
    if (maxDiff < 0.08) return 11;
    return 10;
  }
}

/// CustomPainter 绘制轨迹路径 + 起终点标记
///
/// 直接将经纬度换算到画布像素坐标，不依赖 flutter_map 的投影。
/// 通过 FlutterMap 的 initialCenter/initialZoom 确定地图渲染位置，
/// 然后本 painter 用同一算法绘制路径覆盖在瓦片之上。
class _RoutePainter extends CustomPainter {
  final List<LatLng> points;
  final LatLng center;
  final double zoom;

  _RoutePainter({
    required this.points,
    required this.center,
    required this.zoom,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    if (points.length < 2) return;

    // 计算边界框
    double minLat = points[0].latitude, maxLat = points[0].latitude;
    double minLng = points[0].longitude, maxLng = points[0].longitude;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    final latRange = math.max(maxLat - minLat, 1e-6);
    final lngRange = math.max(maxLng - minLng, 1e-6);

    // 保持宽高比，留内边距
    final padRatio = 0.88;
    final scaleX = size.width / lngRange * padRatio;
    final scaleY = size.height / latRange * padRatio;
    final scale = math.min(scaleX, scaleY);

    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;

    // 转换为画布坐标
    final pts = points.map((p) {
      final x = (p.longitude - centerLng) * scale + size.width / 2;
      final y = (centerLat - p.latitude) * scale + size.height / 2;
      return Offset(x.toDouble(), y.toDouble());
    }).toList();

    // 绘制路径外发光
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 6
      ..color = const Color(0xFF4CAF50).withOpacity(0.2);
    canvas.drawPath(_buildPath(pts), glowPaint);

    // 绘制主路径
    final pathPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3
      ..color = AppColors.primary;
    canvas.drawPath(_buildPath(pts), pathPaint);

    // 绘制起终点标记
    _drawDot(canvas, pts.first, AppColors.primaryDark);
    if (pts.length > 1 && (pts.first - pts.last).distance > 2) {
      _drawDot(canvas, pts.last, AppColors.danger400);
    }
  }

  ui.Path _buildPath(List<Offset> pts) {
    final path = ui.Path();
    path.moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) {
      if (i < pts.length - 1) {
        final prev = pts[i - 1], curr = pts[i], next = pts[i + 1];
        path.quadraticBezierTo(
          (prev.dx + curr.dx) / 2, (prev.dy + curr.dy) / 2,
          (curr.dx + next.dx) / 2, (curr.dy + next.dy) / 2,
        );
      } else {
        path.lineTo(pts[i].dx, pts[i].dy);
      }
    }
    return path;
  }

  void _drawDot(Canvas canvas, Offset c, Color color) {
    canvas.drawCircle(c, 6, Paint()..color = Colors.white);
    canvas.drawCircle(c, 4, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.center != center ||
        oldDelegate.zoom != zoom;
  }
}