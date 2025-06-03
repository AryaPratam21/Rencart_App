import 'dart:io' show File;
import 'dart:io';
import 'package:appwrite/appwrite.dart' as appwrite;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:rental_mobil_app_flutter/features/booking_management/domain/booking.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/domain/vehicle.dart'
    as vehicle_model;
import 'package:rental_mobil_app_flutter/features/vehicle_management/providers/owner_vehicle_providers.dart';

// Provider untuk loading state form ini
final addEditVehicleLoadingProvider = StateProvider<bool>((ref) => false);
// Provider untuk list gambar yang baru dipilih (File)
final newSelectedImagesProvider = StateProvider<List<XFile>>((ref) => []);
// Provider untuk list URL gambar yang sudah ada (untuk mode edit, dan yang tidak dihapus)
final existingImageUrlsProvider =
    StateProvider.family<List<String>, List<String>?>(
        (ref, initialUrls) => initialUrls ?? []);

// Provider untuk riwayat booking mobil ini (dummy, implementasi service asli di BookingService)
final vehicleBookingHistoryProvider =
    FutureProvider.family<List<Booking>, String>((ref, vehicleId) async {
  // TODO: Ganti dengan fetch dari BookingService
  await Future.delayed(Duration(seconds: 1));
  if (vehicleId == "ID_MOBIL_DUMMY_1") {
    return [
      Booking(
        id: 'b1',
        customerName: 'Ava Carter',
        vehicleId: vehicleId,
        startDate: DateTime(2024, 7, 15),
        endDate: DateTime(2024, 7, 20),
        totalPrice: 200,
        status: 'completed',
        customerPhone: '',
        customerEmail: '',
        ownerNotes: '',
      ),
      Booking(
        id: 'b2',
        customerName: 'Ethan Harper',
        vehicleId: vehicleId,
        startDate: DateTime(2024, 6, 10),
        endDate: DateTime(2024, 6, 12),
        totalPrice: 150,
        status: 'completed',
        customerPhone: '',
        customerEmail: '',
        ownerNotes: '',
      ),
    ];
  }
  return [];
});

class AddEditVehicleScreen extends ConsumerStatefulWidget {
  final bool isEditMode;
  final vehicle_model.Vehicle? vehicle; // Gunakan prefix di sini

  const AddEditVehicleScreen({
    super.key,
    required this.isEditMode,
    this.vehicle,
  });

  @override
  ConsumerState<AddEditVehicleScreen> createState() =>
      _AddEditVehicleScreenState();
}

class _AddEditVehicleScreenState extends ConsumerState<AddEditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _carNameController;
  late TextEditingController _plateNumberController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _cityController;

  String? _selectedStatus;
  String? _selectedTransmission;
  String? _selectedCapacity;

  final List<String> _statusOptions = [
    'available',
    'rented',
    'maintenance',
    'inactive'
  ];
  final List<String> _transmissionOptions = ['Automatic', 'Manual'];
  final List<String> _capacityOptions = ['2', '4', '5', '7', '8+'];

  @override
  void initState() {
    super.initState();
    _carNameController = TextEditingController(
        text: widget.isEditMode ? widget.vehicle?.name : '');
    _plateNumberController = TextEditingController(
        text: widget.isEditMode ? widget.vehicle?.plateNumber : '');
    _priceController = TextEditingController(
        text: widget.isEditMode
            ? widget.vehicle?.rentalPricePerDay.toString()
            : '');
    _descriptionController = TextEditingController(
        text: widget.isEditMode ? widget.vehicle?.description : '');
    _cityController = TextEditingController(
        text: widget.isEditMode ? widget.vehicle?.currentLocationCity : '');

    if (widget.isEditMode && widget.vehicle != null) {
      _selectedStatus = widget.vehicle!.status;
      _selectedTransmission = widget.vehicle!.transmission;
      _selectedCapacity = widget.vehicle!.capacity?.toString();
      // Inisialisasi existingImageUrlsProvider dengan gambar yang sudah ada
      // Kita gunakan `Future.microtask` agar provider bisa diinisialisasi setelah build pertama
      Future.microtask(() {
        ref
            .read(existingImageUrlsProvider(widget.vehicle!.imageUrls).notifier)
            .state = List<String>.from(widget.vehicle!.imageUrls);
      });
    } else {
      _selectedStatus = _statusOptions.first; // Default status untuk mobil baru
    }
  }

  @override
  void dispose() {
    _carNameController.dispose();
    _plateNumberController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    // Tidak perlu manual invalidate provider jika sudah autoDispose
    super.dispose();
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    try {
      final List<XFile> pickedFiles = await picker.pickMultiImage(
        imageQuality: 70, // Kompresi gambar
        maxWidth: 1024, // Batasi lebar gambar
        maxHeight: 1024, // Batasi tinggi gambar
      );
      if (pickedFiles.isNotEmpty) {
        ref.read(newSelectedImagesProvider.notifier).update((state) {
          final currentFiles = List<XFile>.from(state);
          currentFiles.addAll(pickedFiles);
          return currentFiles;
        });
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error picking images: $e'),
            backgroundColor: Colors.red));
    }
  }

  Future<void> _saveOrUpdateVehicle() async {
    if (!_formKey.currentState!.validate() || _selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Mohon lengkapi semua data yang wajib diisi.'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    ref.read(addEditVehicleLoadingProvider.notifier).state = true;

    try {
      final vehicleService = ref.read(vehicleServiceProvider);
      final newImages = ref.read(newSelectedImagesProvider);
      final existingImages =
          ref.read(existingImageUrlsProvider(widget.vehicle?.imageUrls));

      final vehicleData = vehicle_model.Vehicle(
        id: widget.isEditMode ? widget.vehicle!.id : null,
        name: _carNameController.text.trim(),
        plateNumber: _plateNumberController.text.trim(),
        rentalPricePerDay: double.tryParse(_priceController.text.trim()) ?? 0.0,
        status: _selectedStatus!,
        imageUrls: widget.isEditMode ? existingImages : [],
        transmission: _selectedTransmission,
        capacity: _selectedCapacity != null && _selectedCapacity!.isNotEmpty
            ? int.tryParse(_selectedCapacity!)
            : null,
        description: _descriptionController.text.trim(),
        currentLocationCity: _cityController.text.trim(),
      );

      if (widget.isEditMode) {
        await vehicleService.updateVehicle(
            vehicleData, newImages, widget.vehicle!.imageUrls);
      } else {
        await ref
            .read(vehicleServiceProvider)
            .addVehicle(vehicleData, newImages);
      }
      ref.invalidate(ownerVehiclesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Mobil berhasil ${widget.isEditMode ? "diperbarui" : "ditambahkan"}!'),
              backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    } on appwrite.AppwriteException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Appwrite Error: ${e.message ?? "Unknown error"}'),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('An unexpected error occurred: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        ref.read(addEditVehicleLoadingProvider.notifier).state = false;
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final Color textColor = Colors.white.withOpacity(0.8);
    final Color hintColor = Colors.white.withOpacity(0.5);
    final Color fieldBackgroundColor = Color(0xFF2A402A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: textColor, fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8.0),
        TextFormField(
          controller: controller,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: hint ?? 'Enter $label',
            hintStyle: TextStyle(color: hintColor),
            filled: true,
            fillColor: fieldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          ),
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator ??
              (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter $label';
                }
                if (label.contains('Price') &&
                    (double.tryParse(value) == null ||
                        double.parse(value) <= 0)) {
                  return 'Please enter a valid positive price';
                }
                return null;
              },
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? currentValue,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? hint,
  }) {
    final Color textColor = Colors.white.withOpacity(0.8);
    final Color hintColor = Colors.white.withOpacity(0.5);
    final Color dropdownBackgroundColor = Color(0xFF2A402A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: textColor, fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8.0),
        DropdownButtonFormField<String>(
          value: currentValue,
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: TextStyle(color: Colors.black87)),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint ?? 'Select $label',
            hintStyle: TextStyle(color: hintColor),
            filled: true,
            fillColor: dropdownBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          ),
          dropdownColor: Colors.grey[200],
          iconEnabledColor: textColor,
          style: TextStyle(color: textColor, fontSize: 16),
          validator: (value) =>
              (value == null || value.isEmpty) ? 'Please select $label' : null,
        ),
      ],
    );
  }

  Widget _buildImageSection(WidgetRef ref) {
    final newImages = ref.watch(newSelectedImagesProvider);
    final existingUrls = ref.watch(existingImageUrlsProvider(
        widget.vehicle?.imageUrls)); // Pass initial URLs
    final Color textColor = Colors.white.withOpacity(0.8);
    final Color hintColor = Colors.white.withOpacity(0.5);
    final Color fieldBackgroundColor = Color(0xFF2A402A);

    bool hasImages = newImages.isNotEmpty || existingUrls.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Car Images',
            style: TextStyle(
                color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
              color: fieldBackgroundColor,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  style: BorderStyle.solid,
                  width: 1)),
          child: Column(
            children: [
              if (!hasImages)
                Column(
                  children: [
                    Icon(Icons.cloud_upload_outlined,
                        size: 50, color: hintColor),
                    const SizedBox(height: 8),
                    Text('Upload Images',
                        style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                        'Add photos of your car to showcase its features and condition.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: hintColor, fontSize: 13)),
                  ],
                ),
              if (existingUrls.isNotEmpty)
                _buildExistingImagesGrid(existingUrls, ref),
              if (newImages.isNotEmpty) _buildNewImagesGrid(newImages, ref),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: Icon(Icons.photo_library_outlined, color: Colors.black87),
                label: Text('Select Images',
                    style: TextStyle(color: Colors.black87)),
                onPressed: _pickImages,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[400],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNewImagesGrid(List<XFile> images, WidgetRef ref) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return kIsWeb
            ? Image.network(images[index].path)
            : Image.file(File(images[index].path));
      },
    );
  }

  Widget _buildExistingImagesGrid(List<String> imageUrls, WidgetRef ref) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                imageUrls[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[700],
                    child: Icon(Icons.error_outline, color: Colors.grey[400])),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                      child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF8BC34A))));
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.all(2),
              decoration:
                  BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: IconButton(
                icon: Icon(Icons.delete_outline,
                    color: Colors.redAccent, size: 18),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                onPressed: () {
                  // Logika untuk menandai gambar ini akan dihapus saat update
                  // Untuk sekarang, kita hapus langsung dari state providernya
                  ref
                      .read(existingImageUrlsProvider(widget.vehicle?.imageUrls)
                          .notifier)
                      .update((state) {
                    final newList = List<String>.from(state);
                    newList.removeAt(index);
                    return newList;
                  });
                  print('Marked image ${imageUrls[index]} for deletion.');
                },
              ),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(addEditVehicleLoadingProvider);
    final Color backgroundColor = Color(0xFF1A2E1A);
    final Color buttonColor = Color(0xFF8BC34A);
    final Color textColor = Colors.white.withOpacity(0.9);
    final Color subTextColor = Colors.white.withOpacity(0.7);
    final Color chipBackgroundColor = Color(0xFF2A402A);
    final Color selectedChipColor = Color(0xFF8BC34A);

    // Ambil riwayat booking jika mode edit dan vehicle ada
    final bookingHistoryAsync = widget.isEditMode && widget.vehicle?.id != null
        ? ref.watch(vehicleBookingHistoryProvider(widget.vehicle!.id!))
        : null;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: Icon(Icons.close, color: Colors.white.withOpacity(0.8)),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Text(
          widget.isEditMode ? 'Edit Car' : 'Add Car',
          style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar mobil besar di atas (mode edit)
              if (widget.isEditMode &&
                  widget.vehicle != null &&
                  widget.vehicle!.imageUrls.isNotEmpty)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: widget.vehicle!.imageUrls.isNotEmpty
                        ? Image.network(
                            widget.vehicle!.imageUrls.first,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                    height: 200,
                                    color: Colors.grey[700],
                                    child: Icon(Icons.image_not_supported,
                                        color: Colors.grey[400], size: 50)),
                          )
                        : Container(child: Icon(Icons.directions_car)),
                  ),
                ),
              if (widget.isEditMode) const SizedBox(height: 20),

              _buildTextField(
                  label: 'Car Name', controller: _carNameController),
              const SizedBox(height: 16),
              _buildTextField(
                  label: 'Plate Number', controller: _plateNumberController),
              const SizedBox(height: 16),

              if (widget.isEditMode) ...[
                _buildDetailRow("VIN:", "1234567890ABCDEFG"),
                _buildDetailRow("Mileage:", "35,000 miles"),
                _buildDetailRow("Location:", _cityController.text),
                const SizedBox(height: 16),
              ],

              _buildTextField(
                  label: 'Price per Day (\$)',
                  controller: _priceController,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 20),

              Text('Status',
                  style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 8.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _statusOptions.map((status) {
                  bool isSelected = _selectedStatus == status;
                  return ChoiceChip(
                    label: Text(status,
                        style: TextStyle(
                            color: isSelected ? Colors.black87 : textColor)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatus = status;
                      });
                    },
                    backgroundColor: chipBackgroundColor,
                    selectedColor: selectedChipColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide.none),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              _buildTextField(
                  label: 'Description',
                  controller: _descriptionController,
                  maxLines: 3),
              const SizedBox(height: 16),
              _buildDropdownField(
                  label: 'Transmission',
                  currentValue: _selectedTransmission,
                  items: _transmissionOptions,
                  onChanged: (val) =>
                      setState(() => _selectedTransmission = val)),
              const SizedBox(height: 16),
              _buildDropdownField(
                  label: 'Capacity',
                  currentValue: _selectedCapacity,
                  items: _capacityOptions,
                  hint: 'Select capacity',
                  onChanged: (val) => setState(() => _selectedCapacity = val)),
              const SizedBox(height: 16),
              _buildTextField(
                  label: 'Current Location City', controller: _cityController),
              const SizedBox(height: 24),

              _buildImageSection(ref),
              const SizedBox(height: 24),

              // Booking History (hanya tampil jika mode edit dan ada data)
              if (widget.isEditMode && bookingHistoryAsync != null) ...[
                Text('Booking History',
                    style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                bookingHistoryAsync.when(
                  data: (history) {
                    if (history.isEmpty) {
                      return Text('No booking history for this car.',
                          style: TextStyle(color: subTextColor));
                    }
                    return Column(
                      children: history
                          .map((booking) => _buildBookingHistoryItem(
                              booking, textColor, subTextColor))
                          .toList(),
                    );
                  },
                  loading: () => Center(
                      child: CircularProgressIndicator(color: buttonColor)),
                  error: (err, stack) => Text(
                      'Error loading booking history: $err',
                      style: TextStyle(color: Colors.redAccent)),
                ),
                const SizedBox(height: 24),
              ],

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
            top: 10.0),
        child: isLoading
            ? Center(
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(color: buttonColor)))
            : ElevatedButton(
                onPressed: _saveOrUpdateVehicle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  minimumSize: Size(double.infinity, 56),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: Text(widget.isEditMode ? 'Save Changes' : 'Add Car',
                    style: TextStyle(color: Colors.black87)),
              ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final Color textColor = Colors.white.withOpacity(0.9);
    final Color subTextColor = Colors.white.withOpacity(0.7);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: subTextColor, fontSize: 14)),
          Text(value,
              style: TextStyle(
                  color: textColor, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildBookingHistoryItem(
      Booking booking, Color textColor, Color subTextColor) {
    final DateFormat dateFormat = DateFormat('MMMM d, yyyy');
    return Card(
      color: Color(0xFF2A402A),
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(0xFF8BC34A).withOpacity(0.2),
          child: Icon(Icons.person_outline, color: Color(0xFF8BC34A)),
        ),
        title: Text(booking.customerName,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
        subtitle: Text(
            '${dateFormat.format(booking.startDate)} - ${dateFormat.format(booking.endDate)}',
            style: TextStyle(color: subTextColor)),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
