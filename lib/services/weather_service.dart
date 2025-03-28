import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';
import 'api_keys.dart';

class WeatherService {
  Future<Weather> fetchWeather(String cityName) async {
    final response = await http.get(
      Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=${ApiKeys.openWeatherMapApiKey}')
    );
    
    if (response.statusCode == 200) {
      return Weather.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }
  
  Future<Weather> fetchWeatherByLocation(double lat, double lng) async {
    final response = await http.get(
      Uri.parse('https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lng&appid=${ApiKeys.openWeatherMapApiKey}')
    );
    
    if (response.statusCode == 200) {
      return Weather.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
