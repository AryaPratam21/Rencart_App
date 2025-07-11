import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewLocationButton extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String? address; // Optional, for tooltip or fallback

  const ViewLocationButton({
    super.key,
    required this.latitude,
    required this.longitude,
    this.address,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.location_on),
      label: const Text('Lihat Lokasi di Google Maps'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8BC34A),
        foregroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () async {
        final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tidak dapat membuka Google Maps.')),
          );
        }
      },
    );
  }
}
