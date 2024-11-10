import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'shield.dart'; // Import shield.dart

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late GoogleMapController mapController;

  final LatLng _initialPosition = LatLng(3.254105, 101.729989);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onBottomNavTapped(int index) {
    if (index == 1) { // Navigate to ShieldPage on Shield icon tap
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Shield()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Maps Widget
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 14.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),
          // Top icons (setting, chat, inbox)
          Positioned(
            top: 50.0,
            left: 16.0,
            right: 16.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircleButton(Icons.settings, () {
                  // Handle settings button tap
                }),
                _buildCircleButton(Icons.chat, () {
                  // Handle chat button tap
                }),
                _buildCircleButton(Icons.person, () {
                  // Handle profile button tap
                  Navigator.pushNamed(context, '/profile');
                }),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        width: 100,
        height: 100,
        child: FloatingActionButton(
          onPressed: () {
            // Handle Ask for Angela button tap
          },
          backgroundColor: Colors.green,
          shape: CircleBorder(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ask for',
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                'ANGELA',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          currentIndex: 0, // Set default to Location (Home)
          onTap: _onBottomNavTapped,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on),
              label: 'Location',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shield),
              label: 'Shield',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onPressed) {
    return CircleAvatar(
      backgroundColor: Colors.white,
      child: IconButton(
        icon: Icon(icon, color: Colors.green),
        onPressed: onPressed,
      ),
    );
  }
}