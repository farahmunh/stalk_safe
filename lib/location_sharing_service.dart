import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationSharingService {
  static final LocationSharingService _instance = LocationSharingService._internal();
  factory LocationSharingService() => _instance;

  LocationSharingService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<Position>? _locationSubscription;
  StreamSubscription<DocumentSnapshot>? _friendLocationSubscription;
  bool isSharingLocation = false;
  String? currentRecipientId;
  LatLng? friendLocation;

  /// Starts sharing location, optionally with a specific recipient.
  Future<void> startSharingLocation({String? recipientId}) async {
    if (isSharingLocation && currentRecipientId == recipientId) return;

    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    isSharingLocation = true;
    currentRecipientId = recipientId;

    final updateData = {
      'isSharingLocation': true,
      if (recipientId != null) 'specificRecipientId': recipientId,
    };

    await _firestore.collection('users').doc(currentUser.uid).update(updateData);

    _locationSubscription?.cancel();
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).listen((position) async {
      await _firestore.collection('users').doc(currentUser.uid).update({
        'location': {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
      });
    });
  }

  Future<void> stopSharingLocation() async {
    if (!isSharingLocation) return;

    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    isSharingLocation = false;
    currentRecipientId = null;

    await _firestore.collection('users').doc(currentUser.uid).update({
      'isSharingLocation': false,
      'location': FieldValue.delete(),
      'specificRecipientId': FieldValue.delete(),
    });

    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  void listenToFriendLocation(String friendId, void Function(LatLng?) onUpdate) {
    _friendLocationSubscription?.cancel();

    _friendLocationSubscription = _firestore.collection('users').doc(friendId).snapshots().listen((snapshot) {
      if (snapshot.exists && snapshot.data()?['location'] != null) {
        final locationData = snapshot.data()?['location'];
        final updatedLocation = LatLng(locationData['latitude'], locationData['longitude']);
        friendLocation = updatedLocation;
        onUpdate(updatedLocation);
      } else {
        onUpdate(null);
      }
    });
  }

  void stopFriendLocationListener() {
    _friendLocationSubscription?.cancel();
    _friendLocationSubscription = null;
    friendLocation = null;
  }

  void dispose() {
    _locationSubscription?.cancel();
    _friendLocationSubscription?.cancel();
  }
}