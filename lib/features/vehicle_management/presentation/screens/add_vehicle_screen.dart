import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/domain/models/vehicle.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/presentation/widgets/vehicle_image_preview.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/providers/owner_vehicle_providers.dart' as vehicle_providers;
import 'package:rental_mobil_app_flutter/features/auth/providers/auth_controller_provider.dart';
import 'package:image_picker/image_picker.dart';


class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

final addVehicleLoadingProvider = StateProvider<bool>((ref) => false);

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _carNameController = TextEditingController();
  final _plateNumberController = TextEditingController();
  final _cityController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  String? _selectedStatus = 'Tersedia';
  String? _selectedTransmission;
  String? _selectedCapacity;
  final List<XFile> _newSelectedImages = [];

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

    if (_newSelectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan tambahkan minimal 1 gambar')),
      );
      return;
    }

    setState(() => ref.read(addVehicleLoadingProvider.notifier).state = true);
    var user = ref.read(authControllerProvider).user;
    if (user == null) {
      user = await ref.read(authControllerProvider.notifier).getCurrentUser();
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesi login habis atau user tidak ditemukan. Silakan login ulang.')),
        );
        setState(() => ref.read(addVehicleLoadingProvider.notifier).state = false);
        // TODO: arahkan ke halaman login jika perlu
        return;
      }
    }

    try {
      final vehicleService = ref.read(vehicle_providers.vehicleServiceProvider);
      final fileIds = await vehicleService.uploadImagesAndGetFileIds(_newSelectedImages, userId: user.$id);
      print('DEBUG fileIds hasil upload: ' + fileIds.toString());
      if (fileIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal upload gambar, fileId kosong!')),
        );
        setState(() => ref.read(addVehicleLoadingProvider.notifier).state = false);
        return;
      }
      final vehicle = Vehicle(
        ownerId: user.$id,
        name: _carNameController.text.trim(),
        status: _selectedStatus!,
        plate_number: _plateNumberController.text.trim(),
        rentalPricePerDay: double.tryParse(_priceController.text.trim()) ?? 0,
        image_urls: fileIds,
        vin: null,
        mileage: null,
        year: null,
        lastBookingUserId: null,
        capacity: int.tryParse(_selectedCapacity ?? '0') ?? 0,
        transmission: _selectedTransmission ?? '',
        description: _descriptionController.text.trim(),
        currentLocationCity: _cityController.text.trim(),
        location: _locationController.text.trim(),
        latitude: double.tryParse(_latitudeController.text.trim()) ?? 0.0,
        longitude: double.tryParse(_longitudeController.text.trim()) ?? 0.0,
      );
      await vehicleService.addVehicle(vehicle, fileIds);
      if (mounted) {
        // Refresh list kendaraan agar gambar baru langsung muncul
        ref.invalidate(vehicle_providers.ownerVehiclesProvider);
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => ref.read(addVehicleLoadingProvider.notifier).state = false);
      }
    }
  }

  

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(addVehicleLoadingProvider);
    return Scaffold(
  backgroundColor: const Color(0xFF1A2E1A),
      appBar: AppBar(
        title: const Text('Tambah Mobil', style: TextStyle(color: Colors.white)),
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
              Text(
                'Form Tambah Mobil',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
  controller: _carNameController,
  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
  decoration: InputDecoration(
  filled: true,
  fillColor: Colors.transparent,
    labelText: 'Nama Mobil',
    labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    hintStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    helperStyle: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
    errorStyle: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
    counterStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.green, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white, width: 1),
    ),
  ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Nama mobil wajib diisi' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
  controller: _plateNumberController,
  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
  decoration: InputDecoration(
  filled: true,
  fillColor: Colors.transparent,
    labelText: 'Nomor Polisi',
    labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    hintStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    helperStyle: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
    errorStyle: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
    counterStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.green, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white, width: 1),
    ),
  ),
),
              const SizedBox(height: 8),
              TextFormField(
  controller: _cityController,
  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
  decoration: InputDecoration(
  filled: true,
  fillColor: Colors.transparent,
    labelText: 'Kota',
    labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    hintStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    helperStyle: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
    errorStyle: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
    counterStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.green, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white, width: 1),
    ),
  ),
),
              const SizedBox(height: 8),
              TextFormField(
  controller: _priceController,
  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
  decoration: InputDecoration(
  filled: true,
  fillColor: Colors.transparent,
    labelText: 'Harga Sewa/Hari (Rp)',
    labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    hintStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    helperStyle: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
    errorStyle: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
    counterStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.green, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white, width: 1),
    ),
  ),
  keyboardType: TextInputType.number,
),
              const SizedBox(height: 8),
              TextFormField(
  controller: _descriptionController,
  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
  decoration: InputDecoration(
  filled: true,
  fillColor: Colors.transparent,
    labelText: 'Deskripsi',
    labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    hintStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    helperStyle: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
    errorStyle: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
    counterStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.green, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white, width: 1),
    ),
  ),
  maxLines: 3,
),
              const SizedBox(height: 8),
              TextFormField(
  controller: _locationController,
  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
  decoration: InputDecoration(
  filled: true,
  fillColor: Colors.transparent,
    labelText: 'Lokasi',
    labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    hintStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    helperStyle: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
    errorStyle: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
    counterStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.green, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white, width: 1),
    ),
  ),
),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
  child: TextFormField(
    controller: _latitudeController,
    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    decoration: InputDecoration(
  filled: true,
  fillColor: Colors.transparent,
      labelText: 'Latitude',
      labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      hintStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      helperStyle: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
      errorStyle: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
      counterStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.green, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.green, width: 1),
      ),
    ),
    keyboardType: TextInputType.number,
  ),
),
                  const SizedBox(width: 8),
                  Expanded(
  child: TextFormField(
    controller: _longitudeController,
    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    decoration: InputDecoration(
  filled: true,
  fillColor: Colors.transparent,
      labelText: 'Longitude',
      labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      hintStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      helperStyle: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
      errorStyle: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
      counterStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.green, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.green, width: 1),
      ),
    ),
    keyboardType: TextInputType.number,
  ),
),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
  dropdownColor: const Color(0xFF2A402A),
  iconEnabledColor: Colors.green,
  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
  value: _selectedStatus,
  decoration: InputDecoration(
  filled: true,
  fillColor: Colors.transparent,
    labelText: 'Status',
    labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    hintStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    helperStyle: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
    errorStyle: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
    counterStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.green, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white, width: 1),
    ),
  ),
  items: const [
    DropdownMenuItem(value: 'Tersedia', child: Text('Tersedia', style: TextStyle(color: Colors.white))),
    DropdownMenuItem(value: 'Tidak Tersedia', child: Text('Tidak Tersedia', style: TextStyle(color: Colors.white))),
  ],
  onChanged: (v) => setState(() => _selectedStatus = v),
),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
  dropdownColor: const Color(0xFF2A402A),
  iconEnabledColor: Colors.green,
  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
  value: _selectedTransmission,
  decoration: InputDecoration(
  filled: true,
  fillColor: Colors.transparent,
    labelText: 'Transmisi',
    labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    hintStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    helperStyle: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
    errorStyle: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
    counterStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.green, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white, width: 1),
    ),
  ),
  items: const [
    DropdownMenuItem(value: 'Manual', child: Text('Manual', style: TextStyle(color: Colors.white))),
    DropdownMenuItem(value: 'Automatic', child: Text('Automatic', style: TextStyle(color: Colors.white))),
  ],
  onChanged: (v) => setState(() => _selectedTransmission = v),
),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
  dropdownColor: const Color(0xFF2A402A),
  iconEnabledColor: Colors.green,
  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
  value: _selectedCapacity,
  decoration: InputDecoration(
  filled: true,
  fillColor: Colors.transparent,
    labelText: 'Kapasitas (Kursi)',
    labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    hintStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    helperStyle: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600),
    errorStyle: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
    counterStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.green, width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white, width: 1),
    ),
  ),
  items: List.generate(8, (i) => DropdownMenuItem(value: '${i+1}', child: Text('${i+1}', style: TextStyle(color: Colors.white)))),
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
                  Text('Gambar: ${_newSelectedImages.length}'),
                ],
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
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
              SizedBox(height: 16),
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
}
