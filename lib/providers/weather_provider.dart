import 'package:flutter/foundation.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  
  Weather? _currentWeather;
  bool _isLoading = false;
  String _error = '';

  Weather? get currentWeather => _currentWeather;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchWeatherByCity(String cityName) async {
    if (cityName.isEmpty) return;
    
    _setLoading(true);
    try {
      _currentWeather = await _weatherService.fetchWeather(cityName);
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load weather data: ${e.toString()}');
    }
  }

  Future<void> fetchWeatherByLocation(double lat, double lng) async {
    _setLoading(true);
    try {
      _currentWeather = await _weatherService.fetchWeatherByLocation(lat, lng);
      _setLoading(false);
    } catch (e) {
      _setError('Failed to load weather data: ${e.toString()}');
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
