import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/theme/app_theme.dart';

class AdminCustomRequestsScreen extends StatefulWidget {
  const AdminCustomRequestsScreen({super.key});

  @override
  State<AdminCustomRequestsScreen> createState() => _AdminCustomRequestsScreenState();
}

class _AdminCustomRequestsScreenState extends State<AdminCustomRequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _allRequests = [];
  bool _isLoading = true;
  static const String serverUrl = 'https://18.218.161.253:3001';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRequests();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('$serverUrl/api/admin/custom-requests'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _allRequests = data['requests'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading requests: $e');
      setState(() => _isLoading = false);
    }
  }

  List<dynamic> get _pendingRequests => _allRequests.where((r) => r['status'] == 'pending' && r['paymentStatus'] == 'paid').toList();
  List<dynamic> get _acceptedRequests => _allRequests.where((r) => r['status'] == 'accepted').toList();
  List<dynamic> get _rejectedRequests => _allRequests.where((r) => r['status'] == 'rejected').toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.forestBackground,
      appBar: AppBar(
        title: Text(
          'Custom Requests',
          style: GoogleFonts.outfit(
            color: AppTheme.neutralDark,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryOrange,
          unselectedLabelColor: AppTheme.neutralMedium,
          indicatorColor: AppTheme.primaryOrange,
          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
          tabs: [
            Tab(text: 'Pending (${_pendingRequests.length})'),
            Tab(text: 'Accepted (${_acceptedRequests.length})'),
            Tab(text: 'Rejected (${_rejectedRequests.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRequests,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildRequestList(_pendingRequests, 'pending'),
                  _buildRequestList(_acceptedRequests, 'accepted'),
                  _buildRequestList(_rejectedRequests, 'rejected'),
                ],
              ),
            ),
    );
  }

  Widget _buildRequestList(List<dynamic> requests, String status) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: AppTheme.neutralMedium.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'No ${status} requests',
              style: GoogleFonts.outfit(
                fontSize: 18,
                color: AppTheme.neutralMedium,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        return _buildRequestCard(requests[index], status);
      },
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryOrange.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        request['serviceType'],
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.neutralDark,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryOrange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '₹${request['amount']}',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Order ID: ${request['orderId']}',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: AppTheme.neutralMedium,
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Customer', request['userName'] ?? 'N/A'),
                _buildDetailRow('Email', request['userEmail'] ?? 'N/A'),
                _buildDetailRow('Phone', request['userPhone'] ?? 'N/A'),
                const Divider(height: 24),
                _buildDetailRow('Requested Date', request['date']),
                _buildDetailRow('Time Slot', request['timeSlot']),
                if (request['requirements'] != null && request['requirements'].toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Requirements:',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.neutralDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    request['requirements'],
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: AppTheme.neutralMedium,
                    ),
                  ),
                ],
                if (request['finalDate'] != null) ...[
                  const Divider(height: 24),
                  _buildDetailRow('Confirmed Date', request['finalDate'], isHighlighted: true),
                  _buildDetailRow('Confirmed Time', request['finalTime'] ?? '', isHighlighted: true),
                ],
                if (request['joiningLink'] != null) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow('Joining Link', request['joiningLink']),
                ],
                if (request['adminNotes'] != null) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow('Admin Notes', request['adminNotes']),
                ],

                // Actions
                if (status == 'pending') ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showRejectDialog(request),
                          icon: const Icon(Icons.close, size: 18),
                          label: Text('Reject', style: GoogleFonts.outfit()),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showAcceptDialog(request),
                          icon: const Icon(Icons.check, size: 18),
                          label: Text('Accept', style: GoogleFonts.outfit(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (status == 'accepted') ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showEditDialog(request),
                    icon: const Icon(Icons.edit, size: 18),
                    label: Text('Edit Details', style: GoogleFonts.outfit(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryOrange,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppTheme.neutralMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: isHighlighted ? Colors.green : AppTheme.neutralDark,
                fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAcceptDialog(Map<String, dynamic> request) {
    final joiningLinkController = TextEditingController();
    final adminNotesController = TextEditingController();
    DateTime selectedDate = DateTime.parse(request['date']);
    String selectedTime = request['timeSlot'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Accept Request', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Set confirmed date and time:', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(DateFormat('dd MMM yyyy').format(selectedDate), style: GoogleFonts.outfit()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedTime,
                  decoration: InputDecoration(
                    labelText: 'Time Slot',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: ['09:00 AM', '10:00 AM', '11:00 AM', '12:00 PM', '02:00 PM', '03:00 PM', '04:00 PM', '05:00 PM']
                      .map((time) => DropdownMenuItem(value: time, child: Text(time)))
                      .toList(),
                  onChanged: (value) => setState(() => selectedTime = value!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: joiningLinkController,
                  decoration: InputDecoration(
                    labelText: 'Joining Link (Google Meet/Zoom)',
                    hintText: 'https://meet.google.com/...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: adminNotesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Admin Notes (Optional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.outfit()),
            ),
            ElevatedButton(
              onPressed: () {
                _updateOrderStatus(
                  request['orderId'],
                  'accepted',
                  joiningLink: joiningLinkController.text,
                  adminNotes: adminNotesController.text,
                  finalDate: DateFormat('yyyy-MM-dd').format(selectedDate),
                  finalTime: selectedTime,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('Accept', style: GoogleFonts.outfit(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showRejectDialog(Map<String, dynamic> request) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Reject Request', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: notesController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Reason for rejection',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.outfit()),
          ),
          ElevatedButton(
            onPressed: () {
              _updateOrderStatus(
                request['orderId'],
                'rejected',
                adminNotes: notesController.text,
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Reject', style: GoogleFonts.outfit(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Map<String, dynamic> request) {
    final joiningLinkController = TextEditingController(text: request['joiningLink'] ?? '');
    final adminNotesController = TextEditingController(text: request['adminNotes'] ?? '');
    DateTime selectedDate = request['finalDate'] != null ? DateTime.parse(request['finalDate']) : DateTime.parse(request['date']);
    String selectedTime = request['finalTime'] ?? request['timeSlot'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Edit Details', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                    }
                  },
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(DateFormat('dd MMM yyyy').format(selectedDate), style: GoogleFonts.outfit()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedTime,
                  decoration: InputDecoration(
                    labelText: 'Time Slot',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: ['09:00 AM', '10:00 AM', '11:00 AM', '12:00 PM', '02:00 PM', '03:00 PM', '04:00 PM', '05:00 PM']
                      .map((time) => DropdownMenuItem(value: time, child: Text(time)))
                      .toList(),
                  onChanged: (value) => setState(() => selectedTime = value!),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: joiningLinkController,
                  decoration: InputDecoration(
                    labelText: 'Joining Link',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: adminNotesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Admin Notes',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.outfit()),
            ),
            ElevatedButton(
              onPressed: () {
                _updateOrderStatus(
                  request['orderId'],
                  'accepted',
                  joiningLink: joiningLinkController.text,
                  adminNotes: adminNotesController.text,
                  finalDate: DateFormat('yyyy-MM-dd').format(selectedDate),
                  finalTime: selectedTime,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryOrange),
              child: Text('Update', style: GoogleFonts.outfit(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateOrderStatus(
    String orderId,
    String status, {
    String? joiningLink,
    String? adminNotes,
    String? finalDate,
    String? finalTime,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/api/admin/custom-requests/update-status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'orderId': orderId,
          'status': status,
          if (joiningLink != null) 'joiningLink': joiningLink,
          if (adminNotes != null) 'adminNotes': adminNotes,
          if (finalDate != null) 'finalDate': finalDate,
          if (finalTime != null) 'finalTime': finalTime,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Request ${status}ed successfully')),
        );
        _loadRequests();
      }
    } catch (e) {
      debugPrint('Error updating status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update request')),
      );
    }
  }
}
