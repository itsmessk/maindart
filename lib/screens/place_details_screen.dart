import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/place.dart';
import '../providers/places_provider.dart';
import '../providers/routes_provider.dart';
import 'routes_screen.dart';

class PlaceDetailsScreen extends StatefulWidget {
  final Place place;

  const PlaceDetailsScreen({super.key, required this.place});

  @override
  State<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  GoogleMapController? _mapController;
  
  @override
  Widget build(BuildContext context) {
    final placesProvider = Provider.of<PlacesProvider>(context);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with image
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.place.name),
              background: widget.place.imageUrl != null
                  ? Image.network(
                      widget.place.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
            ),
            actions: [
              // Favorite button
              IconButton(
                icon: Icon(
                  widget.place.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: widget.place.isFavorite ? Colors.red : null,
                ),
                onPressed: () {
                  placesProvider.toggleFavorite(widget.place);
                },
              ),
            ],
          ),
          
          // Place details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type and rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Place type
                      if (widget.place.type != null)
                        Chip(
                          label: Text(
                            widget.place.type!.replaceAll('_', ' ').toUpperCase(),
                          ),
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                        ),
                      
                      // Rating
                      if (widget.place.rating != null && widget.place.rating! > 0)
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.place.rating!.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Address
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.place.address,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Get directions button
                  ElevatedButton.icon(
                    onPressed: () {
                      _getDirections();
                    },
                    icon: const Icon(Icons.directions),
                    label: const Text('Get Directions'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Map section title
                  const Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Map
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            widget.place.latitude,
                            widget.place.longitude,
                          ),
                          zoom: 15,
                        ),
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                        markers: {
                          Marker(
                            markerId: MarkerId(widget.place.id),
                            position: LatLng(
                              widget.place.latitude,
                              widget.place.longitude,
                            ),
                            infoWindow: InfoWindow(title: widget.place.name),
                          ),
                        },
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                        myLocationButtonEnabled: false,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Nearby section
                  const Text(
                    'What\'s Nearby',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Nearby buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNearbyButton(
                        icon: Icons.restaurant,
                        label: 'Restaurants',
                        onTap: () => _searchNearby('restaurant'),
                      ),
                      _buildNearbyButton(
                        icon: Icons.hotel,
                        label: 'Hotels',
                        onTap: () => _searchNearby('lodging'),
                      ),
                      _buildNearbyButton(
                        icon: Icons.local_cafe,
                        label: 'Cafes',
                        onTap: () => _searchNearby('cafe'),
                      ),
                      _buildNearbyButton(
                        icon: Icons.shopping_bag,
                        label: 'Shops',
                        onTap: () => _searchNearby('shopping_mall'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNearbyButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
  
  void _getDirections() {
    // Navigate to routes screen
    // In a real app, this would pre-fill the destination
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RoutesScreen(),
      ),
    );
  }
  
  void _searchNearby(String type) async {
    final placesProvider = Provider.of<PlacesProvider>(context, listen: false);
    
    await placesProvider.fetchNearbyPlaces(
      widget.place.latitude,
      widget.place.longitude,
      type: type,
    );
    
    if (context.mounted) {
      // Go back to explore screen
      Navigator.pop(context);
    }
  }
}
