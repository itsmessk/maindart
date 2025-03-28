import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/routes_provider.dart';
import '../models/route.dart' as app_route;
import '../models/place.dart';
import '../providers/places_provider.dart';

class RoutesScreen extends StatefulWidget {
  const RoutesScreen({super.key});

  @override
  State<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends State<RoutesScreen> {
  GoogleMapController? _mapController;
  Place? _originPlace;
  Place? _destinationPlace;
  int _selectedRouteIndex = 0;
  final List<String> _travelModes = ['Driving', 'Walking', 'Transit'];
  
  @override
  Widget build(BuildContext context) {
    final routesProvider = Provider.of<RoutesProvider>(context);
    final placesProvider = Provider.of<PlacesProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Routes'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Origin and destination selectors
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Origin selector
                InkWell(
                  onTap: () => _selectPlace(true),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _originPlace?.name ?? 'Select origin',
                            style: TextStyle(
                              color: _originPlace != null ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                        if (_originPlace != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _originPlace = null;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Destination selector
                InkWell(
                  onTap: () => _selectPlace(false),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.flag, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _destinationPlace?.name ?? 'Select destination',
                            style: TextStyle(
                              color: _destinationPlace != null ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                        if (_destinationPlace != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _destinationPlace = null;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Get route button
                ElevatedButton(
                  onPressed: (_originPlace != null && _destinationPlace != null)
                      ? _getRoute
                      : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text('Get Route'),
                ),
              ],
            ),
          ),
          
          // Travel mode selector
          if (routesProvider.routes.isNotEmpty)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _travelModes.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_travelModes[index]),
                      selected: _selectedRouteIndex == index,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedRouteIndex = index;
                          });
                          routesProvider.selectRoute(index);
                          _updateMapRoute();
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          
          // Map and route details
          Expanded(
            child: routesProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    children: [
                      // Google Map
                      GoogleMap(
                        initialCameraPosition: const CameraPosition(
                          target: LatLng(0, 0),
                          zoom: 2,
                        ),
                        onMapCreated: (controller) {
                          _mapController = controller;
                          if (_originPlace != null) {
                            _moveToLocation(
                              _originPlace!.latitude,
                              _originPlace!.longitude,
                            );
                          }
                        },
                        markers: _getMarkers(),
                        polylines: _getPolylines(routesProvider),
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        zoomControlsEnabled: true,
                      ),
                      
                      // Route details card
                      if (routesProvider.selectedRoute != null)
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Card(
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${routesProvider.selectedRoute!.distance} (${routesProvider.selectedRoute!.duration})',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'From: ${routesProvider.selectedRoute!.startAddress}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'To: ${routesProvider.selectedRoute!.endAddress}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Travel mode: ${_travelModes[_selectedRouteIndex]}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
  
  void _selectPlace(bool isOrigin) async {
    // In a real app, this would open a place search screen
    // For now, we'll just use the first place from the nearby places list
    final placesProvider = Provider.of<PlacesProvider>(context, listen: false);
    
    if (placesProvider.nearbyPlaces.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No places available. Please search for places first.')),
      );
      return;
    }
    
    // Show a dialog to select a place
    final Place? selectedPlace = await showDialog<Place>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isOrigin ? 'Select Origin' : 'Select Destination'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: placesProvider.nearbyPlaces.length,
            itemBuilder: (context, index) {
              final place = placesProvider.nearbyPlaces[index];
              return ListTile(
                title: Text(place.name),
                subtitle: Text(place.address),
                onTap: () => Navigator.of(context).pop(place),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    
    if (selectedPlace != null) {
      setState(() {
        if (isOrigin) {
          _originPlace = selectedPlace;
        } else {
          _destinationPlace = selectedPlace;
        }
      });
      
      if (_mapController != null) {
        _moveToLocation(
          selectedPlace.latitude,
          selectedPlace.longitude,
        );
      }
    }
  }
  
  void _getRoute() async {
    if (_originPlace == null || _destinationPlace == null) return;
    
    final routesProvider = Provider.of<RoutesProvider>(context, listen: false);
    
    await routesProvider.fetchRoutes(
      _originPlace!.latitude,
      _originPlace!.longitude,
      _destinationPlace!.latitude,
      _destinationPlace!.longitude,
    );
    
    _updateMapRoute();
  }
  
  void _updateMapRoute() {
    if (_mapController == null) return;
    
    final routesProvider = Provider.of<RoutesProvider>(context, listen: false);
    if (routesProvider.selectedRoute == null) return;
    
    // Create bounds that include both origin and destination
    final bounds = LatLngBounds(
      southwest: LatLng(
        routesProvider.selectedRoute!.startLat < routesProvider.selectedRoute!.endLat
            ? routesProvider.selectedRoute!.startLat
            : routesProvider.selectedRoute!.endLat,
        routesProvider.selectedRoute!.startLng < routesProvider.selectedRoute!.endLng
            ? routesProvider.selectedRoute!.startLng
            : routesProvider.selectedRoute!.endLng,
      ),
      northeast: LatLng(
        routesProvider.selectedRoute!.startLat > routesProvider.selectedRoute!.endLat
            ? routesProvider.selectedRoute!.startLat
            : routesProvider.selectedRoute!.endLat,
        routesProvider.selectedRoute!.startLng > routesProvider.selectedRoute!.endLng
            ? routesProvider.selectedRoute!.startLng
            : routesProvider.selectedRoute!.endLng,
      ),
    );
    
    // Add some padding to the bounds
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 100),
    );
  }
  
  void _moveToLocation(double lat, double lng) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(lat, lng),
        14,
      ),
    );
  }
  
  Set<Marker> _getMarkers() {
    final Set<Marker> markers = {};
    
    if (_originPlace != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('origin'),
          position: LatLng(_originPlace!.latitude, _originPlace!.longitude),
          infoWindow: InfoWindow(title: _originPlace!.name),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }
    
    if (_destinationPlace != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(_destinationPlace!.latitude, _destinationPlace!.longitude),
          infoWindow: InfoWindow(title: _destinationPlace!.name),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
    
    return markers;
  }
  
  Set<Polyline> _getPolylines(RoutesProvider routesProvider) {
    final Set<Polyline> polylines = {};
    
    if (routesProvider.selectedRoute != null) {
      final points = routesProvider.selectedRoute!.polylinePoints;
      final List<LatLng> polylineCoordinates = [];
      
      for (var point in points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
      
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: polylineCoordinates,
          color: Colors.blue,
          width: 5,
        ),
      );
    }
    
    return polylines;
  }
}
