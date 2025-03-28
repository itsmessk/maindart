import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/place.dart';
import '../providers/places_provider.dart';

class PlaceCard extends StatelessWidget {
  final Place place;
  final VoidCallback onTap;

  const PlaceCard({
    super.key,
    required this.place,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final placesProvider = Provider.of<PlacesProvider>(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Place image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: place.imageUrl != null
                  ? Image.network(
                      place.imageUrl!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          width: double.infinity,
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
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Place name and favorite button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          place.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          place.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: place.isFavorite ? Colors.red : null,
                        ),
                        onPressed: () {
                          placesProvider.toggleFavorite(place);
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Place address
                  Text(
                    place.address,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Place type and rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Place type
                      if (place.type != null)
                        Chip(
                          label: Text(
                            place.type!.replaceAll('_', ' ').toUpperCase(),
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      
                      // Rating
                      if (place.rating != null && place.rating! > 0)
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              place.rating!.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
