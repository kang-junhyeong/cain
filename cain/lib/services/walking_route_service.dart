import 'dart:convert';

import 'package:http/http.dart' as http;

/// 위도·경도 한 점 (지도 SDK에 의존하지 않는 공통 좌표 타입)
class GeoPoint {
  final double latitude;
  final double longitude;

  const GeoPoint(this.latitude, this.longitude);
}

/// 도보 경로 결과
class WalkingRoute {
  /// 경로를 이루는 좌표 목록 (출발 → 도착 순서)
  final List<GeoPoint> points;

  /// 총 거리 (m)
  final int distanceMeters;

  /// 예상 소요 시간 (초)
  final int durationSeconds;

  const WalkingRoute({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });
}

/// 경로 조회 실패 사유
enum WalkingRouteError { missingApiKey, network, noRoute }

class WalkingRouteException implements Exception {
  final WalkingRouteError reason;
  final String? detail;

  const WalkingRouteException(this.reason, [this.detail]);

  @override
  String toString() =>
      'WalkingRouteException($reason${detail != null ? ': $detail' : ''})';
}

/// 도보 경로 제공자.
///
/// 화면은 이 인터페이스만 사용한다. 경로 데이터 출처(TMAP, 추후 Google Routes API 등)를
/// 바꿀 때는 구현체만 교체하면 된다.
abstract class WalkingRouteService {
  Future<WalkingRoute> getRoute({required GeoPoint from, required GeoPoint to});

  /// 현재 사용하는 기본 구현체
  factory WalkingRouteService() => TmapWalkingRouteService();
}

/// TMAP 보행자 경로 API (SK open API) 구현체.
///
/// - 키: `--dart-define-from-file=env.json`의 `TMAP_APP_KEY`
/// - TODO(보안): 정식 배포 시에는 앱에서 직접 호출하지 말고 FastAPI 서버를 경유해 키를 서버에만 둔다.
class TmapWalkingRouteService implements WalkingRouteService {
  static const String _appKey = String.fromEnvironment('TMAP_APP_KEY');
  static const String _endpoint =
      'https://apis.openapi.sk.com/tmap/routes/pedestrian?version=1&format=json';
  static const Duration _timeout = Duration(seconds: 10);

  final http.Client _client;

  TmapWalkingRouteService({http.Client? client})
      : _client = client ?? http.Client();

  @override
  Future<WalkingRoute> getRoute(
      {required GeoPoint from, required GeoPoint to}) async {
    if (_appKey.isEmpty || _appKey.startsWith('여기에')) {
      throw const WalkingRouteException(WalkingRouteError.missingApiKey);
    }

    final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse(_endpoint),
            headers: {
              'appKey': _appKey,
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              // TMAP은 X = 경도, Y = 위도
              'startX': from.longitude.toString(),
              'startY': from.latitude.toString(),
              'endX': to.longitude.toString(),
              'endY': to.latitude.toString(),
              'reqCoordType': 'WGS84GEO',
              'resCoordType': 'WGS84GEO',
              // 출발지·도착지 이름은 필수이며 UTF-8 URL 인코딩 값이어야 한다
              'startName': Uri.encodeComponent('출발'),
              'endName': Uri.encodeComponent('도착'),
            }),
          )
          .timeout(_timeout);
    } catch (e) {
      throw WalkingRouteException(WalkingRouteError.network, e.toString());
    }

    if (response.statusCode != 200) {
      throw WalkingRouteException(
        WalkingRouteError.noRoute,
        'HTTP ${response.statusCode}: ${response.body}',
      );
    }

    return _parse(utf8.decode(response.bodyBytes));
  }

  /// TMAP 응답(GeoJSON FeatureCollection)을 [WalkingRoute]로 변환한다.
  /// - 첫 번째 Point feature의 properties에 totalDistance(m), totalTime(초)가 있다.
  /// - LineString feature들의 좌표를 이어 붙이면 전체 경로가 된다. 좌표는 [경도, 위도] 순서.
  static WalkingRoute _parse(String body) {
    final json = jsonDecode(body) as Map<String, dynamic>;
    final features =
        (json['features'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();

    int? distance;
    int? duration;
    final points = <GeoPoint>[];

    for (final feature in features) {
      final geometry = feature['geometry'] as Map<String, dynamic>?;
      final properties = feature['properties'] as Map<String, dynamic>? ?? {};

      distance ??= (properties['totalDistance'] as num?)?.toInt();
      duration ??= (properties['totalTime'] as num?)?.toInt();

      if (geometry?['type'] == 'LineString') {
        for (final coord in (geometry!['coordinates'] as List<dynamic>)) {
          final c = coord as List<dynamic>;
          final point =
              GeoPoint((c[1] as num).toDouble(), (c[0] as num).toDouble());
          // 구간 경계에서 같은 좌표가 반복되면 건너뛴다
          if (points.isEmpty ||
              points.last.latitude != point.latitude ||
              points.last.longitude != point.longitude) {
            points.add(point);
          }
        }
      }
    }

    if (points.length < 2 || distance == null || duration == null) {
      throw const WalkingRouteException(
          WalkingRouteError.noRoute, 'empty route');
    }

    return WalkingRoute(
        points: points, distanceMeters: distance, durationSeconds: duration);
  }
}
