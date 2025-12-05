import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check and request location permissions
  Future<bool> checkAndRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    
    return true;
  }

  /// Get current location with city and country
  Future<Map<String, dynamic>?> getCurrentLocation() async {
    try {
      // Check if location service is enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        return null;
      }

      // Check and request permission
      bool hasPermission = await checkAndRequestPermission();
      if (!hasPermission) {
        print('Location permission denied');
        return null;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          
          return {
            'latitude': position.latitude,
            'longitude': position.longitude,
            'city': place.locality ?? place.subAdministrativeArea ?? 'Unknown',
            'country': place.country ?? 'Unknown',
          };
        }
      } catch (e) {
        print('Error getting address: $e');
        // Return coordinates even if geocoding fails
        return {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'city': null,
          'country': null,
        };
      }

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'city': null,
        'country': null,
      };
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  /// Open app settings for location permission
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }
}
