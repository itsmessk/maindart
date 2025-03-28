import 'package:flutter/foundation.dart';
import '../models/place.dart';
import '../services/places_service.dart';
import '../database/database_helper.dart';

class PlacesProvider with ChangeNotifier {
  final PlacesService _placesService = PlacesService();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  
  List<Place> _nearbyPlaces = [];
  List<Place> _searchResults = [];
  List<Place> _favoritesList = [];
  bool _isLoading = false;
  String _error = '';

  List<Place> get nearbyPlaces => _nearbyPlaces;
  List<Place> get searchResults => _searchResults;
  List<Place> get favoritesList => _favoritesList;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchNearbyPlaces(double lat, double lng, {String type = 'tourist_attraction'}) async {
    _setLoading(true);
    try {
      _nearbyPlaces = await _placesService.fetchNearbyPlaces(lat, lng, type: type);
      _updateFavoriteStatus(_nearbyPlaces);
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load nearby places: ${e.toString()}');
    }
  }

  Future<void> searchPlaces(String query, {double? lat, double? lng}) async {
    if (query.isEmpty) return;
    
    _setLoading(true);
    try {
      _searchResults = await _placesService.searchPlaces(query, lat: lat, lng: lng);
      _updateFavoriteStatus(_searchResults);
      
      // Add to search history
      await _databaseHelper.addSearchQuery(query);
      
      _setLoading(false);
    } catch (e) {
      _setError('Failed to search places: ${e.toString()}');
    }
  }

  Future<void> loadFavorites() async {
    _setLoading(true);
    try {
      _favoritesList = await _databaseHelper.getFavorites();
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load favorites: ${e.toString()}');
    }
  }

  Future<void> toggleFavorite(Place place) async {
    try {
      bool isFav = await _databaseHelper.isFavorite(place.id);
      
      if (isFav) {
        await _databaseHelper.removeFavorite(place.id);
      } else {
        await _databaseHelper.addFavorite(place);
      }
      
      // Update lists
      _updatePlaceInList(_nearbyPlaces, place.id, !isFav);
      _updatePlaceInList(_searchResults, place.id, !isFav);
      await loadFavorites();
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to update favorite: ${e.toString()}');
    }
  }

  Future<List<String>> getSearchHistory() async {
    try {
      return await _databaseHelper.getSearchHistory();
    } catch (e) {
      _setError('Failed to get search history: ${e.toString()}');
      return [];
    }
  }

  Future<void> clearSearchHistory() async {
    try {
      await _databaseHelper.clearSearchHistory();
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear search history: ${e.toString()}');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    _error = '';
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _updateFavoriteStatus(List<Place> places) async {
    for (int i = 0; i < places.length; i++) {
      bool isFav = await _databaseHelper.isFavorite(places[i].id);
      if (isFav) {
        places[i] = places[i].copyWith(isFavorite: true);
      }
    }
    notifyListeners();
  }

  void _updatePlaceInList(List<Place> places, String placeId, bool isFavorite) {
    final index = places.indexWhere((place) => place.id == placeId);
    if (index != -1) {
      places[index] = places[index].copyWith(isFavorite: isFavorite);
    }
  }
}
