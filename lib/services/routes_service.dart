import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/route.dart';
import 'api_keys.dart';

class RoutesService {
  Future<RouteInfo> fetchRoute(
    double originLat, 
    double originLng, 
    double destinationLat, 
    double destinationLng, 
    {String mode = 'driving'}
  ) async {
    final response = await http.get(
      Uri.parse('https://maps.googleapis.com/maps/api/directions/json?origin=$originLat,$originLng&destination=$destinationLat,$destinationLng&mode=$mode&key=${ApiKeys.googleMapsApiKey}')
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return RouteInfo.fromJson(data, mode);
    } else {
      throw Exception('Failed to load route data');
    }
  }
  
  Future<List<RouteInfo>> fetchMultipleRoutes(
    double originLat, 
    double originLng, 
    double destinationLat, 
    double destinationLng
  ) async {
    List<RouteInfo> routes = [];
    
    // Fetch routes for different travel modes
    final drivingRoute = await fetchRoute(originLat, originLng, destinationLat, destinationLng, mode: 'driving');
    final walkingRoute = await fetchRoute(originLat, originLng, destinationLat, destinationLng, mode: 'walking');
    final transitRoute = await fetchRoute(originLat, originLng, destinationLat, destinationLng, mode: 'transit');
    
    routes.add(drivingRoute);
    routes.add(walkingRoute);
    routes.add(transitRoute);
    
    return routes;
  }
  
  Future<List<Map<String, dynamic>>> fetchPublicTransport(String query) async {
    final response = await http.get(
      Uri.parse('https://transportapi.com/v3/uk/places.json?query=$query&api_key=${ApiKeys.transportApiKey}')
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final places = data['member'] as List;
      return places.map((place) => place as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load transport data');
    }
  }
}
