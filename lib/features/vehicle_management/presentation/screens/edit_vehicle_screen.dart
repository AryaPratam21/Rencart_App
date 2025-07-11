import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/domain/models/vehicle.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/presentation/widgets/vehicle_image_preview.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/providers/owner_vehicle_providers.dart' as vehicle_providers;
import 'package:image_picker/image_picker.dart';
import 'package:rental_mobil_app_flutter/core/constants/app_constants.dart';


class EditVehicleScreen extends ConsumerStatefulWidget {
  final Vehicle vehicle;
  const EditVehicleScreen({super.key, required this.vehicle});

  @override
  ConsumerState<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

final editVehicleLoadingProvider = StateProvider<bool>((ref) => false);

class _EditVehicleScreenState extends ConsumerState<EditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _carNameController;
  late final TextEditingController _plateNumberController;
  late final TextEditingController _cityController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;

  String? _selectedStatus;
  String? _selectedTransmission;
  String? _selectedCapacity;
  late List<String> _existingImageUrls;
  final List<XFile> _newSelectedImages = [];

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    _carNameController = TextEditingController(text: v.name);
    _plateNumberController = TextEditingController(text: v.plate_number);
    _cityController = TextEditingController(text: v.currentLocationCity);
    _priceController = TextEditingController(text: v.rentalPricePerDay.toString());
    _descriptionController = TextEditingController(text: v.description);
    _locationController = TextEditingController(text: v.location);
    _latitudeController = TextEditingController(text: v.latitude.toString());
    _longitudeController = TextEditingController(text: v.longitude.toString());
    _selectedStatus = v.status;
    _selectedTransmission = v.transmission;
    _selectedCapacity = v.capacity.toString();
    _existingImageUrls = List.from(v.image_urls);
  }

  @override
  void dispose() {
    _carNameController.dispose();
    _plateNumberController.dispose();
    _cityController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await ImagePicker().pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _newSelectedImages.addAll(pickedFiles);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCapacity == null || _selectedTransmission == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih kapasitas dan transmisi')),
      );
      return;
    }

    if (_existingImageUrls.isEmpty && _newSelectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan tambahkan minimal 1 gambar')),
      );
      return;
    }

    setState(() => ref.read(editVehicleLoadingProvider.notifier).state = true);
    

    try {
      final vehicleService = ref.read(vehicle_providers.vehicleServiceProvider);
      final newImageUrls = await vehicleService.uploadImagesAndGetUrls(_newSelectedImages);
      final updatedVehicle = widget.vehicle.copyWith(
        name: _carNameController.text.trim(),
        status: _selectedStatus!,
        plate_number: _plateNumberController.text.trim(),
        rentalPricePerDay: double.tryParse(_priceController.text.trim()) ?? 0,
        image_urls: [..._existingImageUrls, ...newImageUrls],
        capacity: int.tryParse(_selectedCapacity ?? '0') ?? 0,
        transmission: _selectedTransmission ?? '',
        description: _descriptionController.text.trim(),
        currentLocationCity: _cityController.text.trim(),
        location: _locationController.text.trim(),
        latitude: double.tryParse(_latitudeController.text.trim()) ?? 0.0,
        longitude: double.tryParse(_longitudeController.text.trim()) ?? 0.0,
      );
      if (widget.vehicle.id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID kendaraan tidak ditemukan. Tidak dapat menyimpan perubahan.')),
        );
        return;
      }
      await vehicleService.updateVehicle(widget.vehicle.id!, updatedVehicle);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => ref.read(editVehicleLoadingProvider.notifier).state = false);
      }
    }
  }

  

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(editVehicleLoadingProvider);
    return Scaffold(
  backgroundColor: const Color(0xFF1A2E1A),
      appBar: AppBar(
        title: const Text('Edit Mobil'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _carNameController,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green.withOpacity(0.1), width: 1),
                  ),labelText: 'Nama Mobil'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Nama mobil wajib diisi' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _plateNumberController,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green.withOpacity(0.1), width: 1),
                  ),labelText: 'Nomor Polisi'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green.withOpacity(0.1), width: 1),
                  ),labelText: 'Kota'),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green.withOpacity(0.1), width: 1),
                  ),labelText: 'Harga Sewa/Hari (Rp)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green.withOpacity(0.1), width: 1),
                  ),labelText: 'Deskripsi'),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green.withOpacity(0.1), width: 1),
                  ),labelText: 'Lokasi'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
                      decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green.withOpacity(0.1), width: 1),
                  ),labelText: 'Latitude'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeController,
                      decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green.withOpacity(0.1), width: 1),
                  ),labelText: 'Longitude'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                iconEnabledColor: Colors.green,
                style: const TextStyle(color: Colors.black),
                value: _selectedStatus,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green.withOpacity(0.1), width: 1),
                  ),labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'Tersedia', child: Text('Tersedia')),
                  DropdownMenuItem(value: 'Tidak Tersedia', child: Text('Tidak Tersedia')),
                ],
                onChanged: (v) => setState(() => _selectedStatus = v),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                iconEnabledColor: Colors.green,
                style: const TextStyle(color: Colors.black),
                value: _selectedTransmission,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green.withOpacity(0.1), width: 1),
                  ),labelText: 'Transmisi'),
                items: const [
                  DropdownMenuItem(value: 'Manual', child: Text('Manual')),
                  DropdownMenuItem(value: 'Automatic', child: Text('Automatic')),
                ],
                onChanged: (v) => setState(() => _selectedTransmission = v),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                iconEnabledColor: Colors.green,
                style: const TextStyle(color: Colors.black),
                value: _selectedCapacity,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green.withOpacity(0.1), width: 1),
                  ),labelText: 'Kapasitas (Kursi)'),
                items: List.generate(8, (i) => DropdownMenuItem(value: '${i+1}', child: Text('${i+1}'))),
                onChanged: (v) => setState(() => _selectedCapacity = v),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Tambah Gambar'),
                  ),
                  const SizedBox(width: 12),
                  Text('Gambar: ${_existingImageUrls.length + _newSelectedImages.length}'),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._existingImageUrls.map((fileId) => VehicleImagePreview(
                    imageUrl: getAppwriteImageUrl(fileId),
                    onRemove: () {
                      setState(() {
                        _existingImageUrls.remove(fileId);
                      });
                    },
                  )),
                  ..._newSelectedImages.map((file) => VehicleImagePreview(
                    image: file,
                    onRemove: () {
                      setState(() {
                        _newSelectedImages.remove(file);
                      });
                    },
                  )),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: isLoading ? null : _submitForm,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getAppwriteImageUrl(String fileId) {
    return 'https://cloud.appwrite.io/v1/storage/buckets/${AppConstants.vehicleImagesBucketId}/files/$fileId/view?project=${AppConstants.appwriteProjectId}';
  }
}
