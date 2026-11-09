import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../app_theme.dart';
import '../app_strings.dart';
import '../models/building.dart';
import '../services/walking_route_service.dart';

/// 단계 안내 화면에 들어가는 지도.
///
/// - 처음에는 목적지 건물 마커만 표시
/// - 우측 하단 버튼 → 위치 권한 요청 → 허용 시 현재 위치 표시 + 도보 경로(선)·소요 시간 표시
class StepRouteMap extends StatefulWidget {
  final Building building;
  final String locale;
  final WalkingRouteService? routeService;

  const StepRouteMap({
    super.key,
    required this.building,
    required this.locale,
    this.routeService,
  });

  @override
  State<StepRouteMap> createState() => _StepRouteMapState();
}

enum _RouteState { idle, locating, loading, ready, failed }

class _StepRouteMapState extends State<StepRouteMap> {
  static const double _initialZoom = 16.5;

  /// 경로 끝점과 건물 사이가 이보다 멀면 점선으로 이어 준다 (m)
  static const double _lastLegThresholdMeters = 10;

  late final WalkingRouteService _routeService =
      widget.routeService ?? WalkingRouteService();
  GoogleMapController? _controller;

  bool _locationEnabled = false;
  LatLng? _myPosition;
  WalkingRoute? _route;
  _RouteState _state = _RouteState.idle;

  LatLng get _destination =>
      LatLng(widget.building.latitude!, widget.building.longitude!);

  AppStrings get _strings => AppStrings(widget.locale);

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // ───────────────────────── 위치 권한 · 현재 위치 ─────────────────────────

  Future<void> _onMyLocationPressed() async {
    if (_state == _RouteState.locating || _state == _RouteState.loading) return;

    if (!await Geolocator.isLocationServiceEnabled()) {
      _showSnack(_strings.locationServiceOff,
          action: Geolocator.openLocationSettings);
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      _showSnack(_strings.locationPermissionForever,
          action: Geolocator.openAppSettings);
      return;
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.unableToDetermine) {
      _showSnack(_strings.locationPermissionDenied);
      return;
    }

    setState(() {
      _locationEnabled = true;
      _state = _RouteState.locating;
    });

    final Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } catch (e) {
      debugPrint('[StepRouteMap] 현재 위치 조회 실패: $e');
      if (!mounted) return;
      setState(() => _state = _RouteState.failed);
      return;
    }
    if (!mounted) return;

    _myPosition = LatLng(position.latitude, position.longitude);
    await _loadRoute();
  }

  // ───────────────────────── 도보 경로 ─────────────────────────

  Future<void> _loadRoute() async {
    final from = _myPosition;
    if (from == null) return;

    setState(() {
      _state = _RouteState.loading;
      _route = null;
    });

    try {
      final route = await _routeService.getRoute(
        from: GeoPoint(from.latitude, from.longitude),
        to: GeoPoint(_destination.latitude, _destination.longitude),
      );
      if (!mounted) return;
      setState(() {
        _route = route;
        _state = _RouteState.ready;
      });
      _fitCamera([
        for (final p in route.points) LatLng(p.latitude, p.longitude),
        _destination
      ]);
    } on WalkingRouteException catch (e) {
      debugPrint('[StepRouteMap] 도보 경로 조회 실패: $e');
      if (!mounted) return;
      setState(() => _state = _RouteState.failed);
      // 경로가 없어도 내 위치와 건물이 한 화면에 보이도록 맞춘다
      _fitCamera([from, _destination]);
    }
  }

  void _fitCamera(List<LatLng> points) {
    final controller = _controller;
    if (controller == null || points.isEmpty) return;

    var south = points.first.latitude, north = south;
    var west = points.first.longitude, east = west;
    for (final p in points) {
      if (p.latitude < south) south = p.latitude;
      if (p.latitude > north) north = p.latitude;
      if (p.longitude < west) west = p.longitude;
      if (p.longitude > east) east = p.longitude;
    }
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
            southwest: LatLng(south, west), northeast: LatLng(north, east)),
        48,
      ),
    );
  }

  // ───────────────────────── 지도 요소 ─────────────────────────

  Set<Marker> get _markers => {
        Marker(
          markerId: MarkerId('building_${widget.building.id}'),
          position: _destination,
          infoWindow:
              InfoWindow(title: widget.building.name.resolve(widget.locale)),
        ),
      };

  Set<Polyline> get _polylines {
    final route = _route;
    if (route == null) return {};

    final path = [
      for (final p in route.points) LatLng(p.latitude, p.longitude)
    ];
    final lines = <Polyline>{
      Polyline(
        polylineId: const PolylineId('walking_route'),
        points: path,
        color: AppTheme.primary,
        width: 5,
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    };

    // 경로가 건물 앞 도로에서 끝나는 경우, 건물까지 남은 구간을 점선으로 표시
    final end = path.last;
    final gap = Geolocator.distanceBetween(
      end.latitude,
      end.longitude,
      _destination.latitude,
      _destination.longitude,
    );
    if (gap > _lastLegThresholdMeters) {
      lines.add(Polyline(
        polylineId: const PolylineId('walking_route_last_leg'),
        points: [end, _destination],
        color: AppTheme.primary,
        width: 4,
        patterns: [PatternItem.dot, PatternItem.gap(10)],
      ));
    }
    return lines;
  }

  // ───────────────────────── UI ─────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 260,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition:
                      CameraPosition(target: _destination, zoom: _initialZoom),
                  onMapCreated: (c) => _controller = c,
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: _locationEnabled,
                  myLocationButtonEnabled: false, // 기본 버튼 대신 아래 커스텀 버튼 사용
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  // 스크롤 화면 안에서도 지도를 끌어서 움직일 수 있도록
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer()),
                  },
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: FloatingActionButton.small(
                    heroTag: 'step_route_map_my_location',
                    tooltip: _strings.myLocation,
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primary,
                    onPressed: _onMyLocationPressed,
                    child: _state == _RouteState.locating ||
                            _state == _RouteState.loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildStatus(),
      ],
    );
  }

  Widget _buildStatus() {
    final IconData icon;
    final String text;
    Color color = AppTheme.textSecondary;

    switch (_state) {
      case _RouteState.idle:
        icon = Icons.touch_app;
        text = _strings.mapTapMyLocation;
      case _RouteState.locating:
      case _RouteState.loading:
        icon = Icons.directions_walk;
        text = _strings.mapFindingRoute;
      case _RouteState.ready:
        final route = _route!;
        icon = Icons.directions_walk;
        text = _strings.walkingSummary(
            (route.durationSeconds / 60).ceil(), route.distanceMeters);
        color = AppTheme.primary;
      case _RouteState.failed:
        icon = Icons.info_outline;
        text = _strings.routeUnavailable;
        color = AppTheme.warning;
    }

    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: _state == _RouteState.ready
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _showSnack(String message, {Future<bool> Function()? action}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: action == null
            ? null
            : SnackBarAction(
                label: _strings.openSettings, onPressed: () => action()),
      ),
    );
  }
}
