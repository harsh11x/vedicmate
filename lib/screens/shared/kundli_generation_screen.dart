import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';

class KundliGenerationScreen extends StatefulWidget {
  final String name;
  final DateTime dateOfBirth;
  final String placeOfBirth;
  final String timeOfBirth;

  const KundliGenerationScreen({
    super.key,
    required this.name,
    required this.dateOfBirth,
    required this.placeOfBirth,
    required this.timeOfBirth,
  });

  @override
  State<KundliGenerationScreen> createState() => _KundliGenerationScreenState();
}

class _KundliGenerationScreenState extends State<KundliGenerationScreen> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _isGenerating = false;
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Digital Kundli'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadKundli,
            tooltip: 'Download Kundli',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareKundli,
            tooltip: 'Share Kundli',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Welcome Message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: AppTheme.yellowPrimary.withOpacity(0.1),
              child: Column(
                children: [
                  const Icon(
                    Icons.celebration,
                    size: 48,
                    color: AppTheme.yellowPrimary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome to Vedic Mate!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your Digital Kundli is ready as a welcome gift!',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Kundli Display
            RepaintBoundary(
              key: _repaintKey,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  border: Border.all(color: AppTheme.yellowPrimary, width: 2),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header
                    Text(
                      'KUNDLI',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.yellowPrimary,
                          ),
                    ),
                    const Divider(height: 32),
                    // Personal Details
                    _KundliSection(
                      title: 'Personal Details',
                      children: [
                        _KundliRow(label: 'Name', value: widget.name),
                        _KundliRow(
                          label: 'Date of Birth',
                          value: '${widget.dateOfBirth.day}/${widget.dateOfBirth.month}/${widget.dateOfBirth.year}',
                        ),
                        _KundliRow(label: 'Time of Birth', value: widget.timeOfBirth),
                        _KundliRow(label: 'Place of Birth', value: widget.placeOfBirth),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Planetary Positions (Mock Data)
                    _KundliSection(
                      title: 'Planetary Positions',
                      children: [
                        _KundliRow(label: 'Sun', value: 'Leo 15°'),
                        _KundliRow(label: 'Moon', value: 'Cancer 22°'),
                        _KundliRow(label: 'Mars', value: 'Aries 8°'),
                        _KundliRow(label: 'Mercury', value: 'Virgo 12°'),
                        _KundliRow(label: 'Jupiter', value: 'Sagittarius 18°'),
                        _KundliRow(label: 'Venus', value: 'Libra 25°'),
                        _KundliRow(label: 'Saturn', value: 'Capricorn 10°'),
                        _KundliRow(label: 'Rahu', value: 'Pisces 5°'),
                        _KundliRow(label: 'Ketu', value: 'Virgo 5°'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Houses (Mock Data)
                    _KundliSection(
                      title: 'Houses',
                      children: [
                        _KundliRow(label: 'Ascendant (Lagna)', value: 'Aries'),
                        _KundliRow(label: '2nd House', value: 'Taurus'),
                        _KundliRow(label: '7th House', value: 'Libra'),
                        _KundliRow(label: '10th House', value: 'Capricorn'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Watermark
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        'Vedic Mate',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: _downloadKundli,
                    icon: const Icon(Icons.download),
                    label: const Text('Download Kundli'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.yellowPrimary,
                      foregroundColor: AppTheme.textDark,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _shareKundli,
                    icon: const Icon(Icons.share),
                    label: const Text('Share Kundli'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppTheme.yellowPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadKundli() async {
    setState(() => _isDownloading = true);
    try {
      // Capture the widget as image
      final RenderRepaintBoundary boundary =
          _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Save to device
      final Directory directory = await getApplicationDocumentsDirectory();
      final String fileName = 'Kundli_${widget.name}_${DateTime.now().millisecondsSinceEpoch}.png';
      final File file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pngBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kundli saved to: ${file.path}'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }

  Future<void> _shareKundli() async {
    try {
      // Capture and share
      final RenderRepaintBoundary boundary =
          _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final Directory directory = await getTemporaryDirectory();
      final String fileName = 'Kundli_${widget.name}.png';
      final File file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(file.path)], text: 'My Digital Kundli from Vedic Mate');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }
}

class _KundliSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _KundliSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.yellowPrimary,
              ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class _KundliRow extends StatelessWidget {
  final String label;
  final String value;

  const _KundliRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

