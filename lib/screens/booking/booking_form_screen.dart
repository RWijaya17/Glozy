import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/salon_model.dart'
    as salon_model; // Ubah alias menjadi salon_model
import '../../models/booking_model.dart' as booking;
import '../../utils/app_colors.dart';
import '../../providers/booking_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../home/main_navigation.dart';

class BookingFormScreen extends StatefulWidget {
  final salon_model.SalonModel salon; // Ubah ke salon_model
  final bool isHomeService;

  const BookingFormScreen({
    Key? key,
    required this.salon,
    required this.isHomeService,
  }) : super(key: key);

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;

  DateTime _selectedDate = DateTime.now();
  String _selectedTimeSlot = '';
  final List<salon_model.ServiceModel> _selectedServices =
      []; // Ubah ke salon_model
  bool _isLoading = false;

  final List<String> _timeSlots = [
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '12:00',
    '12:30',
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
    '16:30',
    '17:00',
    '17:30',
  ];

  // Tambahkan fungsi untuk konversi ServiceModel
  List<booking.ServiceModel> _convertServices(
      List<salon_model.ServiceModel> services) {
    // Ubah ke salon_model
    return services
        .map((service) => booking.ServiceModel(
              id: service.id,
              name: service.name,
              price: service.price,
              duration: service.duration,
            ))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _addressController = TextEditingController();
    _notesController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isHomeService && mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final user = authProvider.userModel;
        if (user != null && user.address != null && user.address!.isNotEmpty) {
          setState(() {
            _addressController.text = user.address!;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    try {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 30)),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.dark(
                primary: AppColors.secondary,
                surface: AppColors.primary,
                onSurface: AppColors.text,
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null && picked != _selectedDate) {
        setState(() {
          _selectedDate = picked;
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open date picker: ${e.toString()}',
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    }
  }

  double _calculateTotal() {
    // Base total dari semua service yang dipilih
    double total =
        _selectedServices.fold(0, (sum, service) => sum + service.price);

    // Tambahkan biaya home service jika diperlukan
    if (widget.isHomeService && _selectedServices.isNotEmpty) {
      total += 20000; // Biaya home service 20,000
    }

    return total;
  }

  void _toggleService(salon_model.ServiceModel service) {
    // Ubah ke salon_model
    setState(() {
      final index = _selectedServices.indexWhere((s) => s.id == service.id);
      if (index != -1) {
        _selectedServices.removeAt(index);
      } else {
        _selectedServices.add(service);
      }
    });
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedServices.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select at least one service',
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
      return;
    }

    if (_selectedTimeSlot.isEmpty) {
      Get.snackbar(
        'Error',
        'Please select a time slot',
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final bookingProvider =
          Provider.of<BookingProvider>(context, listen: false);

      if (authProvider.currentUser == null) {
        setState(() => _isLoading = false);
        Get.snackbar(
          'Error',
          'You need to be logged in to make a booking',
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
        );
        return;
      }

      // Pastikan alamat diisi jika home service
      if (widget.isHomeService && (_addressController.text.trim().isEmpty)) {
        setState(() => _isLoading = false);
        Get.snackbar(
          'Error',
          'Please enter your service address',
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
        );
        return;
      }

      // Konversi ServiceModel dari salon ke booking
      final convertedServices = _convertServices(_selectedServices);

      final newBooking = booking.BookingModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: authProvider.currentUser!.uid,
        salonId: widget.salon.id,
        salonName: widget.salon.name,
        salonAddress: widget.salon.address,
        salonImage: widget.salon.imageUrl,
        services: convertedServices, // Gunakan hasil konversi
        bookingDate: _selectedDate,
        timeSlot: _selectedTimeSlot,
        isHomeService: widget.isHomeService,
        customerAddress:
            widget.isHomeService ? _addressController.text.trim() : null,
        totalPrice: _calculateTotal(),
        status: booking.BookingStatus.pending,
        createdAt: DateTime.now(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      final success = await bookingProvider.createBooking(newBooking);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        Get.snackbar(
          'Success',
          'Booking created successfully',
          backgroundColor: AppColors.success,
          colorText: AppColors.white,
        );
        Get.offAll(() => const MainNavigation(),
            arguments: 2); // Navigate to MyOrders tab
      } else {
        Get.snackbar(
          'Error',
          'Failed to create booking. Please try again.',
          backgroundColor: AppColors.error,
          colorText: AppColors.white,
        );
      }
    } catch (e) {
      debugPrint('Error in _submitBooking: $e');

      if (!mounted) return;
      setState(() => _isLoading = false);

      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again later.',
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    }
  }

  Widget _buildServiceList() {
    if (widget.salon.services.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightGrey),
        ),
        child: const Center(
          child: Text(
            'No services available',
            style: TextStyle(color: AppColors.grey),
          ),
        ),
      );
    } else {
      return Column(
        children: widget.salon.services.map((service) {
          final isSelected = _selectedServices.any((s) => s.id == service.id);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: AppColors.secondary, width: 2)
                  : Border.all(color: AppColors.lightGrey),
            ),
            child: ListTile(
              onTap: () => _toggleService(service),
              leading: Checkbox(
                value: isSelected,
                onChanged: (_) => _toggleService(service),
                activeColor: AppColors.secondary,
              ),
              title: Text(
                service.name,
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                '${service.duration} min',
                style: const TextStyle(color: AppColors.grey),
              ),
              trailing: Text(
                'Rp ${service.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      );
    }
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightGrey),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.grey),
            const SizedBox(width: 12),
            Text(
              DateFormat('EEEE, MMMM d, y').format(_selectedDate),
              style: const TextStyle(color: AppColors.text),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: AppColors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _timeSlots.map((time) {
        final isSelected = _selectedTimeSlot == time;
        return InkWell(
          onTap: () {
            setState(() {
              _selectedTimeSlot = time;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.secondary : AppColors.primary,
              borderRadius: BorderRadius.circular(8),
              border:
                  isSelected ? null : Border.all(color: AppColors.lightGrey),
            ),
            child: Text(
              time,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.text,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.isHomeService ? 'Book Home Service' : 'Book Appointment',
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Services',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              _buildServiceList(),
              const SizedBox(height: 24),
              Text(
                'Select Date',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              _buildDateSelector(),
              const SizedBox(height: 24),
              Text(
                'Select Time',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              _buildTimeSelector(),
              if (widget.isHomeService) ...[
                const SizedBox(height: 24),
                Text(
                  'Your Address',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _addressController,
                  label: 'Service Address',
                  prefixIcon: Icons.location_on_outlined,
                  maxLines: 3,
                  validator: (value) {
                    if (widget.isHomeService &&
                        (value == null || value.isEmpty)) {
                      return 'Please enter your service address';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Notes (Optional)',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _notesController,
                label: 'Any special instructions?',
                prefixIcon: Icons.note_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Summary',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: AppColors.text,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ..._selectedServices.map((service) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                service.name,
                                style: TextStyle(color: AppColors.text),
                              ),
                            ),
                            Text(
                              'Rp ${service.price.toStringAsFixed(0)}',
                              style: TextStyle(color: AppColors.text),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    if (_selectedServices.isNotEmpty &&
                        widget.isHomeService) ...[
                      const Divider(height: 16, color: AppColors.lightGrey),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Home Service Fee',
                            style: TextStyle(color: AppColors.text),
                          ),
                          Text(
                            'Rp 20,000',
                            style: TextStyle(color: AppColors.text),
                          ),
                        ],
                      ),
                    ],
                    if (_selectedServices.isNotEmpty) ...[
                      const Divider(height: 16, color: AppColors.lightGrey),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'Rp ${_calculateTotal().toStringAsFixed(0)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Book Now',
                isLoading: _isLoading,
                enabled: _selectedServices.isNotEmpty,
                onPressed: () {
                  _submitBooking();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
