import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../utils/app_text.dart';
import '../../data/dummy_data.dart';
import '../../providers/demo_data_provider.dart';
import '../../providers/language_provider.dart';
import '../../services/local_storage_service.dart';
import '../../widgets/rich_text_editor.dart';
import '../../widgets/gradient_app_bar.dart';
import '../../widgets/gradient_button.dart';

class CreateEventScreen extends StatefulWidget {
  final String creatorId;
  final Map<String, dynamic>? event; // For editing

  const CreateEventScreen({
    super.key,
    required this.creatorId,
    this.event,
  });

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _titleEnController = TextEditingController();
  final _titleJaController = TextEditingController();
  final _descEnController = TextEditingController();
  final _descJaController = TextEditingController();
  final _locationEnController = TextEditingController();
  final _locationJaController = TextEditingController();
  final _venueEnController = TextEditingController();
  final _venueJaController = TextEditingController();
  final _venueAddressEnController = TextEditingController();
  final _venueAddressJaController = TextEditingController();
  final _malePriceController = TextEditingController();
  final _femalePriceController = TextEditingController();
  final _maleLimitController = TextEditingController();
  final _femaleLimitController = TextEditingController();
  final _mapLinkController = TextEditingController();

  // Focus nodes for auto-next field
  final _titleEnFocus = FocusNode();
  final _titleJaFocus = FocusNode();
  final _locationEnFocus = FocusNode();
  final _locationJaFocus = FocusNode();
  final _venueEnFocus = FocusNode();
  final _venueJaFocus = FocusNode();
  final _venueAddressEnFocus = FocusNode();
  final _venueAddressJaFocus = FocusNode();
  final _malePriceFocus = FocusNode();
  final _femalePriceFocus = FocusNode();
  final _maleLimitFocus = FocusNode();
  final _femaleLimitFocus = FocusNode();
  final _mapLinkFocus = FocusNode();

  // Validation error tracking
  final Map<String, bool> _fieldErrors = {};

  // Image lists (up to 10 images each)
  List<String> _imagesEn = [];
  List<String> _imagesJa = [];

  // Available demo images
  final List<String> _availableImages = [
    'assets/e1.jpg',
    'assets/e2.jpg',
    'assets/e3.jpg',
    'assets/e4.jpg',
  ];

  bool get _isEditing => widget.event != null;

  // ── Recurring event state ──────────────────────────────────────────────
  bool _isRecurring = false;
  // Each entry is a DateTime with both date and time set
  final List<DateTime> _recurringDateTimes = [];

  // ── Date / time pickers ─────────────────────────────────────────
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 18, minute: 0);
  DateTime _selectedEndDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _selectedEndTime = const TimeOfDay(hour: 23, minute: 0);

  Future<void> _pickDate() async {
    final now = DateTime.now();
    // When editing, allow past dates; when creating, start from today
    final firstDate =
        _isEditing && _selectedDate.isBefore(now) ? _selectedDate : now;

    final picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate.isBefore(firstDate) ? firstDate : _selectedDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    // When editing, allow past dates; when creating, start from selected start date
    final firstDate = _isEditing && _selectedDate.isBefore(now)
        ? _selectedDate
        : (_selectedDate.isBefore(now) ? now : _selectedDate);

    final picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedEndDate.isBefore(firstDate) ? firstDate : _selectedEndDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _selectedEndDate = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime,
    );
    if (picked != null) setState(() => _selectedEndTime = picked);
  }

  /// Pick a date+time for a new recurring slot and add to list.
  Future<void> _addRecurringSlot() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _recurringDateTimes.isEmpty
          ? _selectedDate
          : _recurringDateTimes.last.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _recurringDateTimes.isEmpty
          ? _selectedTime
          : TimeOfDay.fromDateTime(_recurringDateTimes.last),
    );
    if (time == null) return;

    setState(() {
      _recurringDateTimes.add(
        DateTime(date.year, date.month, date.day, time.hour, time.minute),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadEventData();
    } else {
      // Default images for new events
      _imagesEn = ['assets/e1.jpg', 'assets/e2.jpg'];
      _imagesJa = ['assets/e1.jpg', 'assets/e2.jpg'];
    }
  }

  void _loadEventData() {
    final event = widget.event!;
    _titleEnController.text = event['title_en'] ?? '';
    _titleJaController.text = event['title_ja'] ?? '';
    _descEnController.text = event['description_en'] ?? '';
    _descJaController.text = event['description_ja'] ?? '';
    _locationEnController.text = event['location_en'] ?? '';
    _locationJaController.text = event['location_ja'] ?? '';
    _venueEnController.text = event['venueName_en'] ?? event['venueName'] ?? '';
    _venueJaController.text = event['venueName_ja'] ?? event['venueName'] ?? '';
    _venueAddressEnController.text = event['venueAddress_en'] ?? '';
    _venueAddressJaController.text = event['venueAddress_ja'] ?? '';
    _malePriceController.text = event['malePrice']?.toString() ?? '0';
    _femalePriceController.text = event['femalePrice']?.toString() ?? '0';
    _maleLimitController.text = event['maleLimit']?.toString() ?? '50';
    _femaleLimitController.text = event['femaleLimit']?.toString() ?? '50';
    _mapLinkController.text = event['mapLink'] ?? '';

    // Load existing images
    _imagesEn = List<String>.from(event['images_en'] ?? []);
    _imagesJa = List<String>.from(event['images_ja'] ?? []);

    // Load existing date and time
    try {
      _selectedDate = DateTime.parse(event['date']);
      _selectedEndDate = event['endDate'] != null
          ? DateTime.parse(event['endDate'])
          : DateTime.parse(event['date']);

      final timeParts = (event['startTime'] as String? ?? '18:00').split(':');
      if (timeParts.length == 2) {
        _selectedTime = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        );
      }

      final endTimeParts = (event['endTime'] as String? ?? '23:00').split(':');
      if (endTimeParts.length == 2) {
        _selectedEndTime = TimeOfDay(
          hour: int.parse(endTimeParts[0]),
          minute: int.parse(endTimeParts[1]),
        );
      }
    } catch (e) {
      // Keep defaults if parsing fails
    }
  }

  @override
  void dispose() {
    _titleEnController.dispose();
    _titleJaController.dispose();
    _descEnController.dispose();
    _descJaController.dispose();
    _locationEnController.dispose();
    _locationJaController.dispose();
    _venueEnController.dispose();
    _venueJaController.dispose();
    _venueAddressEnController.dispose();
    _venueAddressJaController.dispose();
    _malePriceController.dispose();
    _femalePriceController.dispose();
    _maleLimitController.dispose();
    _femaleLimitController.dispose();
    _mapLinkController.dispose();

    _titleEnFocus.dispose();
    _titleJaFocus.dispose();
    _locationEnFocus.dispose();
    _locationJaFocus.dispose();
    _venueEnFocus.dispose();
    _venueJaFocus.dispose();
    _venueAddressEnFocus.dispose();
    _venueAddressJaFocus.dispose();
    _malePriceFocus.dispose();
    _femalePriceFocus.dispose();
    _maleLimitFocus.dispose();
    _femaleLimitFocus.dispose();
    _mapLinkFocus.dispose();

    super.dispose();
  }

  Future<void> _saveEvent() async {
    // Clear previous errors
    setState(() {
      _fieldErrors.clear();
    });

    // Validation with specific error messages
    final List<String> missingFields = [];

    if (_titleEnController.text.trim().isEmpty) {
      missingFields.add('Title (English)');
      _fieldErrors['titleEn'] = true;
    }
    if (_titleJaController.text.trim().isEmpty) {
      missingFields.add('Title (Japanese)');
      _fieldErrors['titleJa'] = true;
    }
    if (_locationEnController.text.trim().isEmpty) {
      missingFields.add('Location (English)');
      _fieldErrors['locationEn'] = true;
    }
    if (_locationJaController.text.trim().isEmpty) {
      missingFields.add('Location (Japanese)');
      _fieldErrors['locationJa'] = true;
    }
    if (_venueEnController.text.trim().isEmpty) {
      missingFields.add('Venue Name (English)');
      _fieldErrors['venueEn'] = true;
    }
    if (_venueJaController.text.trim().isEmpty) {
      missingFields.add('Venue Name (Japanese)');
      _fieldErrors['venueJa'] = true;
    }
    if (_imagesEn.isEmpty) {
      missingFields.add('Images (English)');
      _fieldErrors['imagesEn'] = true;
    }
    if (_imagesJa.isEmpty) {
      missingFields.add('Images (Japanese)');
      _fieldErrors['imagesJa'] = true;
    }
    if (_malePriceController.text.trim().isEmpty) {
      missingFields.add('Male Price');
      _fieldErrors['malePrice'] = true;
    }
    if (_femalePriceController.text.trim().isEmpty) {
      missingFields.add('Female Price');
      _fieldErrors['femalePrice'] = true;
    }
    if (_maleLimitController.text.trim().isEmpty) {
      missingFields.add('Male Ticket Limit');
      _fieldErrors['maleLimit'] = true;
    }
    if (_femaleLimitController.text.trim().isEmpty) {
      missingFields.add('Female Ticket Limit');
      _fieldErrors['femaleLimit'] = true;
    }

    if (missingFields.isNotEmpty) {
      setState(() {}); // Trigger rebuild to show red borders

      // Show detailed error message
      final errorMessage = missingFields.length == 1
          ? 'Missing field: ${missingFields[0]}'
          : 'Missing fields:\n${missingFields.map((f) => '• $f').join('\n')}';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    if (_isEditing) {
      // Update existing event
      final event = widget.event!;
      final newDate = _selectedDate.toIso8601String().substring(0, 10);

      event['date'] = newDate;

      event['title_en'] = _titleEnController.text;
      event['title_ja'] = _titleJaController.text;
      event['description_en'] = _descEnController.text;
      event['description_ja'] = _descJaController.text;
      event['location_en'] = _locationEnController.text;
      event['location_ja'] = _locationJaController.text;
      event['venueName_en'] = _venueEnController.text;
      event['venueName_ja'] = _venueJaController.text;
      event['venueName'] =
          _venueEnController.text; // Keep for backward compatibility
      event['venueAddress_en'] = _venueAddressEnController.text;
      event['venueAddress_ja'] = _venueAddressJaController.text;
      event['malePrice'] = int.tryParse(_malePriceController.text) ?? 0;
      event['femalePrice'] = int.tryParse(_femalePriceController.text) ?? 0;
      event['maleLimit'] = int.tryParse(_maleLimitController.text) ?? 50;
      event['femaleLimit'] = int.tryParse(_femaleLimitController.text) ?? 50;
      event['images_en'] = _imagesEn;
      event['images_ja'] = _imagesJa;
      event['mapLink'] = _mapLinkController.text.trim();
      final startTimeStr =
          '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
      final endTimeStr =
          '${_selectedEndTime.hour.toString().padLeft(2, '0')}:${_selectedEndTime.minute.toString().padLeft(2, '0')}';
      event['startTime'] = startTimeStr;
      event['endTime'] = endTimeStr;
      event['endDate'] = _selectedEndDate.toIso8601String().substring(0, 10);
    } else {
      final baseEvent = {
        'title_en': _titleEnController.text,
        'title_ja': _titleJaController.text,
        'description_en': _descEnController.text,
        'description_ja': _descJaController.text,
        'images_en': _imagesEn,
        'images_ja': _imagesJa,
        'location_en': _locationEnController.text,
        'location_ja': _locationJaController.text,
        'startTime': '18:00',
        'endTime': '22:00',
        'venueName_en': _venueEnController.text,
        'venueName_ja': _venueJaController.text,
        'venueName': _venueEnController.text, // Keep for backward compatibility
        'venueAddress_en': _venueAddressEnController.text,
        'venueAddress_ja': _venueAddressJaController.text,
        'mapLink': _mapLinkController.text.trim().isEmpty
            ? 'https://maps.google.com'
            : _mapLinkController.text.trim(),
        'malePrice': int.tryParse(_malePriceController.text) ?? 0,
        'femalePrice': int.tryParse(_femalePriceController.text) ?? 0,
        'maleLimit': int.tryParse(_maleLimitController.text) ?? 50,
        'femaleLimit': int.tryParse(_femaleLimitController.text) ?? 50,
        'maleBooked': 0,
        'femaleBooked': 0,
        'isHidden': false,
        'createdBy': widget.creatorId,
      };

      if (_isRecurring && _recurringDateTimes.isNotEmpty) {
        // One event per manually-picked date+time
        for (int i = 0; i < _recurringDateTimes.length; i++) {
          final dt = _recurringDateTimes[i];
          final timeStr =
              '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
          final copy = Map<String, dynamic>.from(baseEvent);
          copy['id'] = 'EVENT-${Random().nextInt(999999)}-$i';
          copy['date'] = dt.toIso8601String().substring(0, 10);
          copy['startTime'] = timeStr;
          copy['isRecurring'] = true;
          copy['recurringLabel'] = 'Recurring';
          DummyData.events.add(copy);
        }
      } else {
        final startTimeStr =
            '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
        final endTimeStr =
            '${_selectedEndTime.hour.toString().padLeft(2, '0')}:${_selectedEndTime.minute.toString().padLeft(2, '0')}';
        baseEvent['id'] = 'EVENT-${Random().nextInt(9999)}';
        baseEvent['date'] = _selectedDate.toIso8601String().substring(0, 10);
        baseEvent['endDate'] =
            _selectedEndDate.toIso8601String().substring(0, 10);
        baseEvent['startTime'] = startTimeStr;
        baseEvent['endTime'] = endTimeStr;
        DummyData.events.add(baseEvent);
      }
    }

    // Save to SharedPreferences
    await LocalStorageService.saveEvents();

    if (mounted) {
      // Notify other screens to refresh
      Provider.of<DemoDataProvider>(context, listen: false).notifyDataChanged();
      // Show snackbar BEFORE popping (context is still valid here)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppText.success(context))),
      );
      Navigator.pop(context, true); // Return true to refresh dashboard
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>(); // rebuild when language changes
    return Scaffold(
      appBar: GradientAppBar(
        title: Text(
          _isEditing
              ? AppText.editEvent(context)
              : AppText.createEvent(context),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // English Version
            Text(
              'English Version',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleEnController,
              focusNode: _titleEnFocus,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _titleJaFocus.requestFocus(),
              decoration: InputDecoration(
                labelText: 'Title (English) *',
                prefixIcon: const Icon(Icons.title),
                errorText: _fieldErrors['titleEn'] == true
                    ? 'This field is required'
                    : null,
                border: _fieldErrors['titleEn'] == true
                    ? const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      )
                    : null,
                enabledBorder: _fieldErrors['titleEn'] == true
                    ? const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      )
                    : null,
              ),
              onChanged: (value) {
                if (_fieldErrors['titleEn'] == true && value.isNotEmpty) {
                  setState(() => _fieldErrors.remove('titleEn'));
                }
              },
            ),
            const SizedBox(height: 16),
            RichTextEditor(
              controller: _descEnController,
              label: 'Description (English)',
              hint: 'Enter event description with formatting...',
              maxLines: 6,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationEnController,
              focusNode: _locationEnFocus,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _locationJaFocus.requestFocus(),
              decoration: InputDecoration(
                labelText: 'Location (English) *',
                prefixIcon: const Icon(Icons.location_on),
                errorText: _fieldErrors['locationEn'] == true
                    ? 'This field is required'
                    : null,
                border: _fieldErrors['locationEn'] == true
                    ? const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      )
                    : null,
                enabledBorder: _fieldErrors['locationEn'] == true
                    ? const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      )
                    : null,
              ),
              onChanged: (value) {
                if (_fieldErrors['locationEn'] == true && value.isNotEmpty) {
                  setState(() => _fieldErrors.remove('locationEn'));
                }
              },
            ),

            const SizedBox(height: 16),

            // English Images Section
            Row(
              children: [
                Text(
                  'Images (English) - Up to 10 *',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _fieldErrors['imagesEn'] == true
                            ? Colors.red
                            : null,
                      ),
                ),
                if (_fieldErrors['imagesEn'] == true) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.error, color: Colors.red, size: 20),
                ],
              ],
            ),
            if (_fieldErrors['imagesEn'] == true)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'At least one image is required',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.red,
                      ),
                ),
              ),
            const SizedBox(height: 8),
            _buildImageSelector(true),

            const SizedBox(height: 24),

            // Japanese Version
            Text(
              'Japanese Version',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleJaController,
              focusNode: _titleJaFocus,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _locationEnFocus.requestFocus(),
              decoration: InputDecoration(
                labelText: 'Title (Japanese) *',
                prefixIcon: const Icon(Icons.title),
                errorText: _fieldErrors['titleJa'] == true
                    ? 'This field is required'
                    : null,
                border: _fieldErrors['titleJa'] == true
                    ? const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      )
                    : null,
                enabledBorder: _fieldErrors['titleJa'] == true
                    ? const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      )
                    : null,
              ),
              onChanged: (value) {
                if (_fieldErrors['titleJa'] == true && value.isNotEmpty) {
                  setState(() => _fieldErrors.remove('titleJa'));
                }
              },
            ),
            const SizedBox(height: 16),
            RichTextEditor(
              controller: _descJaController,
              label: 'Description (Japanese)',
              hint: 'イベントの説明を入力してください...',
              maxLines: 6,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationJaController,
              focusNode: _locationJaFocus,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _venueEnFocus.requestFocus(),
              decoration: InputDecoration(
                labelText: 'Location (Japanese) *',
                prefixIcon: const Icon(Icons.location_on),
                errorText: _fieldErrors['locationJa'] == true
                    ? 'This field is required'
                    : null,
                border: _fieldErrors['locationJa'] == true
                    ? const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      )
                    : null,
                enabledBorder: _fieldErrors['locationJa'] == true
                    ? const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      )
                    : null,
              ),
              onChanged: (value) {
                if (_fieldErrors['locationJa'] == true && value.isNotEmpty) {
                  setState(() => _fieldErrors.remove('locationJa'));
                }
              },
            ),

            const SizedBox(height: 16),

            // Japanese Images Section
            Row(
              children: [
                Text(
                  'Images (Japanese) - Up to 10 *',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _fieldErrors['imagesJa'] == true
                            ? Colors.red
                            : null,
                      ),
                ),
                if (_fieldErrors['imagesJa'] == true) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.error, color: Colors.red, size: 20),
                ],
              ],
            ),
            if (_fieldErrors['imagesJa'] == true)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'At least one image is required',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.red,
                      ),
                ),
              ),
            const SizedBox(height: 8),
            _buildImageSelector(false),

            const SizedBox(height: 24),

            // Event Details
            Text(
              'Event Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _venueEnController,
              focusNode: _venueEnFocus,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _venueJaFocus.requestFocus(),
              decoration: InputDecoration(
                labelText: 'Venue Name (English) *',
                prefixIcon: const Icon(Icons.place),
                errorText: _fieldErrors['venueEn'] == true
                    ? 'This field is required'
                    : null,
                border: _fieldErrors['venueEn'] == true
                    ? const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      )
                    : null,
                enabledBorder: _fieldErrors['venueEn'] == true
                    ? const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      )
                    : null,
              ),
              onChanged: (value) {
                if (_fieldErrors['venueEn'] == true && value.isNotEmpty) {
                  setState(() => _fieldErrors.remove('venueEn'));
                }
              },
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _venueJaController,
              focusNode: _venueJaFocus,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _venueAddressEnFocus.requestFocus(),
              decoration: InputDecoration(
                labelText: 'Venue Name (Japanese) *',
                prefixIcon: const Icon(Icons.place),
                errorText: _fieldErrors['venueJa'] == true
                    ? 'This field is required'
                    : null,
                border: _fieldErrors['venueJa'] == true
                    ? const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      )
                    : null,
                enabledBorder: _fieldErrors['venueJa'] == true
                    ? const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red, width: 2),
                      )
                    : null,
              ),
              onChanged: (value) {
                if (_fieldErrors['venueJa'] == true && value.isNotEmpty) {
                  setState(() => _fieldErrors.remove('venueJa'));
                }
              },
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _venueAddressEnController,
              focusNode: _venueAddressEnFocus,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _venueAddressJaFocus.requestFocus(),
              decoration: const InputDecoration(
                labelText: 'Venue Address (English)',
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _venueAddressJaController,
              focusNode: _venueAddressJaFocus,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _mapLinkFocus.requestFocus(),
              decoration: const InputDecoration(
                labelText: 'Venue Address (Japanese)',
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 16),

            // Date picker
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(8),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Event Date',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _selectedDate.toIso8601String().substring(0, 10),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Time picker
            InkWell(
              onTap: _pickTime,
              borderRadius: BorderRadius.circular(8),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Start Time',
                  prefixIcon: Icon(Icons.access_time),
                ),
                child: Text(
                  _selectedTime.format(context),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // End Date picker
            InkWell(
              onTap: _pickEndDate,
              borderRadius: BorderRadius.circular(8),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'End Date',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  _selectedEndDate.toIso8601String().substring(0, 10),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // End Time picker
            InkWell(
              onTap: _pickEndTime,
              borderRadius: BorderRadius.circular(8),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'End Time',
                  prefixIcon: Icon(Icons.access_time),
                ),
                child: Text(
                  _selectedEndTime.format(context),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Google Maps Link
            TextField(
              controller: _mapLinkController,
              focusNode: _mapLinkFocus,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _malePriceFocus.requestFocus(),
              decoration: const InputDecoration(
                labelText: 'Google Maps Link',
                hintText: 'https://maps.google.com/?q=Tokyo+Japan',
                prefixIcon: Icon(Icons.map),
              ),
              keyboardType: TextInputType.url,
            ),

            const SizedBox(height: 24),

            // Pricing & Limits
            Text(
              'Pricing & Limits',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _malePriceController,
                    focusNode: _malePriceFocus,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _femalePriceFocus.requestFocus(),
                    decoration: InputDecoration(
                      labelText: 'Male Price (¥) *',
                      prefixIcon: const Icon(Icons.male),
                      errorText:
                          _fieldErrors['malePrice'] == true ? 'Required' : null,
                      border: _fieldErrors['malePrice'] == true
                          ? const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 2),
                            )
                          : null,
                      enabledBorder: _fieldErrors['malePrice'] == true
                          ? const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 2),
                            )
                          : null,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      if (_fieldErrors['malePrice'] == true &&
                          value.isNotEmpty) {
                        setState(() => _fieldErrors.remove('malePrice'));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _femalePriceController,
                    focusNode: _femalePriceFocus,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _maleLimitFocus.requestFocus(),
                    decoration: InputDecoration(
                      labelText: 'Female Price (¥) *',
                      prefixIcon: const Icon(Icons.female),
                      errorText: _fieldErrors['femalePrice'] == true
                          ? 'Required'
                          : null,
                      border: _fieldErrors['femalePrice'] == true
                          ? const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 2),
                            )
                          : null,
                      enabledBorder: _fieldErrors['femalePrice'] == true
                          ? const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 2),
                            )
                          : null,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      if (_fieldErrors['femalePrice'] == true &&
                          value.isNotEmpty) {
                        setState(() => _fieldErrors.remove('femalePrice'));
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _maleLimitController,
                    focusNode: _maleLimitFocus,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _femaleLimitFocus.requestFocus(),
                    decoration: InputDecoration(
                      labelText: 'Male Limit *',
                      prefixIcon: const Icon(Icons.people),
                      errorText:
                          _fieldErrors['maleLimit'] == true ? 'Required' : null,
                      border: _fieldErrors['maleLimit'] == true
                          ? const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 2),
                            )
                          : null,
                      enabledBorder: _fieldErrors['maleLimit'] == true
                          ? const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 2),
                            )
                          : null,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      if (_fieldErrors['maleLimit'] == true &&
                          value.isNotEmpty) {
                        setState(() => _fieldErrors.remove('maleLimit'));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _femaleLimitController,
                    focusNode: _femaleLimitFocus,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      labelText: 'Female Limit *',
                      prefixIcon: const Icon(Icons.people),
                      errorText: _fieldErrors['femaleLimit'] == true
                          ? 'Required'
                          : null,
                      border: _fieldErrors['femaleLimit'] == true
                          ? const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 2),
                            )
                          : null,
                      enabledBorder: _fieldErrors['femaleLimit'] == true
                          ? const OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 2),
                            )
                          : null,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      if (_fieldErrors['femaleLimit'] == true &&
                          value.isNotEmpty) {
                        setState(() => _fieldErrors.remove('femaleLimit'));
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── Recurring Event (new events only) ───────────────────────
            if (!_isEditing) ...[
              Text(
                'Recurring Event',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(AppText.repeatThisEvent(context)),
                subtitle: Text(
                  _isRecurring
                      ? '${_recurringDateTimes.length} date(s) added'
                      : 'Creates a single one-time event',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                value: _isRecurring,
                onChanged: (v) => setState(() {
                  _isRecurring = v;
                  if (!v) _recurringDateTimes.clear();
                }),
              ),
              if (_isRecurring) ...[
                const SizedBox(height: 8),

                // List of added date+time slots
                ..._recurringDateTimes.asMap().entries.map((entry) {
                  final i = entry.key;
                  final dt = entry.value;
                  final timeStr =
                      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                  final dateStr =
                      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      foregroundColor:
                          Theme.of(context).colorScheme.onPrimaryContainer,
                      child: Text('${i + 1}'),
                    ),
                    title: Text(dateStr,
                        style: Theme.of(context).textTheme.bodyLarge),
                    subtitle: Text('🕐 $timeStr',
                        style: Theme.of(context).textTheme.bodySmall),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Theme.of(context).colorScheme.error,
                      onPressed: () =>
                          setState(() => _recurringDateTimes.removeAt(i)),
                    ),
                  );
                }),

                // Add date+time button
                OutlinedButton.icon(
                  onPressed: _addRecurringSlot,
                  icon: const Icon(Icons.add),
                  label: Text(AppText.addDateTime(context)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),

                const SizedBox(height: 8),
              ],
              const Divider(height: 32),
            ],

            // Save Button
            GradientButton(
              onPressed: _saveEvent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(child: Text(AppText.save(context))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSelector(bool isEnglish) {
    final images = isEnglish ? _imagesEn : _imagesJa;
    final maxImages = 10;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected Images Display
        if (images.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: images.asMap().entries.map((entry) {
              final index = entry.key;
              final imagePath = entry.value;
              return Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        cacheWidth: 160,
                        cacheHeight: 160,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isEnglish) {
                            _imagesEn.removeAt(index);
                          } else {
                            _imagesJa.removeAt(index);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: Theme.of(context).colorScheme.onError,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),

        const SizedBox(height: 12),

        // Add Image Button
        if (images.length < maxImages)
          OutlinedButton.icon(
            onPressed: () => _showImagePicker(isEnglish),
            icon: const Icon(Icons.add_photo_alternate),
            label: Text(
              'Add Image (${images.length}/$maxImages)',
              style: const TextStyle(fontSize: 14),
            ),
          ),

        if (images.length >= maxImages)
          Text(
            'Maximum 10 images reached',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
      ],
    );
  }

  void _showImagePicker(bool isEnglish) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEnglish
            ? AppText.selectImageEn(context)
            : AppText.selectImageJa(context)),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _availableImages.length,
            itemBuilder: (context, index) {
              final imagePath = _availableImages[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isEnglish) {
                      if (!_imagesEn.contains(imagePath)) {
                        _imagesEn.add(imagePath);
                      }
                      // Clear error when image is added
                      _fieldErrors.remove('imagesEn');
                    } else {
                      if (!_imagesJa.contains(imagePath)) {
                        _imagesJa.add(imagePath);
                      }
                      // Clear error when image is added
                      _fieldErrors.remove('imagesJa');
                    }
                  });
                  Navigator.pop(context);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    cacheWidth: 200,
                    cacheHeight: 200,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppText.cancel(context)),
          ),
        ],
      ),
    );
  }
}
