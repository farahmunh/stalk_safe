import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'shield.dart';
import 'setting.dart';
import 'angela.dart';

class Home extends StatefulWidget {
  final LatLng? friendLocation; 

  const Home({this.friendLocation});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GoogleMapController? mapController;
  Position? _currentPosition;

  final LatLng _initialPosition = LatLng(3.254105, 101.729989);
  final Set<Marker> _markers = {};


  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _addFriendMarker();
  }

  Future<void> _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
      _markers.add(
        Marker(
          markerId: MarkerId('current_location'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: InfoWindow(title: 'Your Location'),
        ),
      );
    });

    // Animate the camera to the user's location if mapController is initialized
    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude),
        ),
      );
    }
  }

  void _addFriendMarker() {
    if (widget.friendLocation != null && mapController != null) {
      setState(() {
        _markers.add(
          Marker(
            markerId: MarkerId('friend_location'),
            position: widget.friendLocation!,
            infoWindow: InfoWindow(title: 'Friend\'s Location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          ),
        );
        
        // Animate the camera to the friend's location
        mapController!.animateCamera(CameraUpdate.newLatLng(widget.friendLocation!));
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    
    // Add the friend's location marker after the map controller is initialized
    if (widget.friendLocation != null) {
      _addFriendMarker();
    }

    // If current location exists, animate the camera to it
    if (_currentPosition != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        ),
      );
    }
  }

  void _onBottomNavTapped(int index) {
    if (index == 1) {
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
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 14.0,
            ),
            markers: _markers,
            myLocationEnabled: true,
            // myLocationButtonEnabled: false,
          ),
          Positioned(
            top: 50.0,
            left: 16.0,
            right: 16.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircleButton(Icons.settings, () {
                  showDialog(
                    context: context,
                    builder: (BuildContext content) => SettingsDropdown(),
                  );
                }),
                _buildCircleButton(Icons.chat, () {
                  Navigator.pushNamed(context, '/inbox');
                }),
                _buildCircleButton(Icons.person, () {
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Angela()),
            ).then((_) {
              setState(() {});
            });
          },
          backgroundColor: const Color(0xFF7DAF52),
          shape: const CircleBorder(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, 
            children: [
              Text(
                'ask for',
                style: GoogleFonts.squadaOne(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'ANGELA',
                style: GoogleFonts.squadaOne(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF517E4C), // Fixed full-width coverage
        selectedItemColor: const Color(0xFF7DAF52),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: _onBottomNavTapped,
        selectedLabelStyle: GoogleFonts.inter(fontSize: 12),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
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
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onPressed) {
    return CircleAvatar(
      backgroundColor: Colors.white,
      child: IconButton(
        icon: Icon(
          icon,
          color: const Color(0xFF7DAF52),
        ),
        onPressed: onPressed,
      ),
    );
  }
}