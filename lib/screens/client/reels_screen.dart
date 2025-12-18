import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../../core/theme/app_theme.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _commentController = TextEditingController();
  String? _selectedReelId;
  bool _isUploading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _uploadVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);

    if (video == null) return;

    setState(() => _isUploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('reels')
          .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.mp4');

      final uploadTask = storageRef.putFile(File(video.path));
      final snapshot = await uploadTask;
      final videoUrl = await snapshot.ref.getDownloadURL();

      // Save to Firestore
      await FirebaseFirestore.instance.collection('reels').add({
        'userId': user.uid,
        'userName': user.displayName ?? 'User',
        'userPhoto': user.photoURL ?? '',
        'videoUrl': videoUrl,
        'thumbnailUrl': '', // You can generate thumbnail later
        'caption': '',
        'likes': [],
        'comments': [],
        'shares': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video uploaded successfully!'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading video: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _toggleLike(String reelId, List<dynamic> likes) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final isLiked = likes.contains(user.uid);
    await FirebaseFirestore.instance.collection('reels').doc(reelId).update({
      'likes': isLiked
          ? FieldValue.arrayRemove([user.uid])
          : FieldValue.arrayUnion([user.uid]),
    });
  }

  Future<void> _addComment(String reelId) async {
    if (_commentController.text.trim().isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final comment = {
      'userId': user.uid,
      'userName': user.displayName ?? 'User',
      'userPhoto': user.photoURL ?? '',
      'text': _commentController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('reels').doc(reelId).update({
      'comments': FieldValue.arrayUnion([comment]),
    });

    _commentController.clear();
    setState(() => _selectedReelId = null);
  }

  Future<void> _shareReel(String videoUrl, String reelId, String caption) async {
    final shareText = caption.isNotEmpty
        ? '$caption\n\nWatch on Vedic Mate: $videoUrl'
        : 'Check out this video on Vedic Mate: $videoUrl';

    // Show share options
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ShareOptionsSheet(
        videoUrl: videoUrl,
        shareText: shareText,
        reelId: reelId,
      ),
    );

    if (result == 'copied') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Link copied to clipboard!'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('reels')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryOrange),
                );
              }

              final reels = snapshot.data!.docs;

              if (reels.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.video_library, size: 80, color: AppTheme.neutralMedium),
                      const SizedBox(height: 20),
                      Text(
                        'No reels yet',
                        style: TextStyle(color: AppTheme.neutralMedium, fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload your first reel!',
                        style: TextStyle(color: AppTheme.neutralLight, fontSize: 14),
                      ),
                    ],
                  ),
                );
              }

              return PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: reels.length,
                itemBuilder: (context, index) {
                  final reel = reels[index];
                  final data = reel.data() as Map<String, dynamic>;
                  return _ReelItem(
                    reelId: reel.id,
                    data: data,
                    onLike: () => _toggleLike(reel.id, List<String>.from(data['likes'] ?? [])),
                    onComment: () => setState(() => _selectedReelId = reel.id),
                    onShare: () => _shareReel(
                      data['videoUrl'] ?? '',
                      reel.id,
                      data['caption'] ?? '',
                    ),
                  );
                },
              );
            },
          ),
          // Upload Button
          Positioned(
            bottom: 100,
            right: 20,
            child: FloatingActionButton(
              onPressed: _isUploading ? null : _uploadVideo,
              backgroundColor: AppTheme.primaryOrange,
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.add, color: Colors.white),
            ),
          ),
          // Comments Sheet
          if (_selectedReelId != null)
            _CommentsSheet(
              reelId: _selectedReelId!,
              commentController: _commentController,
              onComment: () => _addComment(_selectedReelId!),
              onClose: () => setState(() => _selectedReelId = null),
            ),
        ],
      ),
    );
  }
}

class _ReelItem extends StatelessWidget {
  final String reelId;
  final Map<String, dynamic> data;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const _ReelItem({
    required this.reelId,
    required this.data,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final likes = List<String>.from(data['likes'] ?? []);
    final isLiked = user != null && likes.contains(user.uid);
    final comments = List<Map<String, dynamic>>.from(data['comments'] ?? []);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Video Player Placeholder
        Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_circle_outline, size: 80, color: Colors.white.withOpacity(0.5)),
                const SizedBox(height: 16),
                Text(
                  'Video Player',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  data['videoUrl'] ?? '',
                  style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        // Gradient Overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Right Side Actions
        Positioned(
          right: 16,
          bottom: 100,
          child: Column(
            children: [
              _ActionButton(
                icon: isLiked ? Icons.favorite : Icons.favorite_border,
                label: '${likes.length}',
                color: isLiked ? AppTheme.errorRed : Colors.white,
                onTap: onLike,
              ),
              const SizedBox(height: 24),
              _ActionButton(
                icon: Icons.comment,
                label: '${comments.length}',
                color: Colors.white,
                onTap: onComment,
              ),
              const SizedBox(height: 24),
              _ActionButton(
                icon: Icons.share,
                label: '${data['shares'] ?? 0}',
                color: Colors.white,
                onTap: onShare,
              ),
            ],
          ),
        ),
        // Bottom Info
        Positioned(
          bottom: 20,
          left: 16,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: data['userPhoto'] != null && data['userPhoto'].toString().isNotEmpty
                        ? NetworkImage(data['userPhoto'])
                        : null,
                    child: data['userPhoto'] == null || data['userPhoto'].toString().isEmpty
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    data['userName'] ?? 'User',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (data['caption'] != null && data['caption'].toString().isNotEmpty)
                Text(
                  data['caption'],
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _CommentsSheet extends StatelessWidget {
  final String reelId;
  final TextEditingController commentController;
  final VoidCallback onComment;
  final VoidCallback onClose;

  const _CommentsSheet({
    required this.reelId,
    required this.commentController,
    required this.onComment,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.neutralLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text(
                      'Comments',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: onClose,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('reels').doc(reelId).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    final comments = List<Map<String, dynamic>>.from(
                      data?['comments'] ?? [],
                    );

                    if (comments.isEmpty) {
                      return Center(
                        child: Text(
                          'No comments yet',
                          style: TextStyle(color: AppTheme.neutralMedium),
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: comment['userPhoto'] != null
                                    ? NetworkImage(comment['userPhoto'])
                                    : null,
                                child: comment['userPhoto'] == null
                                    ? const Icon(Icons.person)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      comment['userName'] ?? 'User',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      comment['text'] ?? '',
                                      style: TextStyle(
                                        color: AppTheme.neutralDark,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.neutralSoft,
                  border: Border(
                    top: BorderSide(color: AppTheme.neutralLight),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: InputDecoration(
                          hintText: 'Add a comment...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppTheme.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onComment,
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ShareOptionsSheet extends StatelessWidget {
  final String videoUrl;
  final String shareText;
  final String reelId;

  const _ShareOptionsSheet({
    required this.videoUrl,
    required this.shareText,
    required this.reelId,
  });

  Future<void> _shareToWhatsApp() async {
    final encodedText = Uri.encodeComponent(shareText);
    final whatsappUrl = 'whatsapp://send?text=$encodedText';
    final whatsappWebUrl = 'https://wa.me/?text=$encodedText';
    
    try {
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl));
      } else if (await canLaunchUrl(Uri.parse(whatsappWebUrl))) {
        await launchUrl(Uri.parse(whatsappWebUrl), mode: LaunchMode.externalApplication);
      } else {
        await Share.share(shareText);
      }
      // Update share count
      await FirebaseFirestore.instance.collection('reels').doc(reelId).update({
        'shares': FieldValue.increment(1),
      });
    } catch (e) {
      await Share.share(shareText);
    }
  }

  Future<void> _copyLink() async {
    await Clipboard.setData(ClipboardData(text: videoUrl));
    // Update share count
    await FirebaseFirestore.instance.collection('reels').doc(reelId).update({
      'shares': FieldValue.increment(1),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Share Reel',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ShareOption(
                icon: Icons.link,
                label: 'Copy Link',
                color: AppTheme.infoBlue,
                onTap: () {
                  _copyLink();
                  Navigator.pop(context, 'copied');
                },
              ),
              _ShareOption(
                icon: Icons.chat,
                label: 'WhatsApp',
                color: AppTheme.successGreen,
                onTap: () {
                  _shareToWhatsApp();
                  Navigator.pop(context);
                },
              ),
              _ShareOption(
                icon: Icons.message,
                label: 'Messages',
                color: AppTheme.primaryOrange,
                onTap: () async {
                  final smsUrl = 'sms:?body=${Uri.encodeComponent(shareText)}';
                  try {
                    if (await canLaunchUrl(Uri.parse(smsUrl))) {
                      await launchUrl(Uri.parse(smsUrl));
                    } else {
                      await Share.share(shareText);
                    }
                    await FirebaseFirestore.instance.collection('reels').doc(reelId).update({
                      'shares': FieldValue.increment(1),
                    });
                  } catch (e) {
                    await Share.share(shareText);
                  }
                  Navigator.pop(context);
                },
              ),
              _ShareOption(
                icon: Icons.share,
                label: 'More',
                color: AppTheme.neutralDark,
                onTap: () async {
                  await Share.share(shareText, subject: 'Check out this reel on Vedic Mate');
                  await FirebaseFirestore.instance.collection('reels').doc(reelId).update({
                    'shares': FieldValue.increment(1),
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

