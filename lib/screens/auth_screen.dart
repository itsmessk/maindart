import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  
  String _email = '';
  String _password = '';
  String _error = '';
  bool _isLoading = false;
  bool _isLogin = true;
  
  void _toggleView() {
    setState(() {
      _error = '';
      _isLogin = !_isLogin;
    });
  }
  
  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _error = '';
      });
      
      _formKey.currentState!.save();
      
      try {
        if (_isLogin) {
          final result = await _authService.signInWithEmailAndPassword(_email, _password);
          if (result == null) {
            setState(() {
              _error = 'Could not sign in with those credentials';
              _isLoading = false;
            });
          }
        } else {
          final result = await _authService.registerWithEmailAndPassword(_email, _password);
          if (result == null) {
            setState(() {
              _error = 'Please supply a valid email';
              _isLoading = false;
            });
          }
        }
      } catch (e) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Sign In' : 'Register'),
        elevation: 0,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo or icon
              Icon(
                Icons.travel_explore,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
              
              const SizedBox(height: 16),
              
              // App name
              Text(
                'TravelMate',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // App tagline
              const Text(
                'Explore cities and find the best routes',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Email field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                onSaved: (val) => _email = val!,
              ),
              
              const SizedBox(height: 16),
              
              // Password field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (val) => val!.length < 6 ? 'Password must be at least 6 chars long' : null,
                onSaved: (val) => _password = val!,
              ),
              
              const SizedBox(height: 24),
              
              // Error message
              if (_error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _error,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14.0,
                    ),
                  ),
                ),
              
              // Submit button
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: Text(_isLogin ? 'Sign In' : 'Register'),
                    ),
              
              const SizedBox(height: 16),
              
              // Toggle login/register
              TextButton(
                onPressed: _toggleView,
                child: Text(_isLogin ? 'Need an account? Register' : 'Have an account? Sign In'),
              ),
              
              const SizedBox(height: 16),
              
              // Skip authentication for development
              TextButton(
                onPressed: () {
                  // This is just for development purposes
                  // In a real app, you would remove this
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Authentication bypassed for development')),
                  );
                  
                  // Navigate to main screen
                  Navigator.pushReplacementNamed(context, '/');
                },
                child: const Text('Skip for development'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
