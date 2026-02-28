import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class InvoiceGenerator {
  static Future<void> generateAndDownloadInvoice(Map<String, dynamic> order) async {
    final pdf = pw.Document();
    
    // Load logo
    final logoImage = await rootBundle.load('assets/images/logo.png');
    final logoBytes = logoImage.buffer.asUint8List();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // Watermark
              pw.Positioned(
                left: 100,
                top: 250,
                child: pw.Opacity(
                  opacity: 0.1,
                  child: pw.Image(
                    pw.MemoryImage(logoBytes),
                    width: 400,
                    height: 400,
                  ),
                ),
              ),
              
              // Content
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(logoBytes),
                  pw.SizedBox(height: 30),
                  
                  // Invoice Title
                  pw.Center(
                    child: pw.Text(
                      'INVOICE',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.orange,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  
                  // Invoice Details
                  _buildInvoiceInfo(order),
                  pw.SizedBox(height: 20),
                  
                  // Customer Details
                  _buildCustomerInfo(order),
                  pw.SizedBox(height: 20),
                  
                  // Service Details Table
                  _buildServiceTable(order),
                  pw.SizedBox(height: 20),
                  
                  // Session Details
                  _buildSessionDetails(order),
                  pw.SizedBox(height: 30),
                  
                  // Total
                  _buildTotal(order),
                  pw.SizedBox(height: 30),
                  
                  // Footer
                  _buildFooter(),
                ],
              ),
            ],
          );
        },
      ),
    );

    // Download PDF
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'VedicMate_Invoice_${order['orderId']}.pdf',
    );
  }

  static pw.Widget _buildHeader(Uint8List logoBytes) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Image(
              pw.MemoryImage(logoBytes),
              width: 80,
              height: 80,
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'VedicMate',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.orange,
              ),
            ),
            pw.Text(
              'Spiritual Technology Platform',
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'VedicMate Technologies',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Email: support@vedicmate.com',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.Text(
              'Phone: +91 9876543210',
              style: const pw.TextStyle(fontSize: 10),
            ),
            pw.Text(
              'Website: www.vedicmate.com',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildInvoiceInfo(Map<String, dynamic> order) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.orange50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Invoice Number',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                order['orderId'],
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Invoice Date',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                DateFormat('dd MMM yyyy').format(DateTime.parse(order['createdAt'])),
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCustomerInfo(Map<String, dynamic> order) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'BILL TO',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.orange,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            order['userName'] ?? 'Customer',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 4),
          if (order['userEmail'] != null && order['userEmail'].toString().isNotEmpty)
            pw.Text(
              'Email: ${order['userEmail']}',
              style: const pw.TextStyle(fontSize: 10),
            ),
          if (order['userPhone'] != null && order['userPhone'].toString().isNotEmpty)
            pw.Text(
              'Phone: ${order['userPhone']}',
              style: const pw.TextStyle(fontSize: 10),
            ),
        ],
      ),
    );
  }

  static pw.Widget _buildServiceTable(Map<String, dynamic> order) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.orange),
          children: [
            _buildTableCell('Service Description', isHeader: true),
            _buildTableCell('Quantity', isHeader: true),
            _buildTableCell('Rate', isHeader: true),
            _buildTableCell('Amount', isHeader: true),
          ],
        ),
        // Service Row
        pw.TableRow(
          children: [
            _buildTableCell(order['serviceType']),
            _buildTableCell('1'),
            _buildTableCell(order['amount'] == 'TBD' ? 'TBD' : '₹${order['amount']}'),
            _buildTableCell(order['amount'] == 'TBD' ? 'TBD' : '₹${order['amount']}'),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 11 : 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.white : PdfColors.black,
        ),
        textAlign: isHeader ? pw.TextAlign.center : pw.TextAlign.left,
      ),
    );
  }

  static pw.Widget _buildSessionDetails(Map<String, dynamic> order) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'SESSION DETAILS',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.orange,
            ),
          ),
          pw.SizedBox(height: 10),
          _buildDetailRow('Requested Date:', order['date']),
          _buildDetailRow('Requested Time:', order['timeSlot']),
          if (order['finalDate'] != null)
            _buildDetailRow('Confirmed Date:', order['finalDate'], isHighlighted: true),
          if (order['finalTime'] != null)
            _buildDetailRow('Confirmed Time:', order['finalTime'], isHighlighted: true),
          if (order['requirements'] != null && order['requirements'].toString().isNotEmpty) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              'Requirements:',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              order['requirements'],
              style: const pw.TextStyle(fontSize: 9),
            ),
          ],
          if (order['joiningLink'] != null) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              'Joining Link:',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              order['joiningLink'],
              style: const pw.TextStyle(
                fontSize: 9,
                color: PdfColors.blue,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildDetailRow(String label, String value, {bool isHighlighted = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: isHighlighted ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: isHighlighted ? PdfColors.green : PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTotal(Map<String, dynamic> order) {
    final amount = order['amount'];
    final amountText = amount == 'TBD' ? 'TBD' : '₹$amount';
    
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.orange,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'TOTAL AMOUNT',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.Text(
            amountText,
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Payment Status: PAID',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Payment Method: PayU',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Thank you for choosing VedicMate!',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'For support: support@vedicmate.com',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 15),
        pw.Center(
          child: pw.Text(
            'This is a computer-generated invoice and does not require a signature.',
            style: const pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey600,
            ),
          ),
        ),
      ],
    );
  }
}
