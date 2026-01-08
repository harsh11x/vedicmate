import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class KundliPdfService {
  static const PdfColor primaryColor = PdfColor.fromInt(0xFFFF7A00);
  static const PdfColor secondaryColor = PdfColor.fromInt(0xFF2D2D2D);

  /// Generate PDF with chart images captured from actual widgets
  static Future<Uint8List> generatePdf({
    required String name,
    required DateTime dateOfBirth,
    required String placeOfBirth,
    required String timeOfBirth,
    required String lagnaSign,
    required Map<int, String> houses,
    required Map<String, String> planets,
    bool allPages = true,
    // Chart images captured from the app
    Uint8List? lagnaChartImage,
    Uint8List? navamshaChartImage,
    Uint8List? moonChartImage,
    Uint8List? chalitChartImage,
  }) async {
    final pdf = pw.Document();
    
    final logoImage = await _createLogoImage();
    
    final pageTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(30),
      buildBackground: (context) => _buildWatermark(logoImage),
      theme: pw.ThemeData.withFont(
        base: await PdfGoogleFonts.outfitRegular(),
        bold: await PdfGoogleFonts.outfitBold(),
      ),
    );

    // Page 1: Cover + BIG Lagna Chart
    pdf.addPage(
      pw.Page(
        pageTheme: pageTheme,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
               _buildHeader(logoImage),
               pw.SizedBox(height: 15),
               _buildTitle('VEDIC HOROSCOPE'),
               pw.SizedBox(height: 15),
               _buildPersonalDetails(name, dateOfBirth, timeOfBirth, placeOfBirth),
               pw.SizedBox(height: 15),
               // BIG Lagna Chart - occupies most of the page
               pw.Expanded(
                 child: pw.Center(
                   child: pw.Column(
                     mainAxisAlignment: pw.MainAxisAlignment.center,
                     children: [
                       pw.Container(
                         padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                         decoration: pw.BoxDecoration(
                           color: primaryColor,
                           borderRadius: pw.BorderRadius.circular(6),
                         ),
                         child: pw.Text('LAGNA CHART (D-1)', 
                           style: pw.TextStyle(color: PdfColors.white, fontSize: 14, fontWeight: pw.FontWeight.bold)),
                       ),
                       pw.SizedBox(height: 10),
                       if (lagnaChartImage != null)
                         pw.Image(pw.MemoryImage(lagnaChartImage), width: 350, height: 350)
                       else
                         _buildDetailedLagnaChart(lagnaSign, houses, planets, 350),
                       pw.SizedBox(height: 8),
                       pw.Text('D-1: Birth Chart showing ascendant and planetary positions',
                         style: pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
                     ],
                   ),
                 ),
               ),
               _buildFooter(),
            ]
          );
        }
      )
    );

    if (allPages) {
       // Page 2: All 4 Charts (2x2 grid)
       pdf.addPage(
         pw.Page(
           pageTheme: pageTheme,
           build: (pw.Context context) {
             return pw.Column(
               children: [
                 _buildSectionHeader('KUNDLI CHARTS'),
                 pw.SizedBox(height: 15),
                 pw.Expanded(
                   child: pw.Row(
                     crossAxisAlignment: pw.CrossAxisAlignment.start,
                     children: [
                       // Left column
                       pw.Expanded(
                         child: pw.Column(
                           children: [
                             _buildChartCard('Lagna Chart (D-1)', lagnaChartImage, 
                               _buildDetailedLagnaChart(lagnaSign, houses, planets, 200), primaryColor),
                             pw.SizedBox(height: 15),
                             _buildChartCard('Moon Chart', moonChartImage, 
                               _buildDetailedMoonChart(200), PdfColor.fromInt(0xFF1565C0)),
                           ],
                         ),
                       ),
                       pw.SizedBox(width: 15),
                       // Right column  
                       pw.Expanded(
                         child: pw.Column(
                           children: [
                             _buildChartCard('Navamsha (D-9)', navamshaChartImage, 
                               _buildDetailedNavamshaChart(200), PdfColor.fromInt(0xFF8D1B3D)),
                             pw.SizedBox(height: 15),
                             _buildChartCard('Chalit Chart', chalitChartImage, 
                               _buildDetailedChalitChart(200), PdfColor.fromInt(0xFF2E7D32)),
                           ],
                         ),
                       ),
                     ],
                   ),
                 ),
                 _buildFooter(),
               ],
             );
           }
         )
       );

       // Page 3: Tables
       pdf.addPage(
         pw.MultiPage(
           pageTheme: pageTheme,
           build: (pw.Context context) {
             return [
               _buildSectionHeader('PLANETARY POSITIONS'),
               pw.SizedBox(height: 12),
               _buildPlanetaryTable(planets),
               pw.SizedBox(height: 20),
               _buildSectionHeader('HOUSE DETAILS (BHAVA)'),
               pw.SizedBox(height: 12),
               _buildHousesTable(houses),
               pw.SizedBox(height: 20),
               _buildFooter(),
             ];
           }
         )
       );
    }
    
    return pdf.save();
  }

  static pw.Widget _buildChartCard(String title, Uint8List? image, pw.Widget fallback, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 1),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            decoration: pw.BoxDecoration(
              color: color,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Center(
              child: pw.Text(title, style: pw.TextStyle(color: PdfColors.white, fontSize: 10, fontWeight: pw.FontWeight.bold)),
            ),
          ),
          pw.SizedBox(height: 8),
          if (image != null)
            pw.Image(pw.MemoryImage(image), width: 200, height: 200)
          else
            fallback,
        ],
      ),
    );
  }

  // Detailed Lagna Chart with all signs and planets
  static pw.Widget _buildDetailedLagnaChart(String lagnaSign, Map<int, String> houses, Map<String, String> planets, double size) {
    // House positions in North Indian chart (center points as fractions)
    final houseData = [
      {'pos': [0.5, 0.15], 'sign': houses[1] ?? 'Ari'},  // 1 - Top center
      {'pos': [0.2, 0.08], 'sign': houses[2] ?? 'Tau'},  // 2 - Top left
      {'pos': [0.08, 0.2], 'sign': houses[3] ?? 'Gem'}, // 3 - Left top
      {'pos': [0.15, 0.5], 'sign': houses[4] ?? 'Can'}, // 4 - Left center
      {'pos': [0.08, 0.8], 'sign': houses[5] ?? 'Leo'}, // 5 - Left bottom
      {'pos': [0.2, 0.92], 'sign': houses[6] ?? 'Vir'}, // 6 - Bottom left
      {'pos': [0.5, 0.85], 'sign': houses[7] ?? 'Lib'}, // 7 - Bottom center
      {'pos': [0.8, 0.92], 'sign': houses[8] ?? 'Sco'}, // 8 - Bottom right
      {'pos': [0.92, 0.8], 'sign': houses[9] ?? 'Sag'}, // 9 - Right bottom
      {'pos': [0.85, 0.5], 'sign': houses[10] ?? 'Cap'}, // 10 - Right center
      {'pos': [0.92, 0.2], 'sign': houses[11] ?? 'Aqu'}, // 11 - Right top
      {'pos': [0.8, 0.08], 'sign': houses[12] ?? 'Pis'}, // 12 - Top right
    ];

    // Planet positions (mock - in real app would be calculated)
    final planetPositions = {
      1: ['Sun'],
      4: ['Moon', 'Merc'],
      7: ['Jup'],
      10: ['Sat', 'Rahu'],
    };

    return pw.Container(
      width: size,
      height: size,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: primaryColor, width: 2),
        color: PdfColor.fromInt(0xFFFFF8F0),
      ),
      child: pw.Stack(
        children: [
          // Draw lines
          pw.CustomPaint(
            size: PdfPoint(size, size),
            painter: (canvas, point) {
              canvas.setStrokeColor(PdfColor.fromInt(0xFFFFCC80));
              canvas.setLineWidth(1);
              // Diagonals
              canvas.drawLine(0, 0, point.x, point.y);
              canvas.drawLine(point.x, 0, 0, point.y);
              // Diamond
              canvas.drawLine(point.x/2, 0, point.x, point.y/2);
              canvas.drawLine(point.x, point.y/2, point.x/2, point.y);
              canvas.drawLine(point.x/2, point.y, 0, point.y/2);
              canvas.drawLine(0, point.y/2, point.x/2, 0);
              canvas.strokePath();
            },
          ),
          // House labels
          ...List.generate(12, (i) {
            final data = houseData[i];
            final pos = data['pos'] as List<double>;
            final sign = data['sign'] as String;
            final planetsHere = planetPositions[i + 1] ?? [];
            
            return pw.Positioned(
              left: pos[0] * size - 20,
              top: pos[1] * size - 10,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(sign, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: secondaryColor)),
                  if (planetsHere.isNotEmpty)
                    pw.Text(planetsHere.join('\n'), 
                      style: pw.TextStyle(fontSize: 7, color: primaryColor, fontWeight: pw.FontWeight.bold),
                      textAlign: pw.TextAlign.center),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Detailed Navamsha Chart (4x4 grid)
  static pw.Widget _buildDetailedNavamshaChart(double size) {
    final signs = ['Pis', 'Ari', 'Tau', 'Gem', 'Aqu', '', '', 'Can', 'Cap', '', '', 'Leo', 'Sag', 'Sco', 'Lib', 'Vir'];
    final nums = ['12', '1', '2', '3', '11', '', '', '4', '10', '', '', '5', '9', '8', '7', '6'];
    final cellSize = size / 4;
    
    return pw.Container(
      width: size,
      height: size,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromInt(0xFF8D1B3D), width: 2),
      ),
      child: pw.Column(
        children: List.generate(4, (row) => pw.Row(
          children: List.generate(4, (col) {
            final idx = row * 4 + col;
            final isCenter = (row == 1 || row == 2) && (col == 1 || col == 2);
            return pw.Container(
              width: cellSize,
              height: cellSize,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                color: isCenter ? PdfColor.fromInt(0xFFFCE4EC) : null,
              ),
              child: pw.Center(
                child: isCenter && row == 1 && col == 1 
                  ? pw.Text('NAVAMSHA\nD-9', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 8, color: PdfColor.fromInt(0xFF8D1B3D)))
                  : pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        if (signs[idx].isNotEmpty)
                          pw.Text(signs[idx], style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFF8D1B3D))),
                        if (nums[idx].isNotEmpty)
                          pw.Text(nums[idx], style: pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
                      ],
                    ),
              ),
            );
          }),
        )),
      ),
    );
  }

  // Detailed Moon Chart - Same as Lagna but with Moon-based houses (blue theme)
  static pw.Widget _buildDetailedMoonChart(double size) {
    // Moon Chart house positions (Cancer as 1st house)
    final moonHouseData = [
      {'pos': [0.5, 0.15], 'sign': 'Can'},   // 1 - Top center
      {'pos': [0.2, 0.08], 'sign': 'Leo'},   // 2
      {'pos': [0.08, 0.2], 'sign': 'Vir'},   // 3
      {'pos': [0.15, 0.5], 'sign': 'Lib'},   // 4
      {'pos': [0.08, 0.8], 'sign': 'Sco'},   // 5
      {'pos': [0.2, 0.92], 'sign': 'Sag'},   // 6
      {'pos': [0.5, 0.85], 'sign': 'Cap'},   // 7 - Bottom center
      {'pos': [0.8, 0.92], 'sign': 'Aqu'},   // 8
      {'pos': [0.92, 0.8], 'sign': 'Pis'},   // 9
      {'pos': [0.85, 0.5], 'sign': 'Ari'},   // 10
      {'pos': [0.92, 0.2], 'sign': 'Tau'},   // 11
      {'pos': [0.8, 0.08], 'sign': 'Gem'},   // 12
    ];

    return pw.Container(
      width: size,
      height: size,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromInt(0xFF1565C0), width: 2),
        color: PdfColor.fromInt(0xFFE3F2FD),
      ),
      child: pw.Stack(
        children: [
          // Diamond lines
          pw.CustomPaint(
            size: PdfPoint(size, size),
            painter: (canvas, point) {
              canvas.setStrokeColor(PdfColor.fromInt(0xFF90CAF9));
              canvas.setLineWidth(1);
              // Diagonals
              canvas.drawLine(0, 0, point.x, point.y);
              canvas.drawLine(point.x, 0, 0, point.y);
              // Diamond
              canvas.drawLine(point.x/2, 0, point.x, point.y/2);
              canvas.drawLine(point.x, point.y/2, point.x/2, point.y);
              canvas.drawLine(point.x/2, point.y, 0, point.y/2);
              canvas.drawLine(0, point.y/2, point.x/2, 0);
              canvas.strokePath();
            },
          ),
          // Center label
          pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text('CHANDRA', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFF1565C0))),
                pw.Text('Moon: Cancer', style: pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
              ],
            ),
          ),
          // All 12 sign labels
          ...List.generate(12, (i) {
            final data = moonHouseData[i];
            final pos = data['pos'] as List<double>;
            final sign = data['sign'] as String;
            return pw.Positioned(
              left: pos[0] * size - 15,
              top: pos[1] * size - 8,
              child: pw.Text(sign, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFF1565C0))),
            );
          }),
        ],
      ),
    );
  }

  // Detailed Chalit Chart - Simple Table Layout (reliable PDF rendering)
  static pw.Widget _buildDetailedChalitChart(double size) {
    // Use a simple 3-row table representation for Bhava Chalit
    // This renders reliably in PDF unlike complex canvas drawings
    return pw.Container(
      width: size,
      height: size,
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFE8F5E9),
        border: pw.Border.all(color: PdfColor.fromInt(0xFF2E7D32), width: 2),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          // Title
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(vertical: 6),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF2E7D32),
              borderRadius: const pw.BorderRadius.vertical(top: pw.Radius.circular(6)),
            ),
            child: pw.Center(
              child: pw.Text('BHAVA CHALIT', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
            ),
          ),
          // House grid - 3 rows x 4 columns
          pw.Expanded(
            child: pw.Column(
              children: [
                // Top row: 10, 11, 12, 1
                pw.Expanded(
                  child: pw.Row(
                    children: [
                      _chalitCell('10'),
                      _chalitCell('11'),
                      _chalitCell('12'),
                      _chalitCell('1'),
                    ],
                  ),
                ),
                // Middle row: 9, (center), (center), 2
                pw.Expanded(
                  child: pw.Row(
                    children: [
                      _chalitCell('9'),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
                          ),
                          child: pw.Center(
                            child: pw.Column(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text('Cusp Based', style: pw.TextStyle(fontSize: 8, color: PdfColor.fromInt(0xFF2E7D32))),
                                pw.Text('Asc: 15.5°', style: pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      _chalitCell('2'),
                    ],
                  ),
                ),
                // Third row: 8, (center), (center), 3
                pw.Expanded(
                  child: pw.Row(
                    children: [
                      _chalitCell('8'),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
                          ),
                        ),
                      ),
                      _chalitCell('3'),
                    ],
                  ),
                ),
                // Bottom row: 7, 6, 5, 4
                pw.Expanded(
                  child: pw.Row(
                    children: [
                      _chalitCell('7'),
                      _chalitCell('6'),
                      _chalitCell('5'),
                      _chalitCell('4'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _chalitCell(String num) {
    return pw.Expanded(
      child: pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
        ),
        child: pw.Center(
          child: pw.Text(num, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColor.fromInt(0xFF2E7D32))),
        ),
      ),
    );
  }
  
  static double _cos(double radians) => 
    [1.0, 0.866, 0.5, 0.0, -0.5, -0.866, -1.0, -0.866, -0.5, 0.0, 0.5, 0.866][(radians * 180 / 3.14159 / 30 + 3).round() % 12];
  static double _sin(double radians) => 
    [0.0, 0.5, 0.866, 1.0, 0.866, 0.5, 0.0, -0.5, -0.866, -1.0, -0.866, -0.5][(radians * 180 / 3.14159 / 30 + 3).round() % 12];

  static pw.Widget _buildWatermark(pw.MemoryImage? logoImage) {
    if (logoImage == null) return pw.Container();
    return pw.Center(child: pw.Opacity(opacity: 0.05, child: pw.Image(logoImage, width: 450, height: 450)));
  }

  static pw.Widget _buildHeader(pw.MemoryImage? logoImage) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        if (logoImage != null) pw.Image(logoImage, width: 35, height: 35),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('VEDIC MATE', style: pw.TextStyle(fontSize: 14, color: primaryColor, fontWeight: pw.FontWeight.bold)),
            pw.Text('Divine Guidance', style: pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
          ],
        )
      ],
    );
  }

  static pw.Widget _buildTitle(String title) {
    return pw.Center(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: primaryColor, width: 2))),
        child: pw.Text(title.toUpperCase(), style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, letterSpacing: 2, color: secondaryColor)),
      ),
    );
  }

  static pw.Widget _buildSectionHeader(String title) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: pw.BoxDecoration(color: primaryColor, borderRadius: pw.BorderRadius.circular(4)),
      child: pw.Text(title, style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 11)),
    );
  }

  static pw.Widget _buildPersonalDetails(String name, DateTime dob, String time, String place) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFFFFF8F0), borderRadius: pw.BorderRadius.circular(6), border: pw.Border.all(color: PdfColors.grey300)),
      child: pw.Row(
        children: [
          pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            _buildInfoRow('Name', name),
            pw.SizedBox(height: 4),
            _buildInfoRow('Birth Place', place),
          ])),
          pw.SizedBox(width: 15),
          pw.Expanded(child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            _buildInfoRow('Date', '${dob.day}/${dob.month}/${dob.year}'),
            pw.SizedBox(height: 4),
            _buildInfoRow('Time', time),
          ])),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Row(children: [
      pw.Text('$label: ', style: pw.TextStyle(color: PdfColors.grey600, fontSize: 8)),
      pw.Text(value, style: pw.TextStyle(color: secondaryColor, fontWeight: pw.FontWeight.bold, fontSize: 9)),
    ]);
  }

  static pw.Widget _buildPlanetaryTable(Map<String, String> planets) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {0: const pw.FlexColumnWidth(1), 1: const pw.FlexColumnWidth(2)},
      children: [
        pw.TableRow(decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFFFFF3E0)), children: [
          _buildTableHeader('Planet'), _buildTableHeader('Sign & Degree'),
        ]),
        ...planets.entries.map((e) => pw.TableRow(children: [_buildTableCell(e.key, isBold: true), _buildTableCell(e.value)])).toList(),
      ]
    );
  }
  
  static pw.Widget _buildHousesTable(Map<int, String> houses) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {0: const pw.FlexColumnWidth(1), 1: const pw.FlexColumnWidth(2)},
      children: [
        pw.TableRow(decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFFFFF3E0)), children: [
          _buildTableHeader('House'), _buildTableHeader('Sign Occupied'),
        ]),
        ...houses.entries.map((e) => pw.TableRow(children: [_buildTableCell('House ${e.key}', isBold: true), _buildTableCell(e.value)])).toList(),
      ]
    );
  }
  
  static pw.Widget _buildTableHeader(String text) => pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: primaryColor)));
  static pw.Widget _buildTableCell(String text, {bool isBold = false}) => pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(text, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal, fontSize: 8)));
  static pw.Widget _buildFooter() => pw.Column(children: [pw.Divider(color: PdfColors.grey300), pw.SizedBox(height: 3), pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [pw.Text('Generated via Vedic Mate App', style: pw.TextStyle(fontSize: 7, color: PdfColors.grey500)), pw.Text('http://15.207.36.26:3000', style: pw.TextStyle(fontSize: 7, color: primaryColor))])]);
  
  static Future<pw.MemoryImage?> _createLogoImage() async {
    try {
      // Load actual logo.png from assets
      final ByteData data = await rootBundle.load('assets/images/logo.png');
      final Uint8List bytes = data.buffer.asUint8List();
      return pw.MemoryImage(bytes);
    } catch (e) { 
      // Fallback to generated logo if asset loading fails
      try {
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        final size = Size(100, 100);
        final paint = Paint()..color = const Color(0xFFFF7A00)..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, paint);
        final textPainter = TextPainter(text: TextSpan(text: 'VM', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)), textDirection: TextDirection.ltr);
        textPainter.layout();
        textPainter.paint(canvas, Offset((size.width - textPainter.width) / 2, (size.height - textPainter.height) / 2));
        final picture = recorder.endRecording();
        final image = await picture.toImage(100, 100);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        return pw.MemoryImage(byteData!.buffer.asUint8List());
      } catch (e2) { return null; }
    }
  }
}
