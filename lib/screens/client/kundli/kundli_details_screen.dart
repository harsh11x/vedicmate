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
import '../../../../services/astronomy/astronomy_service.dart';
import '../../../../services/insights/insight_service.dart';
import '../../../../services/wallet_pass_service.dart';
import 'package:add_to_google_wallet/widgets/add_to_google_wallet_button.dart';

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
  Map<String, dynamic>? _planetaryPositions;
  Map<String, dynamic>? _lagnaData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this); // Increased to 5
    _calculateChartData();
  }

  Future<void> _calculateChartData() async {
    // TODO: Use actual lat/long from placeOfBirth (Geocoding)
    // For Phase 1.5/3 demo, we use default lat/long (New Delhi) or mock
    final lat = 28.6139; 
    final lng = 77.2090;

    // Parse time
    final timeParts = widget.timeOfBirth.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    
    final dateTime = DateTime(
      widget.dateOfBirth.year,
      widget.dateOfBirth.month, 
      widget.dateOfBirth.day,
      hour,
      minute,
    );

    final astronomyService = AstronomyService();
    
    final planets = astronomyService.calculatePlanetaryPositions(
      dateTime: dateTime, 
      latitude: lat, 
      longitude: lng
    );
    
    final lagna = astronomyService.calculateAscendant(
      dateTime: dateTime, 
      latitude: lat, 
      longitude: lng,
      sunData: planets['Sun'],
    );

    if (mounted) {
      setState(() {
        _planetaryPositions = planets;
        _lagnaData = lagna;
        _isLoading = false;
      });
    }
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
            Tab(text: "Insights"), // New
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
            const KundliTablesSection(),
            _buildInsightsTab(), // New
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final lagnaData = _getChartData('Lagna');
    final navamsaData = _getChartData('Navamsha');
    final dasamsaData = _getChartData('Dasamsa');
    // final moonData = _getChartData('Moon'); // TODO: Implement if needed

    // Calculate Shadbala
    final shadbala = AstronomyService().calculateShadbala(_planetaryPositions!);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Shadbala Strength Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 const Text("Planetary Strength (Shadbala)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                 const SizedBox(height: 12),
                 ...shadbala.entries.map((e) {
                   return Padding(
                     padding: const EdgeInsets.symmetric(vertical: 4),
                     child: Row(
                       children: [
                         SizedBox(width: 80, child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w500))),
                         Expanded(
                           child: LinearProgressIndicator(
                             value: e.value / 100, 
                             backgroundColor: Colors.grey[200],
                             color: _getStrengthColor(e.value),
                             minHeight: 8,
                             borderRadius: BorderRadius.circular(4),
                           ),
                         ),
                         const SizedBox(width: 12),
                         Text("${e.value.toStringAsFixed(1)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                       ],
                     ),
                   );
                 }).toList(),
              ],
            ),
          ),
          const SizedBox(height: 20),

          KundliChartWidget(
            title: "Lagna Chart (Birth)", 
            chartType: "Lagna",
            lagnaSign: lagnaData['lagnaSign'],
            houses: lagnaData['houses'],
            planets: lagnaData['planets'],
          ),
          const SizedBox(height: 20),
          KundliChartWidget(
            title: "Navamsha Chart (D9)", 
            chartType: "Navamsha",
            lagnaSign: navamsaData['lagnaSign'],
            houses: navamsaData['houses'],
            planets: navamsaData['planets'],
          ),
          const SizedBox(height: 20),
          KundliChartWidget(
            title: "Dasamsa Chart (D10)", 
            chartType: "Navamsha", // Reuse Navamsha style (South Indian or similar) or Lagna (North)
            // Let's use Lagna style (North Indian) for D10 for now as it's common
            // Or better, let's stick to D9 style if we want square, but 'Navamsha' chartType triggers South Indian painter.
            // If I want North Indian for D10, I should use chartType 'Lagna' but with D10 data? 
            // The chartType controls the Painter.
            // Let's use 'Navamsha' style for D10 if we want consistency in Varga charts? 
            // Actually, North vs South is a USER PREFERENCE. 
            // For this MVP, let's use 'Lagna' style (North) for D10 to differentiate or just consistency.
            // Let's use 'Lagna' style.
            lagnaSign: dasamsaData['lagnaSign'],
            houses: dasamsaData['houses'],
            planets: dasamsaData['planets'],
          ),
          const SizedBox(height: 20),
          KundliChartWidget(title: "Moon Chart", chartType: "Moon"),
        ],
      ),
    );
  }

  Map<String, dynamic> _getChartData(String type) {
    if (_planetaryPositions == null || _lagnaData == null) return {};

    String lagnaSign = '';
    int lagnaIndex = 1;
    Map<String, String> planets = {};
    
    // 1. Determine Lagna based on Chart Type
    if (type == 'Lagna') {
      lagnaSign = _lagnaData!['rashi'];
      lagnaIndex = _lagnaData!['rashi_index'];
    } else if (type == 'Navamsha') {
      lagnaSign = _lagnaData!['navamsa'];
      lagnaIndex = _lagnaData!['navamsa_index'];
    } else if (type == 'Dasamsa') {
      lagnaSign = _lagnaData!['dasamsa'];
      lagnaIndex = _lagnaData!['dasamsa_index'] ?? 1; // Fallback
    }

    // 2. Build Houses (1 to 12)
    Map<int, String> houses = {};
    List<String> rashis = [
      'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo', 
      'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
    ];
    // Our service returns full names like 'Mesha (Aries)'. Let's map or just use what we have.
    // The service returns: 'Mesha (Aries)' etc.
    // Let's use simplified names for display if possible, or just use the service strings.
    // Current widgets expect short names 'Ari', 'Tau' etc in their defaults, but handle full strings?
    // Let's use a helper to shorten if needed.
    
    for (int i = 0; i < 12; i++) {
      // House 1 has Lagna Index
      // House i+1 has (Lagna Index + i - 1) % 12 + 1
      int signIndex = (lagnaIndex - 1 + i) % 12; // 0-11
      // Service uses 0-based index logically in array but returns 1-based index in map.
      // My Service returns 'rashi_index' as 1-based.
      
      // We can recreate the sign name from index using my Service's array or a local one.
      // Let's use local short names for UI compactness.
      houses[i + 1] = _getShortSignName(signIndex + 1);
    }

    // 3. Build Planets
    _planetaryPositions!.forEach((key, value) {
      if (type == 'Lagna') {
        final sign = _getShortSignName(value['rashi_index']);
        final deg = value['degree'];
        planets[key] = '$sign $deg°';
      } else if (type == 'Navamsha') {
        final sign = _getShortSignName(value['navamsa_index']);
        planets[key] = sign; // Degree irrelevant for D9 visual
      } else if (type == 'Dasamsa') {
        final sign = _getShortSignName(value['dasamsa_index'] ?? 1);
        planets[key] = sign;
      }
    });

    return {
      'lagnaSign': lagnaSign,
      'houses': houses,
      'planets': planets,
    };
  }

  String _getShortSignName(int index) {
    const shorts = [
      'Ari', 'Tau', 'Gem', 'Can', 'Leo', 'Vir', 
      'Lib', 'Sco', 'Sag', 'Cap', 'Aqu', 'Pis'
    ];
    return shorts[(index - 1) % 12];
  }

  Widget _buildInsightsTab() {
     if (_isLoading || _planetaryPositions == null || _lagnaData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final insightService = InsightService();
    final ascendantSign = _lagnaData!['rashi'].toString().split(' ').first; // Extract name
    // Actually our service logic for getAscendantNature expects full string 'Mesha (Aries)' likely,
    // let's check what _lagnaData['rashi'] returns. 
    // AstronomyService returns full string 'Mesha (Aries)'. 
    // InsightService expects full string.
    
    final nature = insightService.getAscendantNature(_lagnaData!['rashi']);
    final moonSign = _planetaryPositions!['Moon']['rashi'];
    final mindset = insightService.getMoonMindset(moonSign);
    final careerHints = insightService.getCareerHints(_planetaryPositions!);
    final wealthHints = insightService.getWealthHints(_planetaryPositions!);
    final healthHints = insightService.getHealthHints(_planetaryPositions!);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard("Your Basic Nature (Lagna)", [
             Padding(
               padding: const EdgeInsets.symmetric(vertical: 8.0),
               child: Text(nature, style: const TextStyle(fontSize: 16)),
             ),
          ]),
          const SizedBox(height: 16),
          _buildInfoCard("Emotional Mindset (Moon)", [
             Padding(
               padding: const EdgeInsets.symmetric(vertical: 8.0),
               child: Text(mindset, style: const TextStyle(fontSize: 16)),
             ),
          ]),
          const SizedBox(height: 16),
          _buildListCard("Career Potential", careerHints),
          const SizedBox(height: 16),
          _buildListCard("Wealth & Finance", wealthHints),
          const SizedBox(height: 16),
          _buildListCard("Health Indicators", healthHints),
        ],
      ),
    );
  }

  Widget _buildListCard(String title, List<String> items) {
     return _buildInfoCard(title, [
        if (items.isEmpty) 
          const Padding(padding: EdgeInsets.all(8.0), child: Text("No specific indicators found."))
        else
          ...items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.circle, size: 8, color: AppTheme.primaryOrange),
                const SizedBox(width: 8),
                Expanded(child: Text(item, style: const TextStyle(fontSize: 15))),
              ],
            ),
          )),
     ]);
  }

  Color _getStrengthColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.blue;
    if (score >= 40) return Colors.orange;
    return Colors.red;
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
            const Divider(),
            if (Platform.isIOS)
              ListTile(
                leading: const Icon(Icons.wallet_membership_rounded, color: Colors.black),
                title: const Text("Add to Apple Wallet"),
                onTap: () {
                  Navigator.pop(ctx);
                  _addToWallet(isApple: true);
                },
              ),
            if (Platform.isAndroid)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: AddToGoogleWalletButton(
                  pass: WalletPassService().generateGoogleWalletPassJson(
                    name: widget.name,
                    dob: "${widget.dateOfBirth.day}/${widget.dateOfBirth.month}/${widget.dateOfBirth.year}",
                    tob: widget.timeOfBirth,
                    pob: widget.placeOfBirth,
                    rashi: _lagnaData?['rashi'] ?? 'Unknown',
                    nakshatra: 'Rohini',
                  ),
                  onSuccess: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Successfully added to Google Wallet!'), backgroundColor: Colors.green),
                  ),
                  onError: (error) => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Google Wallet Error: $error'), backgroundColor: Colors.red),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _addToWallet({required bool isApple}) async {
    if (!isApple) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 320,
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
                boxShadow: [
                  BoxShadow(color: Colors.black54, blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                children: [
                  // Pass Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryOrange,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                        const SizedBox(width: 12),
                        const Text(
                          "VedicMate Kundli",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  // Pass Body
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildPreviewRow("HOLDER NAME", widget.name.toUpperCase()),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildPreviewRow("RASHI", _lagnaData?['rashi']?.toString().split(' ').first.toUpperCase() ?? "N/A")),
                            Expanded(child: _buildPreviewRow("NAKSHATRA", "ROHINI")),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildPreviewRow("BIRTH PLACE", widget.placeOfBirth.toUpperCase()),
                        const SizedBox(height: 24),
                        // Visual Divider
                        Row(
                          children: List.generate(15, (i) => Expanded(
                            child: Container(height: 1, color: i % 2 == 0 ? Colors.white24 : Colors.transparent),
                          )),
                        ),
                        const SizedBox(height: 24),
                        // Mock QR Code Area
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(Icons.qr_code_2_rounded, size: 100, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Info Note
            Container(
              width: 320,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    "Production Requirement",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Apple Wallet requires a production Apple Developer certificate and a backend service to sign .pkpass files. This preview shows the final intended design.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close", style: TextStyle(color: Colors.white70)),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Get PDF Instead"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      ],
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
