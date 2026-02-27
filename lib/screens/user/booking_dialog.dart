import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../utils/app_text.dart';
import '../../data/dummy_data.dart';
import '../../services/local_storage_service.dart';
import '../../services/local_notification_service.dart';
import '../../providers/demo_data_provider.dart';
import '../../providers/language_provider.dart';

class BookingDialog extends StatefulWidget {
  final Map<String, dynamic> event;

  const BookingDialog({
    super.key,
    required this.event,
  });

  @override
  State<BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog> {
  final _nameController = TextEditingController();
  String _selectedGender = 'male';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _confirmBooking() async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final errorColor = Theme.of(context).colorScheme.error;

    // Get text values before async operations
    final errorText = AppText.error(context);
    final alreadyBookedText = AppText.alreadyBooked(context);
    final bookingSuccessText = AppText.bookingSuccess(context);

    if (_nameController.text.trim().isEmpty) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(errorText)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check if already booked using SharedPreferences
      final hasBooked = await LocalStorageService.hasBookedEvent(
        widget.event['id'],
      );

      if (hasBooked) {
        throw Exception(alreadyBookedText);
      }

      // Check gender limit
      final maleLimit = widget.event['maleLimit'] as int;
      final femaleLimit = widget.event['femaleLimit'] as int;
      final maleBooked = widget.event['maleBooked'] as int? ?? 0;
      final femaleBooked = widget.event['femaleBooked'] as int? ?? 0;

      if (_selectedGender == 'male' && maleBooked >= maleLimit) {
        throw Exception('Sold out for males');
      }

      if (_selectedGender == 'female' && femaleBooked >= femaleLimit) {
        throw Exception('Sold out for females');
      }

      // Simulate booking process
      await Future.delayed(const Duration(seconds: 1));

      // Create ticket
      final ticket = {
        'id': 'TICKET-${Random().nextInt(999999).toString().padLeft(6, '0')}',
        'eventId': widget.event['id'],
        'eventTitle_en': widget.event['title_en'],
        'eventTitle_ja': widget.event['title_ja'],
        'eventDate': widget.event['date'],
        'eventTime': widget.event['startTime'],
        'eventImage': widget.event['images_en'][0], // First image
        'userName': _nameController.text.trim(),
        'gender': _selectedGender,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Save to dummy data
      DummyData.tickets.add(ticket);

      // Increment booked count
      if (_selectedGender == 'male') {
        widget.event['maleBooked'] = (maleBooked + 1);
      } else {
        widget.event['femaleBooked'] = (femaleBooked + 1);
      }

      // Save to SharedPreferences
      await LocalStorageService.saveTickets();
      await LocalStorageService.saveEvents();
      await LocalStorageService.markEventAsBooked(widget.event['id']);

      // Schedule reminder notifications
      try {
        final eventDateTime = DateTime.parse(
          '${widget.event['date']} ${widget.event['startTime']}',
        );
        await LocalNotificationService().scheduleEventReminders(
          eventId: widget.event['id'],
          eventTitle: widget.event['title_en'],
          eventDateTime: eventDateTime,
        );
      } catch (e) {
        debugPrint('⚠️ Failed to schedule notifications: $e');
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (mounted) {
        // Notify other screens to refresh
        Provider.of<DemoDataProvider>(context, listen: false)
            .notifyDataChanged();

        navigator.pop(); // Close dialog only (stay on event details)

        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(bookingSuccessText),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>(); // rebuild when language changes
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppText.bookTicket(context),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 24),

            // Name Input
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: AppText.yourName(context),
                prefixIcon: const Icon(Icons.person),
              ),
            ),

            const SizedBox(height: 16),

            // Gender Selection
            Text(
              AppText.selectGender(context),
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedGender = 'male'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedGender == 'male'
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).dividerColor,
                          width: _selectedGender == 'male' ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: _selectedGender == 'male'
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _selectedGender == 'male'
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: _selectedGender == 'male'
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).iconTheme.color,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppText.male(context),
                            style: TextStyle(
                              fontWeight: _selectedGender == 'male'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: _selectedGender == 'male'
                                  ? Theme.of(context).primaryColor
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedGender = 'female'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedGender == 'female'
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).dividerColor,
                          width: _selectedGender == 'female' ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: _selectedGender == 'female'
                            ? Theme.of(context).primaryColor.withOpacity(0.1)
                            : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _selectedGender == 'female'
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: _selectedGender == 'female'
                                ? Theme.of(context).primaryColor
                                : Theme.of(context).iconTheme.color,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppText.female(context),
                            style: TextStyle(
                              fontWeight: _selectedGender == 'female'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: _selectedGender == 'female'
                                  ? Theme.of(context).primaryColor
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      AppText.cancel(context),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _confirmBooking,
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        : Text(AppText.confirmBooking(context)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
