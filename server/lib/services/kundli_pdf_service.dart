import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import '../core/theme/app_theme.dart';

class KundliPdfService {
  static Future<Uint8List> generatePdf({
    required String name,
    required DateTime dateOfBirth,
    required String placeOfBirth,
    required String timeOfBirth,
    required String lagnaSign,
    required Map<int, String> houses,
    required Map<String, String> planets,
  }) async {
    final pdf = pw.Document();
    
    // Load logo image (we'll create a placeholder for now)
    final logoImage = await _createLogoImage();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // Header with Logo
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                if (logoImage != null)
                  pw.Image(logoImage, width: 60, height: 60),
                pw.SizedBox(width: 20),
                pw.Text(
                  'VEDIC MATE',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.orange,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.SizedBox(height: 20),
            
            // Title
            pw.Center(
              child: pw.Text(
                'DIGITAL KUNDLI',
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.orange,
                ),
              ),
            ),
            pw.SizedBox(height: 30),
            
            // Personal Details Section
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.orange, width: 2),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Personal Details',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.orange,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  _buildDetailRow('Name', name),
                  _buildDetailRow(
                    'Date of Birth',
                    '${dateOfBirth.day}/${dateOfBirth.month}/${dateOfBirth.year}',
                  ),
                  _buildDetailRow('Time of Birth', timeOfBirth),
                  _buildDetailRow('Place of Birth', placeOfBirth),
                ],
              ),
            ),
            pw.SizedBox(height: 30),
            
            // Lagna Chart Section
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.orange, width: 2),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(
                children: [
                  pw.Text(
                    'Lagna Chart (Birth Chart)',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.orange,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  _buildLagnaChart(lagnaSign, houses, planets),
                ],
              ),
            ),
            pw.SizedBox(height: 30),
            
            // Planetary Positions
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.orange, width: 2),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Planetary Positions',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.orange,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  ...planets.entries.map((entry) => 
                    _buildDetailRow(entry.key, entry.value)
                  ).toList(),
                ],
              ),
            ),
            pw.SizedBox(height: 30),
            
            // Houses Information
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.orange, width: 2),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Houses',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.orange,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: houses.entries.map((entry) => 
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.orange),
                          borderRadius: pw.BorderRadius.circular(5),
                        ),
                        child: pw.Text(
                          'House ${entry.key}: ${entry.value}',
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                      ),
                    ).toList(),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 40),
            
            // Footer with Watermark
            pw.Container(
              alignment: pw.Alignment.center,
              child: pw.Column(
                children: [
                  pw.Divider(),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      if (logoImage != null)
                        pw.Image(logoImage, width: 30, height: 30),
                      pw.SizedBox(width: 10),
                      pw.Text(
                        'Generated by Vedic Mate',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey600,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    '© ${DateTime.now().year} Vedic Mate. All rights reserved.',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );
    
    return pdf.save();
  }
  
  static pw.Widget _buildDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildLagnaChart(
    String lagnaSign,
    Map<int, String> houses,
    Map<String, String> planets,
  ) {
    return pw.Container(
      height: 300,
      width: 300,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.orange, width: 2),
      ),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            'Lagna Chart',
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 20),
          pw.Text(
            'Visual representation of the 12 houses',
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 20),
          // Simple grid representation
          pw.GridView(
            crossAxisCount: 3,
            childAspectRatio: 1,
            children: List.generate(9, (index) {
              final houseNum = index + 1;
              final sign = houses[houseNum] ?? '';
              return pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.orange, width: 1),
                ),
                child: pw.Center(
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text(
                        '$houseNum',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.orange,
                        ),
                      ),
                      pw.Text(
                        sign,
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
  
  static Future<pw.MemoryImage?> _createLogoImage() async {
    try {
      // Create a simple logo representation
      // In production, load actual logo asset
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final size = Size(100, 100);
      
      // Draw circular background
      final paint = Paint()
        ..color = Color(0xFFFFB800) // Orange
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, paint);
      
      // Draw simple Vedic Mate text representation
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'VM',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (size.width - textPainter.width) / 2,
          (size.height - textPainter.height) / 2,
        ),
      );
      
      final picture = recorder.endRecording();
      final image = await picture.toImage(size.width.toInt(), size.height.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();
      
      return pw.MemoryImage(bytes);
    } catch (e) {
      return null;
    }
  }
}


