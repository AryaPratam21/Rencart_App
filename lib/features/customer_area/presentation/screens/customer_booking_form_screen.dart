import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Opsional untuk screen ini, tergantung state management Anda
import 'package:intl/intl.dart';
import 'package:rental_mobil_app_flutter/features/vehicle_management/domain/vehicle.dart'; // Sesuaikan path

// Provider sederhana untuk state form (bisa juga pakai StatefulWidget state biasa)
final bookingFormProvider = StateNotifierProvider.autoDispose<BookingFormNotifier, BookingFormData>((ref) {
  return BookingFormNotifier();
});

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
    if (state.startDate != null && state.endDate != null && state.endDate!.isAfter(state.startDate!)) {
      final days = state.endDate!.difference(state.startDate!).inDays + 1; // +1 karena hari awal dihitung
      final rental = days * pricePerDay;
      final taxes = rental * 0.1; // Asumsi pajak 10%
      state = state.copyWith(
        numberOfDays: days,
        rentalPrice: rental,
        taxesAndFees: taxes,
        totalPrice: rental + taxes,
      );
    } else {
       state = state.copyWith(
        numberOfDays: 0,
        rentalPrice: 0,
        taxesAndFees: 0,
        totalPrice: 0,
      );
    }
  }
}


class CustomerBookingFormScreen extends ConsumerStatefulWidget {
  final Vehicle vehicle; // Mobil yang akan dibooking

  const CustomerBookingFormScreen({super.key, required this.vehicle});

  @override
  ConsumerState<CustomerBookingFormScreen> createState() => _CustomerBookingFormScreenState();
}

class _CustomerBookingFormScreenState extends ConsumerState<CustomerBookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Warna sesuai gambar
  static const Color darkBackgroundColor = Color(0xFF1A2E1A);
  static const Color primaryTextColor = Colors.white;
  static const Color secondaryTextColor = Colors.white70;
  static const Color fieldBackgroundColor = Color(0xFF253825); // Warna field input
  static const Color accentButtonColor = Color(0xFF8BC34A);

  final DateFormat _dateFormatter = DateFormat('MMMM d, yyyy');

  @override
  void initState() {
    super.initState();
    // Isi data dari state Riverpod jika ada (misalnya saat kembali ke halaman ini)
    final formData = ref.read(bookingFormProvider);
    _fullNameController.text = formData.fullName;
    _phoneController.text = formData.phoneNumber;
    _emailController.text = formData.email;

    // Listener untuk update state Riverpod saat text field berubah
    _fullNameController.addListener(() {
      ref.read(bookingFormProvider.notifier).setFullName(_fullNameController.text);
    });
    _phoneController.addListener(() {
      ref.read(bookingFormProvider.notifier).setPhoneNumber(_phoneController.text);
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
      initialDate: (isStartDate ? formData.startDate : formData.endDate) ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)), // Tidak bisa pilih tanggal kemarin
      lastDate: DateTime.now().add(const Duration(days: 365)), // Batas 1 tahun ke depan
      builder: (context, child) { // Kustomisasi tema DatePicker
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: accentButtonColor, // Warna header
              onPrimary: Colors.black, // Warna teks di header
              surface: darkBackgroundColor, // Warna background
              onSurface: primaryTextColor, // Warna teks
            ),
            dialogBackgroundColor: const Color(0xFF121F12),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (isStartDate) {
        ref.read(bookingFormProvider.notifier).setStartDate(picked, widget.vehicle.rentalPricePerDay);
      } else {
        // Validasi end date tidak boleh sebelum start date
        if (formData.startDate != null && picked.isBefore(formData.startDate!)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('End date cannot be before start date.'), backgroundColor: Colors.orange),
          );
          return;
        }
        ref.read(bookingFormProvider.notifier).setEndDate(picked, widget.vehicle.rentalPricePerDay);
      }
    }
  }

  void _submitBooking() {
    if (_formKey.currentState!.validate()) {
      final formData = ref.read(bookingFormProvider);
      if (formData.startDate == null || formData.endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select start and end dates.'), backgroundColor: Colors.orange),
        );
        return;
      }
      // TODO: Implementasi logika submit booking ke Appwrite
      print('Booking Requested:');
      print('Car: ${widget.vehicle.name} (ID: ${widget.vehicle.id})');
      print('Start Date: ${formData.startDate}');
      print('End Date: ${formData.endDate}');
      print('Full Name: ${formData.fullName}');
      print('Phone: ${formData.phoneNumber}');
      print('Email: ${formData.email}');
      print('Total Price: \$${formData.totalPrice.toStringAsFixed(2)}');

      // Navigasi ke halaman konfirmasi pembayaran atau tampilkan pesan
      Navigator.of(context).pop(); // Kembali dulu dari form
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking request sent! You will be contacted for payment (Cash).'), backgroundColor: accentButtonColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formData = ref.watch(bookingFormProvider); // Watch untuk update UI harga
    final currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');

    return Scaffold(
      backgroundColor: darkBackgroundColor,
      appBar: AppBar(
        backgroundColor: darkBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Request booking', style: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: primaryTextColor),
            onPressed: () {
              // TODO: Tampilkan dialog bantuan atau info
              print('Help button tapped');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Your trip'),
              _buildDateField('Start date', formData.startDate, () => _selectDate(context, true)),
              const SizedBox(height: 16),
              _buildDateField('End date', formData.endDate, () => _selectDate(context, false)),
              const SizedBox(height: 24),

              _buildSectionTitle('Your details'),
              _buildTextField(label: 'Full name', controller: _fullNameController, hint: 'Enter your full name'),
              const SizedBox(height: 16),
              _buildTextField(label: 'Active phone number', controller: _phoneController, hint: 'Enter your phone number', keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildTextField(label: 'Email', controller: _emailController, hint: 'Enter your email', keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 24),

              _buildSectionTitle('Your car'),
              _buildCarSummary(widget.vehicle, currencyFormatter),
              const SizedBox(height: 16),

              _buildPriceDetail('Rental price', formData.rentalPrice, currencyFormatter),
              _buildPriceDetail('Taxes & fees', formData.taxesAndFees, currencyFormatter, isBold: false),
              const Divider(color: Colors.white24, height: 24),
              _buildPriceDetail('Total', formData.totalPrice, currencyFormatter, isTotal: true),

              const SizedBox(height: 80), // Ruang untuk tombol
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 20.0, right: 20.0, bottom: MediaQuery.of(context).viewInsets.bottom + 20.0, top: 10.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentButtonColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onPressed: _submitBooking,
          child: const Text('Request Booking', style: TextStyle(color: darkBackgroundColor)),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: primaryTextColor, fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDateField(String label, DateTime? date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: secondaryTextColor, fontSize: 14)),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            decoration: BoxDecoration(
              color: fieldBackgroundColor,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null ? _dateFormatter.format(date) : 'Select date',
                  style: TextStyle(color: date != null ? primaryTextColor : secondaryTextColor.withOpacity(0.7), fontSize: 15),
                ),
                const Icon(Icons.calendar_today_outlined, color: secondaryTextColor, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: secondaryTextColor, fontSize: 14)),
        const SizedBox(height: 6.0),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: primaryTextColor, fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: secondaryTextColor.withOpacity(0.7), fontSize: 15),
            filled: true,
            fillColor: fieldBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
             enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.2), width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                 borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: accentButtonColor, width: 1.5),
              ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          ),
          keyboardType: keyboardType,
          validator: validator ?? (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            if (label.toLowerCase().contains('email') && !value.contains('@')) {
                return 'Please enter a valid email';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCarSummary(Vehicle vehicle, NumberFormat formatter) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: vehicle.imageUrls.isNotEmpty
              ? Image.network(
                  vehicle.imageUrls.first,
                  width: 80,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (c,e,s) => Container(width: 80, height: 60, color: Colors.black26, child: const Icon(Icons.image_not_supported, color: Colors.white30)),
                )
              : Container(
                  width: 80,
                  height: 60,
                  color: Colors.black26,
                  child: const Icon(Icons.directions_car, color: Colors.white30, size: 30),
                ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vehicle.name,
                style: const TextStyle(color: primaryTextColor, fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${vehicle.year} • ${vehicle.capacity} seats', // Asumsi model Vehicle punya 'year'
                style: const TextStyle(color: secondaryTextColor, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceDetail(String label, double value, NumberFormat formatter, {bool isBold = true, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? primaryTextColor : secondaryTextColor,
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : (isBold ? FontWeight.w500 : FontWeight.normal),
            ),
          ),
          Text(
            formatter.format(value),
            style: TextStyle(
              color: primaryTextColor,
              fontSize: isTotal ? 18 : 15,
              fontWeight: isTotal ? FontWeight.bold : (isBold ? FontWeight.w600 : FontWeight.normal),
            ),
          ),
        ],
      ),
    );
  }
}

// Extension untuk capitalize string jika belum ada secara global
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

// --- Untuk Menjalankan Contoh Ini di main.dart atau halaman sebelumnya ---
/*
// Misalkan dari CustomerVehicleDetailScreen, saat tombol "Rent Now" ditekan:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => CustomerBookingFormScreen(
      vehicle: currentlySelectedVehicleObject, // Kirim objek Vehicle yang dipilih
    ),
  ),
);

// ATAU jika ingin menjalankan langsung untuk tes UI:
// di main.dart:
// home: CustomerBookingFormScreen(
//   vehicle: Vehicle( // Isi dengan data dummy Vehicle
//     id: 'car-xyz',
//     name: 'Mercedes-Benz C-Class',
//     imageUrls: ['https://via.placeholder.com/300x200.png/5F9EA0/FFFFFF?Text=Mercedes'],
//     rentalPricePerDay: 150,
//     year: 2023, // Tambahkan atribut ini ke model Vehicle jika belum
//     capacity: 4, // Tambahkan atribut ini ke model Vehicle jika belum
//     // ... atribut lain yang dibutuhkan
//   ),
// ),
*/