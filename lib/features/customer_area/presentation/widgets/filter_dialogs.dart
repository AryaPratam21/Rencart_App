import 'package:flutter/material.dart';

// List of available locations
const List<String> availableLocations = [
  'Jakarta',
  'Bandung',
  'Surabaya',
  'Yogyakarta',
  'Bali',
];

// List of available car types
const List<String> availableCarTypes = ['Manual', 'Automatic'];

class LocationFilterDialog extends StatelessWidget {
  const LocationFilterDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pilih Lokasi'),
      content: SizedBox(
        width: 300,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: availableLocations.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(availableLocations[index]),
              onTap: () => Navigator.pop(context, availableLocations[index]),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
      ],
    );
  }
}

class CarTypeFilterDialog extends StatelessWidget {
  const CarTypeFilterDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pilih Tipe Mobil'),
      content: SizedBox(
        width: 300,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: availableCarTypes.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(availableCarTypes[index]),
              onTap: () => Navigator.pop(context, availableCarTypes[index]),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
      ],
    );
  }
}
