import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../utils/app_text.dart';
import '../../widgets/gradient_app_bar.dart';
import 'checkin_history_screen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with WidgetsBindingObserver {
  late MobileScannerController cameraController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    cameraController = MobileScannerController();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Pause camera when app is in background
    if (state == AppLifecycleState.paused) {
      cameraController.stop();
    } else if (state == AppLifecycleState.resumed) {
      cameraController.start();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null) return;

    setState(() => _isProcessing = true);

    // Pre-capture all context-dependent values BEFORE any await call
    final invalidTitle = AppText.invalidTicket(context);
    final notFoundMsg = AppText.ticketNotFound(context);
    final checkInSuccessTitle = AppText.checkInSuccessful(context);
    final alreadyCheckedInTitle = AppText.alreadyCheckedIn(context);

    // Lookup reservation in Firestore by document ID
    Map<String, dynamic> ticket = {};
    try {
      final doc = await FirebaseFirestore.instance
          .collection('reservations')
          .doc(code)
          .get();
      if (doc.exists) {
        ticket = Map<String, dynamic>.from(doc.data()!);
        ticket['id'] = doc.id;
      }
    } catch (e) {
      debugPrint('Firestore QR lookup error: $e');
    }

    if (!mounted) return;

    if (ticket.isEmpty) {
      _showResultDialog(invalidTitle, notFoundMsg, false);
    } else {
      // Mark attendance in Firestore if not already checked in
      if (ticket['checkedInAt'] == null) {
        // Pre-capture all remaining context values before the next await
        final ticketDetailsMsg = AppText.ticketDetails(
          context,
          ticket['id'],
          ticket['userName'],
          ticket['gender'],
          ticket['eventTitle_en'],
        );
        final now = DateTime.now().toIso8601String();
        try {
          await FirebaseFirestore.instance
              .collection('reservations')
              .doc(code)
              .update({'checkedInAt': now, 'isScanned': true});
          ticket['checkedInAt'] = now;
          if (!mounted) return;
          _showResultDialog(checkInSuccessTitle, ticketDetailsMsg, true);
        } catch (e) {
          debugPrint('Check-in update error: $e');
          if (!mounted) return;
          _showResultDialog(
            'Check-in Failed',
            'Could not confirm check-in. Make sure you are logged in as admin.\nError: $e',
            false,
          );
        }
      } else {
        final checkedInTime = DateTime.parse(ticket['checkedInAt']);
        final timeStr =
            '${checkedInTime.hour}:${checkedInTime.minute.toString().padLeft(2, '0')}';
        final alreadyAtMsg = AppText.alreadyCheckedInAt(context, timeStr);
        _showResultDialog(alreadyCheckedInTitle, alreadyAtMsg, false);
      }
    }

    // Reset processing after delay
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isProcessing = false);
    }
  }

  void _showResultDialog(String title, String message, bool success) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: success ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppText.ok(context)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: Text(
          AppText.scanTicketQR(context),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CheckinHistoryScreen(),
                ),
              );
            },
            tooltip: 'Check-in History',
          ),
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
            tooltip: AppText.toggleFlash(context),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => cameraController.switchCamera(),
            tooltip: AppText.switchCamera(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
          ),
          // Overlay with scanning area
          CustomPaint(
            painter: ScannerOverlay(),
            child: Container(),
          ),
          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                AppText.scanInstruction(context),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final scanArea = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 250,
      height: 250,
    );

    // Draw overlay with transparent center
    canvas.drawPath(
      Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addRRect(RRect.fromRectAndRadius(scanArea, const Radius.circular(12)))
        ..fillType = PathFillType.evenOdd,
      paint,
    );

    // Draw corner borders
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    const cornerLength = 30.0;

    // Top-left
    canvas.drawLine(
      Offset(scanArea.left, scanArea.top),
      Offset(scanArea.left + cornerLength, scanArea.top),
      borderPaint,
    );
    canvas.drawLine(
      Offset(scanArea.left, scanArea.top),
      Offset(scanArea.left, scanArea.top + cornerLength),
      borderPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(scanArea.right, scanArea.top),
      Offset(scanArea.right - cornerLength, scanArea.top),
      borderPaint,
    );
    canvas.drawLine(
      Offset(scanArea.right, scanArea.top),
      Offset(scanArea.right, scanArea.top + cornerLength),
      borderPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(scanArea.left, scanArea.bottom),
      Offset(scanArea.left + cornerLength, scanArea.bottom),
      borderPaint,
    );
    canvas.drawLine(
      Offset(scanArea.left, scanArea.bottom),
      Offset(scanArea.left, scanArea.bottom - cornerLength),
      borderPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(scanArea.right, scanArea.bottom),
      Offset(scanArea.right - cornerLength, scanArea.bottom),
      borderPaint,
    );
    canvas.drawLine(
      Offset(scanArea.right, scanArea.bottom),
      Offset(scanArea.right, scanArea.bottom - cornerLength),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
