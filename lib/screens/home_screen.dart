import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/places_provider.dart';
import '../providers/weather_provider.dart';
import '../models/place.dart';
import '../models/weather.dart';
import '../widgets/place_card.dart';
import '../widgets/weather_widget.dart';
import 'place_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  Position? _currentPosition;
  
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }
      
      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });
      
      // Fetch weather and nearby places
      if (_currentPosition != null) {
        await _fetchWeatherAndPlaces();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
  
  Future<void> _fetchWeatherAndPlaces() async {
    if (_currentPosition == null) return;
    
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    final placesProvider = Provider.of<PlacesProvider>(context, listen: false);
    
    await weatherProvider.fetchWeatherByLocation(
      _currentPosition!.latitude,
      _currentPosition!.longitude
    );
    
    await placesProvider.fetchNearbyPlaces(
      _currentPosition!.latitude,
      _currentPosition!.longitude
    );
  }
  
  void _handleSearch() async {
    if (_searchController.text.isEmpty) return;
    
    FocusScope.of(context).unfocus();
    
    final placesProvider = Provider.of<PlacesProvider>(context, listen: false);
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    
    // Fetch weather for the searched city
    await weatherProvider.fetchWeatherByCity(_searchController.text);
    
    // Search for places
    await placesProvider.searchPlaces(_searchController.text, 
      lat: _currentPosition?.latitude, 
      lng: _currentPosition?.longitude
    );
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final placesProvider = Provider.of<PlacesProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('TravelMate'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchWeatherAndPlaces,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search for a city or place',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _searchController.clear(),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onSubmitted: (_) => _handleSearch(),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Weather Widget
                      if (weatherProvider.currentWeather != null)
                        WeatherWidget(weather: weatherProvider.currentWeather!),
                      
                      const SizedBox(height: 20),
                      
                      // Popular Places
                      const Text(
                        'Popular Places Nearby',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      if (placesProvider.isLoading)
                        const Center(child: CircularProgressIndicator())
                      else if (placesProvider.error.isNotEmpty)
                        Center(child: Text(placesProvider.error))
                      else if (placesProvider.nearbyPlaces.isEmpty)
                        const Center(
                          child: Text('No places found nearby'),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: placesProvider.nearbyPlaces.length,
                          itemBuilder: (context, index) {
                            final place = placesProvider.nearbyPlaces[index];
                            return PlaceCard(
                              place: place,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlaceDetailsScreen(place: place),
                                ),
                              ),
                            );
                          },
                        ),
                      
                      const SizedBox(height: 20),
                      
                      // Search Results
                      if (placesProvider.searchResults.isNotEmpty) ...[
                        const Text(
                          'Search Results',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        
                        const SizedBox(height: 10),
                        
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: placesProvider.searchResults.length,
                          itemBuilder: (context, index) {
                            final place = placesProvider.searchResults[index];
                            return PlaceCard(
                              place: place,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlaceDetailsScreen(place: place),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
