import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../utils/app_text.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../services/ticket_service.dart';
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
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null) return;

    setState(() => _isProcessing = true);

    // Pre-capture context-dependent strings before any await
    final invalidTitle = AppText.invalidTicket(context);
    final notFoundMsg = AppText.ticketNotFound(context);
    final checkInSuccessTitle = AppText.checkInSuccessful(context);
    final alreadyCheckedInTitle = AppText.alreadyCheckedIn(context);
    final noPermissionMsg =
        'You must be logged in as admin or creator to check in tickets.';

    // Admin or Creator role check
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isAdmin && !auth.isCreator) {
      _showResultDialog(invalidTitle, noPermissionMsg, false);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _isProcessing = false);
      return;
    }

    try {
      final ticket = await TicketService().checkIn(code);
      if (!mounted) return;
      final details = AppText.ticketDetails(
        context,
        ticket['id'],
        ticket['userName'],
        ticket['gender'],
        ticket['eventTitle_en'],
      );
      _showResultDialog(checkInSuccessTitle, details, true);
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      if (msg.contains('ticket_not_found')) {
        _showResultDialog(invalidTitle, notFoundMsg, false);
      } else if (msg.contains('already_checked_in:')) {
        final timeRaw = msg.split('already_checked_in:').last;
        try {
          final dt = DateTime.parse(timeRaw);
          final timeStr = '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
          _showResultDialog(alreadyCheckedInTitle,
              AppText.alreadyCheckedInAt(context, timeStr), false);
        } catch (_) {
          _showResultDialog(
              alreadyCheckedInTitle, 'Already checked in.', false);
        }
      } else {
        _showResultDialog('Check-in Failed', msg, false);
      }
    }

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _isProcessing = false);
  }

  void _showResultDialog(String title, String message, bool success) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(success ? Icons.check_circle : Icons.error,
                color: success ? Colors.green : Colors.red),
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
    context.watch<LanguageProvider>();
    return Scaffold(
      appBar: GradientAppBar(
        title: Text(AppText.scanTicketQR(context),
            style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CheckinHistoryScreen())),
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
          MobileScanner(controller: cameraController, onDetect: _onDetect),
          CustomPaint(painter: ScannerOverlay(), child: Container()),
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
                style: const TextStyle(color: Colors.white, fontSize: 14),
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

    canvas.drawPath(
      Path()
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..addRRect(RRect.fromRectAndRadius(scanArea, const Radius.circular(12)))
        ..fillType = PathFillType.evenOdd,
      paint,
    );

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    const c = 30.0;
    final l = scanArea.left;
    final r = scanArea.right;
    final t = scanArea.top;
    final b = scanArea.bottom;

    canvas.drawLine(Offset(l, t), Offset(l + c, t), borderPaint);
    canvas.drawLine(Offset(l, t), Offset(l, t + c), borderPaint);
    canvas.drawLine(Offset(r, t), Offset(r - c, t), borderPaint);
    canvas.drawLine(Offset(r, t), Offset(r, t + c), borderPaint);
    canvas.drawLine(Offset(l, b), Offset(l + c, b), borderPaint);
    canvas.drawLine(Offset(l, b), Offset(l, b - c), borderPaint);
    canvas.drawLine(Offset(r, b), Offset(r - c, b), borderPaint);
    canvas.drawLine(Offset(r, b), Offset(r, b - c), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
