import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../widgets/abstract_background.dart';
import 'widgets/kundli_chart_widgets.dart';
import 'widgets/kundli_tables_section.dart';
import 'widgets/kundli_chat_widget.dart';
import '../../../../services/kundli_pdf_service.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:printing/printing.dart';

class KundliDetailsScreen extends StatefulWidget {
  final String name;
  final DateTime dateOfBirth;
  final String placeOfBirth;
  final String timeOfBirth;

  const KundliDetailsScreen({
    super.key,
    required this.name,
    required this.dateOfBirth,
    required this.placeOfBirth,
    required this.timeOfBirth,
  });

  @override
  State<KundliDetailsScreen> createState() => _KundliDetailsScreenState();
}

class _KundliDetailsScreenState extends State<KundliDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutralSoft,
      appBar: AppBar(
        title: const Text('Your Kundli', style: TextStyle(color: AppTheme.neutralDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: AppTheme.neutralDark),
        actions: [
          IconButton(
            icon: Icon(Icons.download_rounded, color: AppTheme.primaryOrange),
            onPressed: () => _showDownloadOptions(context),
          ),
          IconButton(
            icon: Icon(Icons.chat_bubble_outline_rounded, color: AppTheme.primaryOrange),
            onPressed: () {
              // Open Chat
              showModalBottomSheet(
                context: context, 
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) => _buildChatSheet(ctx),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryOrange,
          unselectedLabelColor: AppTheme.neutralMedium,
          indicatorColor: AppTheme.primaryOrange,
          isScrollable: true,
          tabs: const [
            Tab(text: "Basic"),
            Tab(text: "Charts"),
            Tab(text: "Tables"),
            Tab(text: "Report"),
          ],
        ),
      ),
      body: AbstractBackground(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBasicDetailsTab(),
            _buildChartsTab(),
            const KundliTablesSection(), // To be implemented
            _buildReportTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoCard("Birth Details", [
            _buildRow("Name", widget.name),
            _buildRow("Date", "${widget.dateOfBirth.day}/${widget.dateOfBirth.month}/${widget.dateOfBirth.year}"),
            _buildRow("Time", widget.timeOfBirth),
            _buildRow("Place", widget.placeOfBirth),
          ]),
          const SizedBox(height: 16),
          _buildInfoCard("Panchang", [
             _buildRow("Tithi", "Shukla Paksha Dashami"),
             _buildRow("Nakshatra", "Rohini"),
             _buildRow("Yoga", "Siddha"),
             _buildRow("Karan", "Taitila"),
          ]),
           const SizedBox(height: 16),
          _buildInfoCard("Avkahada Chakra", [
             _buildRow("Varna", "Vaishya"),
             _buildRow("Vashya", "Chatuspad"),
             _buildRow("Yoni", "Sarpa"),
             _buildRow("Gan", "Manushya"),
             _buildRow("Nadi", "Antya"),
          ]),
        ],
      ),
    );
  }

  Widget _buildChartsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          KundliChartWidget(title: "Lagna Chart (Birth)", chartType: "Lagna"),
          const SizedBox(height: 20),
          KundliChartWidget(title: "Navamsha Chart (D9)", chartType: "Navamsha"),
          const SizedBox(height: 20),
          KundliChartWidget(title: "Moon Chart", chartType: "Moon"),
          const SizedBox(height: 20),
          KundliChartWidget(title: "Chalit Chart", chartType: "Chalit"),
        ],
      ),
    );
  }

  Widget _buildReportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("General Predictions", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          Text(
            "Your chart indicates a strong personality with leadership qualities. The placement of Sun in the 5th house brings creativity and intelligence...",
            style: TextStyle(height: 1.5, color: AppTheme.neutralDark),
          ),
          const SizedBox(height: 20),
          Text("Health", style: Theme.of(context).textTheme.titleLarge),
          const Text("Generally good health, but watch out for stomach related issues."),
          const SizedBox(height: 20),
          Text("Career", style: Theme.of(context).textTheme.titleLarge),
          const Text("Great prospects in management, administration or any creative field."),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryOrange)),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppTheme.neutralMedium, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showDownloadOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Download Kundli PDF", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.insert_drive_file_outlined),
              title: const Text("Current Page"),
              onTap: () {
                Navigator.pop(ctx);
                _downloadPdf(allPages: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_copy_outlined),
              title: const Text("Full Report (All Pages)"),
              onTap: () {
                Navigator.pop(ctx);
                _downloadPdf(allPages: true);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadPdf({required bool allPages}) async {
    setState(() => _isDownloading = true);
    
    try {
      // Actual mock data for PDF
      final Map<int, String> houses = {
        1: 'Aries', 2: 'Taurus', 3: 'Gemini', 4: 'Cancer',
        5: 'Leo', 6: 'Virgo', 7: 'Libra', 8: 'Scorpio',
        9: 'Sagittarius', 10: 'Capricorn', 11: 'Aquarius', 12: 'Pisces',
      };
      
      final Map<String, String> planets = {
        'Sun': 'Leo 15°', 'Moon': 'Cancer 22°', 'Mars': 'Aries 8°',
        'Mercury': 'Virgo 12°', 'Jupiter': 'Sagittarius 18°', 'Venus': 'Libra 25°',
        'Saturn': 'Capricorn 10°', 'Rahu': 'Pisces 5°', 'Ketu': 'Virgo 5°',
      };

      final pdfBytes = await KundliPdfService.generatePdf(
        name: widget.name,
        dateOfBirth: widget.dateOfBirth,
        placeOfBirth: widget.placeOfBirth,
        timeOfBirth: widget.timeOfBirth,
        lagnaSign: 'Aries',
        houses: houses,
        planets: planets,
        allPages: allPages,
      );
      
      // Use sharePdf to allow user to save/share the file
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'Kundli_${widget.name.replaceAll(' ', '_')}.pdf',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('PDF Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    
    if (mounted) {
      setState(() => _isDownloading = false);
    }
  }


  Widget _buildChatSheet(BuildContext context) {
    // Determine context topic based on current tab
    String topic = "General";
    switch (_tabController.index) {
      case 0: topic = "Basic"; break;
      case 1: topic = "Charts"; break;
      case 2: topic = "Tables"; break;
      case 3: topic = "Report"; break;
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: KundliChatWidget(
        contextTopic: topic,
        kundliName: widget.name,
      ),
    );
  }
}
