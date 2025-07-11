import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rental_mobil_app_flutter/core/constants/app_constants.dart';
import 'package:rental_mobil_app_flutter/features/auth/providers/auth_controller_provider.dart';
import 'package:rental_mobil_app_flutter/features/booking_management/domain/booking.dart';
import 'package:rental_mobil_app_flutter/features/booking_management/providers/booking_providers.dart'
    as booking_providers;
import 'package:rental_mobil_app_flutter/features/customer_area/presentation/screens/customer_booking_detail_screen.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/domain/models/vehicle.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/providers/owner_vehicle_providers.dart'
    as vehicle_providers;

// Helper untuk mengubah fileId menjadi URL gambar Appwrite
String getFilePreviewUrl(String fileId) {
  return 'https://cloud.appwrite.io/v1/storage/buckets/${AppConstants.vehicleImagesBucketId}/files/$fileId/view?project=${AppConstants.appwriteProjectId}';
}

/// Provider sederhana untuk state form (bisa juga pakai StatefulWidget state biasa)
final bookingFormProvider =
    StateNotifierProvider<BookingFormNotifier, BookingFormData>(
      (ref) => BookingFormNotifier(),
    );

class BookingFormData {
  final DateTime? startDate;
  final DateTime? endDate;
  final String fullName;
  final String phoneNumber;
  final String email;
  final int numberOfDays;
  final double rentalPrice;
  final double taxesAndFees;
  final double totalPrice;

  BookingFormData({
    this.startDate,
    this.endDate,
    this.fullName = '',
    this.phoneNumber = '',
    this.email = '',
    this.numberOfDays = 0,
    this.rentalPrice = 0.0,
    this.taxesAndFees = 0.0,
    this.totalPrice = 0.0,
  });

  BookingFormData copyWith({
    DateTime? startDate,
    DateTime? endDate,
    String? fullName,
    String? phoneNumber,
    String? email,
    int? numberOfDays,
    double? rentalPrice,
    double? taxesAndFees,
    double? totalPrice,
  }) {
    return BookingFormData(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      numberOfDays: numberOfDays ?? this.numberOfDays,
      rentalPrice: rentalPrice ?? this.rentalPrice,
      taxesAndFees: taxesAndFees ?? this.taxesAndFees,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}

class BookingFormNotifier extends StateNotifier<BookingFormData> {
  BookingFormNotifier() : super(BookingFormData());

  void setStartDate(DateTime date, double pricePerDay) {
    state = state.copyWith(startDate: date);
    _calculatePrice(pricePerDay);
  }

  void setEndDate(DateTime date, double pricePerDay) {
    state = state.copyWith(endDate: date);
    _calculatePrice(pricePerDay);
  }

  void setFullName(String name) {
    state = state.copyWith(fullName: name);
  }

  void setPhoneNumber(String phone) {
    state = state.copyWith(phoneNumber: phone);
  }

  void setEmail(String email) {
    state = state.copyWith(email: email);
  }

  void _calculatePrice(double pricePerDay) {
    if (state.startDate != null &&
        state.endDate != null &&
        state.endDate!.isAfter(state.startDate!)) {
      final days = state.endDate!.difference(state.startDate!).inDays + 1;
      final rental = days * pricePerDay;
      final taxes = rental * 0.1; // Asumsi pajak 10%
      state = state.copyWith(
        numberOfDays: days,
        rentalPrice: rental,
        taxesAndFees: taxes,
        totalPrice: rental + taxes,
      );
    }
  }
}

class CustomerBookingFormScreen extends ConsumerStatefulWidget {
  final Vehicle vehicle;
  const CustomerBookingFormScreen({super.key, required this.vehicle});

  @override
  ConsumerState<CustomerBookingFormScreen> createState() =>
      _CustomerBookingFormScreenState();
}

class _CustomerBookingFormScreenState
    extends ConsumerState<CustomerBookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Isi data dari state Riverpod jika ada (misalnya saat kembali ke halaman ini)
    final formData = ref.read(bookingFormProvider);
    _fullNameController.text = formData.fullName;
    _phoneController.text = formData.phoneNumber;
    _emailController.text = formData.email;

    // Set tanggal jika ada
    if (formData.startDate != null) {
      _startDate = formData.startDate!;
    }
    if (formData.endDate != null) {
      _endDate = formData.endDate!;
    }

    // Listener untuk update state Riverpod saat text field berubah
    _fullNameController.addListener(() {
      ref
          .read(bookingFormProvider.notifier)
          .setFullName(_fullNameController.text);
    });
    _phoneController.addListener(() {
      ref
          .read(bookingFormProvider.notifier)
          .setPhoneNumber(_phoneController.text);
    });
    _emailController.addListener(() {
      ref.read(bookingFormProvider.notifier).setEmail(_emailController.text);
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final formData = ref.read(bookingFormProvider);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? formData.startDate ?? DateTime.now()
          : formData.endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );

    if (picked != null) {
      if (isStartDate) {
        _startDate = picked;
        ref
            .read(bookingFormProvider.notifier)
            .setStartDate(picked, widget.vehicle.rentalPricePerDay);
      } else {
        if (_startDate != null && picked.isAfter(_startDate!)) {
          _endDate = picked;
          ref
              .read(bookingFormProvider.notifier)
              .setEndDate(picked, widget.vehicle.rentalPricePerDay);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Tanggal akhir harus lebih besar dari tanggal awal',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      setState(() {});
    }
  }

  Future<void> _submitBookingToAppwrite(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // 1. Dapatkan user ID
      final user = await ref
          .read(authControllerProvider.notifier)
          .getCurrentUser();
      if (user == null) {
        throw Exception('User tidak terotentikasi');
      }

      // 2. Buat booking data
      final bookingData = Booking(
        userId: user.$id,
        customerName: ref.read(bookingFormProvider).fullName,
        customerPhone: ref.read(bookingFormProvider).phoneNumber,
        customerEmail: ref.read(bookingFormProvider).email,
        vehicleId: widget.vehicle.id!,
        startDate: ref.read(bookingFormProvider).startDate!,
        endDate: ref.read(bookingFormProvider).endDate!,
        totalPrice: ref.read(bookingFormProvider).totalPrice,
        status: 'pending_confirmation',
        paymentMethod: 'cash',
      );

      // 3. Buat booking di Appwrite
      final bookingService = ref.read(booking_providers.bookingServiceProvider);
      final bookingId = await bookingService.createBooking(bookingData, ref);

      // 4. Update status kendaraan
      final vehicleService = ref.read(vehicle_providers.vehicleServiceProvider);
      await vehicleService.updateVehicleStatus(
        widget.vehicle.id!,
        'Not Available',
      );

      // 5. Navigasi ke detail booking
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              CustomerBookingDetailScreen(bookingId: bookingId),
        ),
      );
    } catch (e) {
      // 6. Handle error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formData = ref.watch(bookingFormProvider);
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF1A2E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Booking Mobil',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Detail Mobil'),
                _buildCarSummary(widget.vehicle, currencyFormatter),
                const SizedBox(height: 24),
                _buildSectionTitle('Detail Penyewa'),
                _buildTextField(
                  label: 'Nama Lengkap',
                  controller: _fullNameController,
                  hint: 'Masukkan nama lengkap',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Nomor Telepon',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  hint: 'Masukkan nomor telepon',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  hint: 'Masukkan email',
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Perjalanan Anda'),
                _buildDateField(
                  'Tanggal Mulai',
                  _startDate,
                  () => _selectDate(context, true),
                ),
                const SizedBox(height: 16),
                _buildDateField(
                  'Tanggal Selesai',
                  _endDate,
                  () => _selectDate(context, false),
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Ringkasan Harga'),
                _buildPriceDetail(
                  'Harga Sewa',
                  formData.rentalPrice.toInt(),
                  currencyFormatter,
                ),
                _buildPriceDetail(
                  'Pajak (10%)',
                  formData.taxesAndFees.toInt(),
                  currencyFormatter,
                ),
                _buildPriceDetail(
                  'Total',
                  formData.totalPrice.toInt(),
                  currencyFormatter,
                  isTotal: true,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () => _submitBookingToAppwrite(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8BC34A),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Lakukan Booking',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(height: 2, width: 40, color: const Color(0xFF8BC34A)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white38),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF8BC34A)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Harap isi kolom ini';
        }
        return null;
      },
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? selectedDate,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white38),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.white70),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedDate != null
                    ? DateFormat('dd MMMM yyyy', 'id_ID').format(selectedDate)
                    : 'Pilih $label',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceDetail(
    String label,
    int amount,
    NumberFormat formatter, {
    bool isTotal = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            formatter.format(amount),
            style: TextStyle(
              color: isTotal ? const Color(0xFF8BC34A) : Colors.white,
              fontSize: 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarSummary(Vehicle vehicle, NumberFormat formatter) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF121F12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              getFilePreviewUrl(vehicle.image_urls.first),
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[200],
                  child: const Icon(Icons.error, color: Colors.red),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  vehicle.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      vehicle.currentLocationCity,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.money, color: Colors.white70, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      formatter.format(vehicle.rentalPricePerDay),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      '/hari',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
