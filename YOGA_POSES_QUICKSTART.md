# Yoga Poses Feature - Quick Start Guide

## 🚀 Getting Started

This guide will help you quickly test and use the new Yoga Poses feature.

---

## 📋 Prerequisites

Make sure you have:
- ✅ Flutter SDK installed
- ✅ App dependencies installed (`flutter pub get`)
- ✅ Device/emulator ready

---

## 🏃 Quick Test (5 Minutes)

### Step 1: Run the App
```bash
cd /Users/harshdev/Documents/Projects/astroapp
flutter pub get
flutter run
```

### Step 2: Navigate to Yoga Poses

**Option A: From Yoga Sutras (Recommended)**
1. Open the app
2. Go to **Dashboard** → **Education** section
3. Tap **Yoga Sutras**
4. Open any chapter (e.g., Chapter 1)
5. Look for the **"View Yoga Poses"** floating button (bottom right)
6. Tap it

**Option B: Direct Navigation (For Testing)**
You can also navigate directly by adding a temporary button in your dashboard or using deep linking:
```dart
context.push('/education/yoga-poses');
```

### Step 3: Test the Features

**On Yoga Poses Screen:**
- ✅ See grid of 50 poses
- ✅ Type "tree" in search bar → Should show Tree Pose
- ✅ Tap "Standing" filter → Shows only standing poses
- ✅ Tap "Beginner" filter → Shows only beginner poses
- ✅ Tap any pose card

**On Pose Detail Screen:**
- ✅ See pose name (English and Sanskrit)
- ✅ See difficulty badge and category
- ✅ Scroll through Benefits section
- ✅ Scroll through Instructions section
- ✅ Scroll through Precautions section
- ✅ Tap **"Mark as Practiced"** button
- ✅ See practice counter increment
- ✅ Go back and return → Counter should persist

---

## 🎯 Key Features to Test

### 1. Search Functionality
```
Search Term → Expected Results
─────────────────────────────────
"tree"      → Tree Pose
"warrior"   → Warrior I, II, III
"cobra"     → Cobra Pose
"downward"  → Downward-Facing Dog
"lotus"     → Lotus Pose
"balancing" → All balancing poses
```

### 2. Category Filters
```
Filter      → Number of Poses
──────────────────────────────
All         → 50 poses
Standing    → 12 poses
Sitting     → 12 poses
Lying       → 9 poses
Balancing   → 9 poses
Twisting    → 2 poses
Inversion   → 6 poses
```

### 3. Difficulty Distribution
```
Difficulty   → Number of Poses → Badge Color
────────────────────────────────────────────
Beginner     → 22 poses        → Green
Intermediate → 20 poses        → Orange
Advanced     → 8 poses         → Red
```

### 4. Practice Tracking
1. Open any pose detail
2. Tap "Mark as Practiced"
3. Button turns green, shows "Practiced"
4. Practice count shows at top (e.g., "🏆 Practiced 1 time")
5. Tap again to toggle off
6. Close app and reopen → Count persists

---

## 🐛 Troubleshooting

### Issue: "Failed to load yoga poses"

**Solution:**
```bash
# Make sure assets are included
flutter clean
flutter pub get
flutter run
```

### Issue: Images not showing

**Expected Behavior:**
- Images are currently placeholders (category icons)
- This is normal until you add actual pose images
- See `assets/images/yoga/README.md` for how to add images

### Issue: Route not found

**Solution:**
```bash
# Make sure you've saved all files and hot restarted
# Hot reload is not enough for route changes
# Press 'R' in terminal or stop and restart app
```

### Issue: JSON parsing error

**Solution:**
```bash
# Validate the JSON file
python3 -m json.tool assets/data/yoga/yoga_poses.json

# If invalid, check for:
# - Missing commas
# - Trailing commas
# - Unescaped quotes
# - Incorrect brackets
```

---

## 📱 User Flows to Test

### Flow 1: Discovery from Yoga Sutras
```
Dashboard
  → Education
    → Yoga Sutras
      → Chapter 1
        → [View Yoga Poses] button
          → Yoga Poses Grid
            → Select a pose
              → Pose Details
                → Mark as Practiced
```

### Flow 2: Search and Practice
```
Yoga Poses Grid
  → Search "warrior"
    → See 3 warrior poses
      → Tap Warrior I
        → Read instructions
          → Mark as Practiced
            → Back to grid
              → Tap Warrior II
                → Mark as Practiced
```

### Flow 3: Filter by Difficulty
```
Yoga Poses Grid
  → Tap "Beginner" filter
    → See 22 beginner poses
      → Tap any pose
        → Practice it
          → Back
            → Try another beginner pose
```

---

## 🎨 Visual Verification

### Yoga Poses Grid
- ✅ Cards have rounded corners
- ✅ Difficulty badges are color-coded
- ✅ Category icons are visible
- ✅ Sanskrit names are in italic
- ✅ Grid has 2 columns
- ✅ Cards have shadows

### Pose Detail Screen
- ✅ Large image area at top
- ✅ Collapsible app bar
- ✅ Info chips are color-coded
- ✅ Benefits have green checkmarks
- ✅ Instructions have numbered circles
- ✅ Precautions have orange info icons
- ✅ Floating action button at bottom

---

## 📊 Data Verification

### Sample Poses to Check

**Beginner:**
- Tadasana (Mountain Pose)
- Balasana (Child's Pose)
- Shavasana (Corpse Pose)

**Intermediate:**
- Bakasana (Crow Pose)
- Navasana (Boat Pose)
- Ustrasana (Camel Pose)

**Advanced:**
- Sirsasana (Headstand)
- Padmasana (Lotus Pose)
- Hanumanasana (Splits)

### Verify Each Pose Has:
- ✅ English name
- ✅ Sanskrit name with diacritics
- ✅ Category
- ✅ Difficulty level
- ✅ Duration
- ✅ 4-6 benefits
- ✅ 6-10 instructions
- ✅ 3-5 precautions

---

## 🔍 Edge Cases to Test

### Empty States
1. Search for "xyz123" → Should show "No poses found"
2. Filter by category, then search → Should combine filters

### Navigation
1. Deep link directly to pose detail
2. Back button from poses grid → Returns to Yoga Sutras
3. Back button from pose detail → Returns to poses grid

### Persistence
1. Mark 5 poses as practiced
2. Close app completely
3. Reopen app
4. Check those 5 poses → Counters should persist

### Performance
1. Scroll through all 50 poses → Should be smooth
2. Search while scrolling → Should update instantly
3. Switch filters rapidly → Should handle without lag

---

## 📝 Quick Reference

### Important Files
```
Data:     assets/data/yoga/yoga_poses.json
Model:    lib/models/yoga_pose_model.dart
Service:  lib/features/education/services/yoga_repository.dart
Screens:  lib/screens/education/yoga_poses_screen.dart
          lib/screens/education/yoga_pose_detail_screen.dart
Routes:   lib/core/routes/app_router.dart
```

### Routes
```
/education/yoga-poses           → Poses grid
/education/yoga-pose/:id        → Pose detail
/education/reader/yoga_sutras   → Yoga Sutras (with button)
```

### SharedPreferences Keys
```
practiced_{poseId}              → bool (is practiced)
practice_count_{poseId}         → int (times practiced)
```

---

## ✅ Acceptance Criteria

The feature is working correctly if:

- ✅ All 50 poses load without errors
- ✅ Search returns correct results
- ✅ Filters work properly
- ✅ Pose details display all sections
- ✅ Practice tracking persists
- ✅ Navigation works smoothly
- ✅ No console errors
- ✅ UI looks polished
- ✅ Performance is smooth

---

## 🎓 Next Steps

After testing:

1. **Add Images** (Optional)
   - See `assets/images/yoga/README.md`
   - 50 images needed (one per pose)
   - App works fine without them

2. **Customize** (Optional)
   - Adjust colors in theme
   - Modify card layouts
   - Add more poses to JSON

3. **Extend** (Optional)
   - Add video demonstrations
   - Create practice sequences
   - Build timer feature

---

## 📞 Support

If you encounter issues:

1. Check console for error messages
2. Verify JSON is valid: `python3 -m json.tool assets/data/yoga/yoga_poses.json`
3. Run `flutter clean && flutter pub get`
4. Review documentation in `YOGA_POSES_FEATURE.md`
5. Check example data in `YOGA_POSE_EXAMPLE.md`

---

## 🎉 Success!

If you can:
- ✅ Navigate from Yoga Sutras to Yoga Poses
- ✅ Search and filter poses
- ✅ View pose details
- ✅ Mark poses as practiced
- ✅ See practice counts persist

**Then the feature is working perfectly!** 🧘‍♀️

---

**Happy Testing!** 🚀
