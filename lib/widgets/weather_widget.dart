import 'package:flutter/material.dart';
import '../models/weather.dart';

class WeatherWidget extends StatelessWidget {
  final Weather weather;

  const WeatherWidget({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade300,
              Colors.blue.shade700,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weather.cityName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      weather.description.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Image.network(
                      weather.iconUrl,
                      width: 60,
                      height: 60,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.cloud,
                          size: 60,
                          color: Colors.white,
                        );
                      },
                    ),
                    Text(
                      '${weather.temperature.toStringAsFixed(1)}°C',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildWeatherDetail(
                  context,
                  Icons.water_drop,
                  'Humidity',
                  '${weather.humidity}%',
                ),
                _buildWeatherDetail(
                  context,
                  Icons.air,
                  'Wind',
                  '${weather.windSpeed} m/s',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
