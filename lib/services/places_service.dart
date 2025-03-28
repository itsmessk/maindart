import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/place.dart';
import 'api_keys.dart';

class PlacesService {
  Future<List<Place>> fetchNearbyPlaces(double lat, double lng, {String type = 'tourist_attraction', int radius = 1500}) async {
    final response = await http.get(
      Uri.parse('https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=$radius&type=$type&key=${ApiKeys.googleMapsApiKey}')
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((place) => Place.fromJson(place)).toList();
    } else {
      throw Exception('Failed to load nearby places');
    }
  }
  
  Future<List<Place>> searchPlaces(String query, {double? lat, double? lng}) async {
    String url;
    if (lat != null && lng != null) {
      url = 'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&location=$lat,$lng&radius=50000&key=${ApiKeys.googleMapsApiKey}';
    } else {
      url = 'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&key=${ApiKeys.googleMapsApiKey}';
    }
    
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List;
      return results.map((place) => Place.fromJson(place)).toList();
    } else {
      throw Exception('Failed to search places');
    }
  }
  
  Future<Place> getPlaceDetails(String placeId) async {
    final response = await http.get(
      Uri.parse('https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=name,rating,formatted_address,geometry,photo,type&key=${ApiKeys.googleMapsApiKey}')
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final result = data['result'];
      return Place.fromJson(result);
    } else {
      throw Exception('Failed to get place details');
    }
  }
}
