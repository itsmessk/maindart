import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/places_provider.dart';
import '../models/place.dart';
import '../widgets/place_card.dart';
import 'place_details_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _selectedFilter = 'tourist_attraction';
  final List<Map<String, dynamic>> _filters = [
    {'name': 'Attractions', 'value': 'tourist_attraction', 'icon': Icons.attractions},
    {'name': 'Restaurants', 'value': 'restaurant', 'icon': Icons.restaurant},
    {'name': 'Hotels', 'value': 'lodging', 'icon': Icons.hotel},
    {'name': 'Museums', 'value': 'museum', 'icon': Icons.museum},
    {'name': 'Parks', 'value': 'park', 'icon': Icons.park},
    {'name': 'Shopping', 'value': 'shopping_mall', 'icon': Icons.shopping_bag},
  ];

  @override
  Widget build(BuildContext context) {
    final placesProvider = Provider.of<PlacesProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = filter['value'] == _selectedFilter;
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          filter['icon'] as IconData,
                          size: 18,
                          color: isSelected ? Colors.white : null,
                        ),
                        const SizedBox(width: 4),
                        Text(filter['name'] as String),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter['value'] as String;
                      });
                      
                      // Fetch places with new filter
                      _fetchPlacesWithFilter();
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Theme.of(context).colorScheme.primary,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Places list
          Expanded(
            child: placesProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : placesProvider.nearbyPlaces.isEmpty
                    ? const Center(child: Text('No places found'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
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
          ),
        ],
      ),
    );
  }
  
  void _fetchPlacesWithFilter() async {
    final placesProvider = Provider.of<PlacesProvider>(context, listen: false);
    
    // Get current position from the provider or use a default location
    double lat = 0.0;
    double lng = 0.0;
    
    // If we have nearby places already, use the location of the first one
    if (placesProvider.nearbyPlaces.isNotEmpty) {
      lat = placesProvider.nearbyPlaces.first.latitude;
      lng = placesProvider.nearbyPlaces.first.longitude;
    }
    
    await placesProvider.fetchNearbyPlaces(lat, lng, type: _selectedFilter);
  }
}
