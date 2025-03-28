class RouteInfo {
  final String startAddress;
  final String endAddress;
  final double startLat;
  final double startLng;
  final double endLat;
  final double endLng;
  final String distance;
  final String duration;
  final List<LatLng> polylinePoints;
  final String travelMode;

  RouteInfo({
    required this.startAddress,
    required this.endAddress,
    required this.startLat,
    required this.startLng,
    required this.endLat,
    required this.endLng,
    required this.distance,
    required this.duration,
    required this.polylinePoints,
    required this.travelMode,
  });

  factory RouteInfo.fromJson(Map<String, dynamic> json, String travelMode) {
    final routes = json['routes'] as List;
    if (routes.isEmpty) {
      return RouteInfo(
        startAddress: '',
        endAddress: '',
        startLat: 0.0,
        startLng: 0.0,
        endLat: 0.0,
        endLng: 0.0,
        distance: '',
        duration: '',
        polylinePoints: [],
        travelMode: travelMode,
      );
    }

    final route = routes[0];
    final leg = route['legs'][0];
    final steps = leg['steps'] as List;
    
    List<LatLng> points = [];
    for (var step in steps) {
      final startLocation = step['start_location'];
      final endLocation = step['end_location'];
      
      points.add(LatLng(startLocation['lat'], startLocation['lng']));
      points.add(LatLng(endLocation['lat'], endLocation['lng']));
    }

    return RouteInfo(
      startAddress: leg['start_address'] ?? '',
      endAddress: leg['end_address'] ?? '',
      startLat: leg['start_location']['lat'] ?? 0.0,
      startLng: leg['start_location']['lng'] ?? 0.0,
      endLat: leg['end_location']['lat'] ?? 0.0,
      endLng: leg['end_location']['lng'] ?? 0.0,
      distance: leg['distance']['text'] ?? '',
      duration: leg['duration']['text'] ?? '',
      polylinePoints: points,
      travelMode: travelMode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startAddress': startAddress,
      'endAddress': endAddress,
      'startLat': startLat,
      'startLng': startLng,
      'endLat': endLat,
      'endLng': endLng,
      'distance': distance,
      'duration': duration,
      'polylinePoints': polylinePoints.map((point) => {'lat': point.latitude, 'lng': point.longitude}).toList(),
      'travelMode': travelMode,
    };
  }
}

class LatLng {
  final double latitude;
  final double longitude;

  LatLng(this.latitude, this.longitude);
}
