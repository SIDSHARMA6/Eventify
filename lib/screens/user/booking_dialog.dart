import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_text.dart';
import '../../utils/input_validator.dart';
import '../../services/ticket_service.dart';
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

    // FIX L-10: check isHidden before async call — give immediate UX feedback
    if (widget.event['isHidden'] == true) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: const Text('This event is no longer available for booking.'),
          backgroundColor: errorColor,
        ),
      );
      return;
    }

    final bookingSuccessText = AppText.bookingSuccess(context);

    // Validate name using centralized validator
    final nameError = InputValidator.validateUserName(_nameController.text);
    if (nameError != null) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text(nameError), backgroundColor: errorColor),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create reservation in Firestore (service checks limits + duplicates)
      await TicketService().createReservation(
        eventId: widget.event['id'],
        userName: _nameController.text.trim(),
        gender: _selectedGender,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      navigator.pop();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(bookingSuccessText),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    context.read<LanguageProvider>();
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
                            ? Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.1)
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
                            ? Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.1)
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
