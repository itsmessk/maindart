import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../providers/places_provider.dart';
import '../widgets/place_card.dart';
import 'place_details_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  bool _isDarkMode = false;
  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'Spanish', 'French'];
  
  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }
  
  void _loadFavorites() async {
    final placesProvider = Provider.of<PlacesProvider>(context, listen: false);
    await placesProvider.loadFavorites();
  }
  
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    final placesProvider = Provider.of<PlacesProvider>(context);
    final brightness = Theme.of(context).brightness;
    _isDarkMode = brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User profile card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      backgroundImage: user?.photoUrl != null
                          ? NetworkImage(user!.photoUrl!)
                          : null,
                      child: user?.photoUrl == null
                          ? Text(
                              user?.displayName?.substring(0, 1).toUpperCase() ??
                                  user?.email?.substring(0, 1).toUpperCase() ??
                                  'U',
                              style: const TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? 'User',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? 'No email',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Settings section
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Dark mode toggle
            Card(
              child: ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Dark Mode'),
                trailing: Switch(
                  value: _isDarkMode,
                  onChanged: (value) {
                    // In a real app, this would update app theme
                    setState(() {
                      _isDarkMode = value;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Theme settings would be saved in a real app'),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Language selector
            Card(
              child: ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Language'),
                trailing: DropdownButton<String>(
                  value: _selectedLanguage,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedLanguage = newValue;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Language changed to $_selectedLanguage'),
                        ),
                      );
                    }
                  },
                  items: _languages.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            
            // Clear search history
            Card(
              child: ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Clear Search History'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  final placesProvider = Provider.of<PlacesProvider>(context, listen: false);
                  await placesProvider.clearSearchHistory();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Search history cleared')),
                    );
                  }
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Favorites section
            const Text(
              'Favorites',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            placesProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : placesProvider.favoritesList.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('No favorite places yet'),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: placesProvider.favoritesList.length,
                        itemBuilder: (context, index) {
                          final place = placesProvider.favoritesList[index];
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
        ),
      ),
    );
  }
}
