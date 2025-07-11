import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

class VehicleImagePreview extends StatelessWidget {
  final String? imageUrl; // Untuk gambar dari URL
  final XFile? image; // Untuk gambar dari galeri
  final VoidCallback onRemove;

  const VehicleImagePreview({
    super.key,
    this.imageUrl, // Tambahkan parameter imageUrl
    this.image, // Tambahkan parameter image
    required this.onRemove,
  }) : assert(
         (imageUrl != null && image == null) ||
             (imageUrl == null && image != null),
         'Harus menyediakan salah satu: imageUrl atau image, tapi tidak keduanya',
       );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl != null
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    width: 120,
                    height: 120,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                        ),
                      );
                    },
                  )
                : image != null
                ? (kIsWeb
                    ? FutureBuilder<Uint8List>(
                        future: image!.readAsBytes(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                            return Image.memory(
                              snapshot.data!,
                              fit: BoxFit.cover,
                              width: 120,
                              height: 120,
                            );
                          }
                          return const Center(child: CircularProgressIndicator());
                        },
                      )
                    : Image.file(
                        File(image!.path),
                        fit: BoxFit.cover,
                        width: 120,
                        height: 120,
                      ))
                : Container(),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
