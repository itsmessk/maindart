import 'package:flutter/foundation.dart';
import '../models/route.dart';
import '../services/routes_service.dart';

class RoutesProvider with ChangeNotifier {
  final RoutesService _routesService = RoutesService();
  
  List<RouteInfo> _routes = [];
  RouteInfo? _selectedRoute;
  bool _isLoading = false;
  String _error = '';

  List<RouteInfo> get routes => _routes;
  RouteInfo? get selectedRoute => _selectedRoute;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchRoutes(
    double originLat, 
    double originLng, 
    double destinationLat, 
    double destinationLng
  ) async {
    _setLoading(true);
    try {
      _routes = await _routesService.fetchMultipleRoutes(
        originLat, 
        originLng, 
        destinationLat, 
        destinationLng
      );
      
      if (_routes.isNotEmpty) {
        _selectedRoute = _routes[0]; // Default to first route (driving)
      }
      
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load routes: ${e.toString()}');
    }
  }

  Future<void> fetchSingleRoute(
    double originLat, 
    double originLng, 
    double destinationLat, 
    double destinationLng, 
    {String mode = 'driving'}
  ) async {
    _setLoading(true);
    try {
      final route = await _routesService.fetchRoute(
        originLat, 
        originLng, 
        destinationLat, 
        destinationLng, 
        mode: mode
      );
      
      _selectedRoute = route;
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load route: ${e.toString()}');
    }
  }

  void selectRoute(int index) {
    if (index >= 0 && index < _routes.length) {
      _selectedRoute = _routes[index];
      notifyListeners();
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
}
