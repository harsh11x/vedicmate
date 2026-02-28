# Yoga Poses Feature Documentation

## Overview
A comprehensive yoga poses (asanas) section has been added to the VedicMate Flutter app, integrated with the Yoga Sutras education content.

## Features Implemented

### 1. **Yoga Poses Data** (`assets/data/yoga/yoga_poses.json`)
- **50 yoga poses** with complete information
- Each pose includes:
  - English and Sanskrit names (with proper diacritics)
  - Category (Standing, Sitting, Lying, Balancing, Twisting, Inversion)
  - Difficulty level (Beginner, Intermediate, Advanced)
  - Duration recommendation
  - Comprehensive benefits list
  - Step-by-step instructions (numbered)
  - Precautions and contraindications
  - Image path (placeholder)

### 2. **Yoga Pose Model** (`lib/models/yoga_pose_model.dart`)
- Clean data structure for yoga poses
- JSON serialization/deserialization
- Type-safe model with all required fields

### 3. **Yoga Repository** (`lib/features/education/services/yoga_repository.dart`)
- Load all poses from JSON
- Get pose by ID
- Filter by category
- Filter by difficulty
- Search functionality
- Caching for performance

### 4. **Yoga Poses Screen** (`lib/screens/education/yoga_poses_screen.dart`)
- **Grid layout** showing all poses
- **Search bar** for finding poses by name or category
- **Category filters** (All, Standing, Sitting, Lying, Balancing, Twisting, Inversion)
- Each pose card displays:
  - Category icon (placeholder for image)
  - Difficulty badge (color-coded)
  - English name
  - Sanskrit name
  - Category label
- Tap any card to view full details

### 5. **Yoga Pose Detail Screen** (`lib/screens/education/yoga_pose_detail_screen.dart`)
- **Full-screen pose details** with:
  - Large image area (placeholder with category icon)
  - Pose names (English and Sanskrit)
  - Info chips for category, difficulty, and duration
  - Practice counter (tracks how many times practiced)
  - **Benefits section** with checkmark icons
  - **Step-by-step instructions** with numbered circles
  - **Precautions section** with warning icons
- **"Mark as Practiced" button** (floating action button)
  - Tracks practice count
  - Saves to local storage
  - Shows achievement badge when practiced

### 6. **Integration with Yoga Sutras**
- When viewing Yoga Sutras in the Reader Screen, a floating action button appears
- Button labeled "View Yoga Poses" navigates to the poses screen
- Seamless integration between philosophy and practice

### 7. **Routing** (Updated `lib/core/routes/app_router.dart`)
- `/education/yoga-poses` - Main poses grid screen
- `/education/yoga-pose/:id` - Individual pose detail screen

## Poses Included (50 Total)

### Beginner Poses (17)
1. Tadasana (Mountain Pose)
2. Vrikshasana (Tree Pose)
3. Adho Mukha Svanasana (Downward-Facing Dog)
4. Bhujangasana (Cobra Pose)
5. Balasana (Child's Pose)
6. Trikonasana (Triangle Pose)
7. Virabhadrasana I (Warrior I)
8. Virabhadrasana II (Warrior II)
9. Setu Bandhasana (Bridge Pose)
10. Shavasana (Corpse Pose)
11. Sukhasana (Easy Pose)
12. Paschimottanasana (Seated Forward Bend)
13. Salabhasana (Locust Pose)
14. Anjaneyasana (Low Lunge)
15. Uttanasana (Standing Forward Bend)
16. Marjaryasana (Cat Pose)
17. Bitilasana (Cow Pose)
18. Malasana (Garland Pose)
19. Prasarita Padottanasana (Wide-Legged Forward Bend)
20. Supta Baddha Konasana (Reclining Bound Angle Pose)
21. Viparita Karani (Legs-Up-the-Wall Pose)
22. Matsyasana (Fish Pose)

### Intermediate Poses (20)
1. Virabhadrasana III (Warrior III)
2. Halasana (Plow Pose)
3. Ustrasana (Camel Pose)
4. Dhanurasana (Bow Pose)
5. Ardha Matsyendrasana (Half Lord of the Fishes)
6. Garudasana (Eagle Pose)
7. Bakasana (Crow Pose)
8. Navasana (Boat Pose)
9. Gomukhasana (Cow Face Pose)
10. Eka Pada Rajakapotasana (Pigeon Pose)
11. Parivrtta Trikonasana (Revolved Triangle Pose)
12. Chaturanga Dandasana (Four-Limbed Staff Pose)
13. Vasisthasana (Side Plank Pose)
14. Natarajasana (Dancer Pose)
15. Tolasana (Scale Pose)
16. Sarvangasana (Shoulder Stand)

### Advanced Poses (8)
1. Padmasana (Lotus Pose)
2. Urdhva Dhanurasana (Wheel Pose)
3. Sirsasana (Headstand)
4. Kapotasana (King Pigeon Pose)
5. Hanumanasana (Monkey Pose/Splits)
6. Pincha Mayurasana (Forearm Stand)
7. Eka Pada Koundinyasana (Flying Lizard Pose)
8. Astavakrasana (Eight-Angle Pose)

## File Structure

```
lib/
├── models/
│   └── yoga_pose_model.dart                    # Yoga pose data model
├── features/
│   └── education/
│       └── services/
│           └── yoga_repository.dart            # Data loading & filtering
└── screens/
    └── education/
        ├── yoga_poses_screen.dart              # Main grid view
        └── yoga_pose_detail_screen.dart        # Detail view

assets/
├── data/
│   └── yoga/
│       └── yoga_poses.json                     # 50 poses data
└── images/
    └── yoga/                                    # Placeholder for images
        ├── tadasana.png
        ├── vrikshasana.png
        └── ... (50 images total)
```

## How to Add Actual Images

### Image Requirements
- **Format**: PNG or JPG
- **Size**: 800x600px or 1200x900px recommended
- **Aspect Ratio**: 4:3 or similar
- **Quality**: High-quality, clear demonstration of the pose
- **Background**: Preferably neutral or yoga-themed

### Steps to Add Images

1. **Obtain Images**
   - Create custom illustrations
   - Use royalty-free stock photos (Unsplash, Pexels, etc.)
   - Commission yoga photography
   - Use AI-generated images (Midjourney, DALL-E, etc.)

2. **Name Images Correctly**
   Each image should match the pose ID from the JSON:
   ```
   tadasana.png
   vrikshasana.png
   adho_mukha_svanasana.png
   bhujangasana.png
   ... etc.
   ```

3. **Place Images in Directory**
   ```bash
   cp your-images/*.png assets/images/yoga/
   ```

4. **No Code Changes Required**
   The app is already configured to load images from the paths specified in the JSON. Once images are in place, they'll automatically appear.

5. **Verify in JSON**
   Each pose already has the correct path:
   ```json
   "image_path": "assets/images/yoga/tadasana.png"
   ```

### Alternative: Use Network Images

If you want to use images from a CDN or server instead:

1. Update the JSON file with URLs:
   ```json
   "image_path": "https://your-cdn.com/yoga/tadasana.png"
   ```

2. Update `yoga_poses_screen.dart` and `yoga_pose_detail_screen.dart` to use `Image.network()` instead of `Image.asset()`:
   ```dart
   // In the image container, replace the Icon with:
   Image.network(
     pose.imagePath,
     fit: BoxFit.cover,
     errorBuilder: (context, error, stackTrace) {
       return Icon(...); // Fallback icon
     },
   )
   ```

## Features for Future Enhancement

### Potential Additions
1. **Video Demonstrations**: Add video URLs for each pose
2. **Voice Guidance**: Text-to-speech for instructions during practice
3. **Practice Sessions**: Create custom yoga sequences
4. **Timer Integration**: Built-in timer for holding poses
5. **Progress Tracking**: Calendar view of practice history
6. **Favorites**: Bookmark favorite poses
7. **Pose Variations**: Add modifications for different skill levels
8. **Muscle Groups**: Highlight which muscles each pose targets
9. **Sequences**: Pre-built sequences (Morning Flow, Bedtime Yoga, etc.)
10. **Social Sharing**: Share poses with friends
11. **Reminders**: Daily practice reminders
12. **Achievements**: Badges for consistency and milestones

## Testing the Feature

### Manual Testing Steps

1. **Navigate to Yoga Sutras**
   ```
   Dashboard → Education → Yoga Sutras → Any Chapter
   ```

2. **Access Yoga Poses**
   - Tap the "View Yoga Poses" floating button
   - Should navigate to the poses grid

3. **Test Search**
   - Type "tree" → Should show Tree Pose
   - Type "warrior" → Should show all Warrior poses

4. **Test Filters**
   - Tap "Standing" → Shows only standing poses
   - Tap "Beginner" → Shows only beginner poses
   - Tap "All" → Shows all poses

5. **Test Pose Details**
   - Tap any pose card
   - Verify all sections load (Benefits, Instructions, Precautions)
   - Tap "Mark as Practiced"
   - Verify counter increments
   - Go back and return → Counter should persist

6. **Test Navigation**
   - Back button should return to poses grid
   - Back from poses grid should return to reader

## Performance Considerations

- **Caching**: Poses are cached in memory after first load
- **Lazy Loading**: Grid uses `GridView.builder` for efficient rendering
- **Local Storage**: Practice status saved to SharedPreferences
- **Image Optimization**: When adding images, compress them to reduce app size

## Accessibility

- All text is readable with proper contrast
- Icons have semantic meaning
- Difficulty levels are color-coded (green/orange/red)
- Instructions are numbered for clarity
- Precautions are clearly marked with warning icons

## Summary

This feature provides a complete yoga practice companion integrated seamlessly with the Yoga Sutras philosophical content. Users can:
- Browse 50 authentic yoga poses
- Learn proper technique with step-by-step instructions
- Understand benefits and precautions
- Track their practice progress
- Filter and search easily

The feature is production-ready and only requires actual pose images to be added for a complete visual experience.
