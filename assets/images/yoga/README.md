# Yoga Pose Images

This directory should contain images for all 50 yoga poses.

## Required Images (50 total)

### Standing Poses
- `tadasana.png` - Mountain Pose
- `vrikshasana.png` - Tree Pose
- `adho_mukha_svanasana.png` - Downward-Facing Dog
- `trikonasana.png` - Triangle Pose
- `virabhadrasana_1.png` - Warrior I Pose
- `virabhadrasana_2.png` - Warrior II Pose
- `virabhadrasana_3.png` - Warrior III Pose
- `anjaneyasana.png` - Low Lunge
- `uttanasana.png` - Standing Forward Bend
- `malasana.png` - Garland Pose
- `prasarita_padottanasana.png` - Wide-Legged Forward Bend
- `chaturanga_dandasana.png` - Four-Limbed Staff Pose

### Sitting Poses
- `balasana.png` - Child's Pose
- `padmasana.png` - Lotus Pose
- `sukhasana.png` - Easy Pose
- `paschimottanasana.png` - Seated Forward Bend
- `ustrasana.png` - Camel Pose
- `navasana.png` - Boat Pose
- `marjaryasana.png` - Cat Pose
- `bitilasana.png` - Cow Pose
- `gomukhasana.png` - Cow Face Pose
- `eka_pada_rajakapotasana.png` - Pigeon Pose
- `kapotasana.png` - King Pigeon Pose
- `hanumanasana.png` - Monkey Pose (Splits)

### Lying Poses
- `bhujangasana.png` - Cobra Pose
- `setu_bandhasana.png` - Bridge Pose
- `shavasana.png` - Corpse Pose
- `matsyasana.png` - Fish Pose
- `dhanurasana.png` - Bow Pose
- `salabhasana.png` - Locust Pose
- `supta_baddha_konasana.png` - Reclining Bound Angle Pose

### Balancing Poses
- `garudasana.png` - Eagle Pose
- `bakasana.png` - Crow Pose
- `vasisthasana.png` - Side Plank Pose
- `natarajasana.png` - Dancer Pose
- `tolasana.png` - Scale Pose
- `eka_pada_koundinyasana.png` - Flying Lizard Pose
- `astavakrasana.png` - Eight-Angle Pose

### Twisting Poses
- `ardha_matsyendrasana.png` - Half Lord of the Fishes Pose
- `parivrtta_trikonasana.png` - Revolved Triangle Pose

### Inversion Poses
- `halasana.png` - Plow Pose
- `viparita_karani.png` - Legs-Up-the-Wall Pose
- `urdhva_dhanurasana.png` - Wheel Pose
- `sirsasana.png` - Headstand
- `pincha_mayurasana.png` - Forearm Stand
- `sarvangasana.png` - Shoulder Stand

## Image Specifications

### Recommended Dimensions
- **Width**: 800-1200px
- **Height**: 600-900px
- **Aspect Ratio**: 4:3 or 16:9
- **Format**: PNG (with transparency) or JPG
- **File Size**: 100-500KB per image (compressed)

### Image Content Guidelines
1. **Clear demonstration** of the pose from the best viewing angle
2. **Neutral background** (white, light gray, or yoga studio setting)
3. **Professional quality** - well-lit, in focus
4. **Consistent style** across all images (same background, similar lighting)
5. **Person in frame** should be centered and clearly visible
6. **Proper alignment** - demonstrate correct form

### Where to Get Images

#### Option 1: Stock Photos (Free)
- **Unsplash**: https://unsplash.com/s/photos/yoga-poses
- **Pexels**: https://www.pexels.com/search/yoga/
- **Pixabay**: https://pixabay.com/images/search/yoga/
- Make sure to check license for commercial use

#### Option 2: AI-Generated
- **Midjourney**: Generate consistent yoga pose illustrations
- **DALL-E**: Create custom yoga pose images
- **Stable Diffusion**: Generate open-source images
- Example prompt: "Professional yoga instructor demonstrating [pose name], neutral background, high quality, 4:3 aspect ratio"

#### Option 3: Custom Photography
- Hire a yoga instructor and photographer
- Ensures consistency and authenticity
- Can match your app's branding

#### Option 4: Illustrations
- Commission a yoga illustrator
- Create a unique, branded look
- Often more affordable than photography
- Easier to maintain consistency

### Naming Convention
**IMPORTANT**: Image filenames MUST match the pose IDs in `yoga_poses.json` exactly.

Example:
```json
{
  "id": "tadasana",
  "image_path": "assets/images/yoga/tadasana.png"
}
```
The file must be named: `tadasana.png`

### Batch Processing Tips

If you have images with different names, use a batch rename tool:

**macOS/Linux:**
```bash
# Example: Rename "Mountain Pose.jpg" to "tadasana.png"
mv "Mountain Pose.jpg" tadasana.png
```

**Using a script:**
```bash
# Create a mapping file and use a script to rename
# See the JSON file for exact ID to pose name mapping
```

### Image Optimization

Before adding images, optimize them:

**Using ImageOptim (macOS):**
```bash
# Drag and drop images into ImageOptim app
```

**Using command line:**
```bash
# Install imagemagick
brew install imagemagick

# Resize and optimize
for img in *.jpg; do
  convert "$img" -resize 1200x900 -quality 85 "${img%.jpg}.png"
done
```

**Online tools:**
- TinyPNG: https://tinypng.com/
- Squoosh: https://squoosh.app/

## Current Status

Currently, the app uses **placeholder icons** based on the pose category. Once you add images here, they will automatically appear in the app.

## Testing Images

After adding images:

1. Run `flutter pub get` to ensure assets are recognized
2. Hot restart the app (not just hot reload)
3. Navigate to Yoga Poses screen
4. Verify images load correctly
5. Check detail screens for proper image display

## Fallback Behavior

If an image is missing, the app will display a category-appropriate icon instead:
- Standing poses: Accessibility icon
- Sitting poses: Seat icon
- Lying poses: Hotel/bed icon
- Balancing poses: Balance icon
- Twisting poses: Rotation icon
- Inversion poses: Flip icon
