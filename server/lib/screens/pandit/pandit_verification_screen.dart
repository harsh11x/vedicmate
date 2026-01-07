import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/theme/app_theme.dart';

class PanditVerificationScreen extends StatefulWidget {
  const PanditVerificationScreen({super.key});

  @override
  State<PanditVerificationScreen> createState() => _PanditVerificationScreenState();
}

class _PanditVerificationScreenState extends State<PanditVerificationScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Document uploads
  File? _idProof;
  File? _certificate;
  File? _photo;
  
  // Interview
  bool _isInterviewScheduled = false;
  DateTime? _interviewDate;
  TimeOfDay? _interviewTime;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, String type) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    
    if (image != null) {
      setState(() {
        if (type == 'id') {
          _idProof = File(image.path);
        } else if (type == 'certificate') {
          _certificate = File(image.path);
        } else if (type == 'photo') {
          _photo = File(image.path);
        }
      });
    }
  }

  void _showImagePicker(String type) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera, type);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery, type);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scheduleInterview() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    
    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      
      if (time != null) {
        setState(() {
          _interviewDate = date;
          _interviewTime = time;
          _isInterviewScheduled = true;
        });
      }
    }
  }

  void _submitVerification() {
    if (_idProof == null || _certificate == null || _photo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload all required documents'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    if (!_isInterviewScheduled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please schedule your interview'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    // Submit for verification
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verification Submitted'),
        content: const Text(
          'Your documents have been submitted for verification. '
          'You will be notified once the interview is scheduled and completed.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/pandit/dashboard');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pandit Verification'),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _DocumentsStep(
            idProof: _idProof,
            certificate: _certificate,
            photo: _photo,
            onPickImage: _showImagePicker,
            onNext: () {
              _pageController.animateToPage(
                1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
              setState(() => _currentStep = 1);
            },
          ),
          _InterviewStep(
            isScheduled: _isInterviewScheduled,
            interviewDate: _interviewDate,
            interviewTime: _interviewTime,
            onSchedule: _scheduleInterview,
            onBack: () {
              _pageController.animateToPage(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
              setState(() => _currentStep = 0);
            },
            onSubmit: _submitVerification,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (_currentStep > 0)
              OutlinedButton(
                onPressed: () {
                  _pageController.animateToPage(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  setState(() => _currentStep = 0);
                },
                child: const Text('Back'),
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: _currentStep == 0
                  ? () {
                      _pageController.animateToPage(
                        1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                      setState(() => _currentStep = 1);
                    }
                  : _submitVerification,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.yellowPrimary,
                foregroundColor: AppTheme.textDark,
              ),
              child: Text(_currentStep == 0 ? 'Next' : 'Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentsStep extends StatelessWidget {
  final File? idProof;
  final File? certificate;
  final File? photo;
  final Function(String) onPickImage;
  final VoidCallback onNext;

  const _DocumentsStep({
    required this.idProof,
    required this.certificate,
    required this.photo,
    required this.onPickImage,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload Verification Documents',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Please upload the following documents for verification',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          // ID Proof
          _DocumentUploadCard(
            title: 'ID Proof',
            subtitle: 'Aadhar Card, PAN Card, or Passport',
            file: idProof,
            onUpload: () => onPickImage('id'),
          ),
          const SizedBox(height: 16),
          // Certificate
          _DocumentUploadCard(
            title: 'Astrology Certificate',
            subtitle: 'Your certification or qualification proof',
            file: certificate,
            onUpload: () => onPickImage('certificate'),
          ),
          const SizedBox(height: 16),
          // Photo
          _DocumentUploadCard(
            title: 'Profile Photo',
            subtitle: 'A clear photo of yourself',
            file: photo,
            onUpload: () => onPickImage('photo'),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.yellowPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppTheme.yellowPrimary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'After document verification, you will be scheduled for an online interview.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentUploadCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final File? file;
  final VoidCallback onUpload;

  const _DocumentUploadCard({
    required this.title,
    required this.subtitle,
    required this.file,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onUpload,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: file != null
                      ? AppTheme.successGreen.withOpacity(0.2)
                      : AppTheme.yellowPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  file != null ? Icons.check_circle : Icons.upload_file,
                  color: file != null ? AppTheme.successGreen : AppTheme.yellowPrimary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (file != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        file!.path.split('/').last,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.successGreen,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (file != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    // Remove file
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InterviewStep extends StatelessWidget {
  final bool isScheduled;
  final DateTime? interviewDate;
  final TimeOfDay? interviewTime;
  final VoidCallback onSchedule;
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  const _InterviewStep({
    required this.isScheduled,
    required this.interviewDate,
    required this.interviewTime,
    required this.onSchedule,
    required this.onBack,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schedule Online Interview',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'After document verification, you will have an online interview with our team.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          if (!isScheduled) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(
                      Icons.video_call,
                      size: 64,
                      color: AppTheme.yellowPrimary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Schedule Your Interview',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select a date and time for your online interview. '
                      'The interview will be conducted via video call within the app.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: onSchedule,
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Schedule Interview'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.yellowPrimary,
                        foregroundColor: AppTheme.textDark,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 64,
                      color: AppTheme.successGreen,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Interview Scheduled',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _InfoCard(
                      icon: Icons.calendar_today,
                      label: 'Date',
                      value: interviewDate != null
                          ? '${interviewDate!.day}/${interviewDate!.month}/${interviewDate!.year}'
                          : 'Not set',
                    ),
                    const SizedBox(height: 12),
                    _InfoCard(
                      icon: Icons.access_time,
                      label: 'Time',
                      value: interviewTime != null
                          ? '${interviewTime!.hour}:${interviewTime!.minute.toString().padLeft(2, '0')}'
                          : 'Not set',
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: onSchedule,
                      icon: const Icon(Icons.edit),
                      label: const Text('Reschedule'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.yellowPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppTheme.yellowPrimary),
                      const SizedBox(width: 8),
                      Text(
                        'What to Expect',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _ExpectationItem(
                    text: 'Interview will be conducted via video call',
                  ),
                  _ExpectationItem(
                    text: 'Duration: 15-30 minutes',
                  ),
                  _ExpectationItem(
                    text: 'Questions about your astrology knowledge and experience',
                  ),
                  _ExpectationItem(
                    text: 'After successful interview, admin will set your rates',
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.creamPrimary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.yellowPrimary),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
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

class _ExpectationItem extends StatelessWidget {
  final String text;

  const _ExpectationItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline,
              size: 16, color: AppTheme.yellowPrimary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

