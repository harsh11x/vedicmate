import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/theme/app_theme.dart';

class VastuInputScreen extends StatefulWidget {
  const VastuInputScreen({super.key});

  @override
  State<VastuInputScreen> createState() => _VastuInputScreenState();
}

class _VastuInputScreenState extends State<VastuInputScreen> {
  File? _imageFile;
  final _descriptionController = TextEditingController();
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
    // Vastu analysis might not require an image always, but let's encourage it.
    // We'll require at least one input (image or description).
    if (_imageFile == null && _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a floor plan or describe your space')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() => _isLoading = false);
      // Navigate to AI Chat with Vastu context
      context.push('/ai-pandit/chat?panditId=ai_pandit_8'); 
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Vastu Shastra', style: TextStyle(color: AppTheme.textDark)),
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
                  'Analyze Your Space',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Upload a floor plan or photo of the room you want to check for Vastu compliance.',
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
                        color: _imageFile != null ? AppTheme.successGreen : AppTheme.forestBackground,
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
                                Icons.add_photo_alternate_outlined,
                                size: 64,
                                color: AppTheme.successGreen.withOpacity(0.6),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Upload Floor Plan / Photo',
                                style: TextStyle(
                                  color: AppTheme.successGreen.withOpacity(0.8),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 32),
          
                // Description Input
                const Text(
                  'Describe the Issue (Optional)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'E.g., "I feel drained in my bedroom", "Where should I place my study table?"',
                    filled: true,
                    fillColor: AppTheme.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppTheme.forestBackground),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppTheme.successGreen, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
          
                // Action Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleAnalyze,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Check Vastu',
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
              leading: const Icon(Icons.camera_alt, color: AppTheme.successGreen),
              title: const Text('Camera'),
              onTap: () {
                context.pop();
                _pickImage(ImageSource.camera);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.successGreen),
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
