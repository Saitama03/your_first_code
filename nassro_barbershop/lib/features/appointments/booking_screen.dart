import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/supabase_repository.dart';
import '../../data/models/models.dart';

final _servicesProvider = FutureProvider<List<ServiceModel>>((ref) async {
  return SupabaseRepository(Supabase.instance.client).getServices();
});

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  ServiceModel? selectedService;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool submitting = false;
  String? errorText;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      initialDate: selectedDate ?? now,
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  Future<void> _submit() async {
    if (selectedService == null ||
        selectedDate == null ||
        selectedTime == null) {
      setState(() => errorText = 'Please select service, date and time');
      return;
    }
    setState(() {
      errorText = null;
      submitting = true;
    });

    final startAt = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );
    final endAt =
        startAt.add(Duration(minutes: selectedService!.durationMinutes));

    try {
      await SupabaseRepository(Supabase.instance.client).bookAppointment(
        serviceId: selectedService!.id,
        startAt: startAt,
        endAt: endAt,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => errorText = e.toString());
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(_servicesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Book Appointment')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (errorText != null)
              Text(errorText!, style: const TextStyle(color: Colors.red)),
            servicesAsync.when(
              data: (services) {
                return DropdownButtonFormField<ServiceModel>(
                  value: selectedService,
                  hint: const Text('Select Service'),
                  items: services
                      .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(
                              '${s.name} — € ${(s.priceCents / 100).toStringAsFixed(2)}')))
                      .toList(),
                  onChanged: (v) => setState(() => selectedService = v),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Failed to load services: $e'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_month),
                    label: Text(selectedDate == null
                        ? 'Pick date'
                        : DateFormat.yMMMEd().format(selectedDate!)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.schedule),
                    label: Text(selectedTime == null
                        ? 'Pick time'
                        : selectedTime!.format(context)),
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: submitting ? null : _submit,
                child: Text(submitting ? 'Booking...' : 'Book Appointment'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
