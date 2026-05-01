import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class StadiumMap extends StatefulWidget {
  final double stadiumLat;
  final double stadiumLng;

  const StadiumMap({
    super.key,
    required this.stadiumLat,
    required this.stadiumLng,
  });

  @override
  State<StadiumMap> createState() => _StadiumMapState();
}

class _StadiumMapState extends State<StadiumMap> {
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
      if (mounted) {
        setState(() => _userLocation = LatLng(pos.latitude, pos.longitude));
      }
    } catch (_) {}
  }

  Future<void> _launchGoogleMapsRoute() async {
    final stadLat = widget.stadiumLat;
    final stadLng = widget.stadiumLng;

    final Uri uri;
    if (_userLocation != null) {
      uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1'
        '&origin=${_userLocation!.latitude},${_userLocation!.longitude}'
        '&destination=$stadLat,$stadLng'
        '&travelmode=driving',
      );
    } else {
      uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1'
        '&destination=$stadLat,$stadLng'
        '&travelmode=driving',
      );
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak dapat membuka Google Maps'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final stadium = LatLng(widget.stadiumLat, widget.stadiumLng);

    return Column(
      children: [
        Expanded(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(target: stadium, zoom: 13),

            gestureRecognizers: {
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },

            markers: {
              Marker(
                markerId: const MarkerId('stadium'),
                position: stadium,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed),
              ),
              if (_userLocation != null)
                Marker(
                  markerId: const MarkerId('user'),
                  position: _userLocation!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue),
                ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
        ),

        Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            12 + MediaQuery.of(context).padding.bottom,
          ),
          child: FilledButton.tonalIcon(
            onPressed: _launchGoogleMapsRoute,
            icon: const Icon(Icons.directions_rounded, size: 18),
            label: const Text('Buka Rute di Google Maps'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}