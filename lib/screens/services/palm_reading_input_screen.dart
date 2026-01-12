import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/theme/app_theme.dart';

class PalmReadingInputScreen extends StatefulWidget {
  const PalmReadingInputScreen({super.key});

  @override
  State<PalmReadingInputScreen> createState() => _PalmReadingInputScreenState();
}

class _PalmReadingInputScreenState extends State<PalmReadingInputScreen> {
  File? _imageFile;
  String _selectedGender = 'Male';
  final _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _handleAnalyze() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a photo of your palm')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() => _isLoading = false);
      // Navigate to AI Chat with Palm Reading context
      context.push('/ai-pandit/chat?panditId=ai_pandit_3'); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Palm Reading', style: TextStyle(color: AppTheme.textDark)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
         decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryLight.withOpacity(0.3),
              AppTheme.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Upload Your Palm Photo',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Take a clear photo of your dominant hand for accurate analysis.',
                  style: TextStyle(color: AppTheme.neutralMedium),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
          
                // Image Picker Area
                GestureDetector(
                  onTap: () => _showImageSourceSheet(),
                  child: Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _imageFile != null ? AppTheme.primaryOrange : AppTheme.forestBackground,
                        width: 2,
                        style: _imageFile != null ? BorderStyle.solid : BorderStyle.solid,
                      ),
                      boxShadow: [
                         BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _imageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.file(_imageFile!, fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt_outlined,
                                size: 64,
                                color: AppTheme.primaryOrange.withOpacity(0.6),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tap to Upload',
                                style: TextStyle(
                                  color: AppTheme.primaryOrange.withOpacity(0.8),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 32),
          
                // Gender Selection
                const Text(
                  'Select Gender',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _GenderCard(
                        label: 'Male',
                        icon: Icons.male,
                        isSelected: _selectedGender == 'Male',
                        onTap: () => setState(() => _selectedGender = 'Male'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _GenderCard(
                        label: 'Female',
                        icon: Icons.female,
                        isSelected: _selectedGender == 'Female',
                        onTap: () => setState(() => _selectedGender = 'Female'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
          
                // Action Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleAnalyze,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Analyze Destiny',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.primaryOrange),
              title: const Text('Camera'),
              onTap: () {
                context.pop();
                _pickImage(ImageSource.camera);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.primaryOrange),
              title: const Text('Gallery'),
              onTap: () {
                context.pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryOrange.withOpacity(0.1) : AppTheme.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryOrange : AppTheme.forestBackground,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppTheme.primaryOrange : AppTheme.neutralMedium,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryOrange : AppTheme.neutralMedium,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
