import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stalk_safe/shield.dart';
import 'package:stalk_safe/angela.dart';
import 'package:stalk_safe/location_sharing_service.dart';

class Home extends StatefulWidget {
  final String? friendId;
  final String? friendName;

  const Home({this.friendId, this.friendName});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GoogleMapController? mapController;
  final LatLng _initialPosition = LatLng(3.254105, 101.729989);
  final Set<Marker> _markers = {};
  final LocationSharingService _locationService = LocationSharingService();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();

    if (widget.friendId != null) {
      _locationService.listenToFriendLocation(widget.friendId!, (LatLng? friendLocation) {
        if (friendLocation != null) {
          setState(() {
            _markers.removeWhere((marker) => marker.markerId.value == 'friend_location');
            _markers.add(
              Marker(
                markerId: MarkerId('friend_location'),
                position: friendLocation,
                infoWindow: InfoWindow(title: "${widget.friendName}'s Location"),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
              ),
            );
          });
        } else {
          setState(() {
            _markers.removeWhere((marker) => marker.markerId.value == 'friend_location');
          });
        }
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _markers.add(
          Marker(
            markerId: MarkerId('current_location'),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: InfoWindow(title: 'Your Location'),
          ),
        );
      });

      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      }
    } catch (e) {
      print("Error getting current location: $e");
    }
  }

  @override
  void dispose() {
    _locationService.stopFriendLocationListener();
    super.dispose();
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
            onMapCreated:(controller) => mapController = controller,
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 14.0,
            ),
            markers: _markers,
            myLocationEnabled: true,
          ),
          Positioned(
            top: 70.0,
            left: 20.0,
            right: 20.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircleButton(Icons.person, () {
                  Navigator.pushNamed(context, '/profile');
                }),
                _buildCircleButton(Icons.chat, () {
                  Navigator.pushNamed(context, '/inbox');
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
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color.fromARGB(52, 0, 0, 0),
            blurRadius: 5,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child:CircleAvatar(
        radius: 22,
        backgroundColor: Colors.white,
        child: IconButton(
          iconSize: 26,
          icon: Icon(
            icon,
            color: const Color(0xFF7DAF52),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}