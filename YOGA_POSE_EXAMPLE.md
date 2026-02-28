# Complete Yoga Pose Data Example

This document shows the complete data structure for one yoga pose as an example.

---

## Example: Vrikshasana (Tree Pose)

### Complete JSON Structure

```json
{
  "id": "vrikshasana",
  "name_english": "Tree Pose",
  "name_sanskrit": "Vṛkṣāsana",
  "category": "Balancing",
  "difficulty": "Beginner",
  "duration": "30-60 seconds per side",
  "image_path": "assets/images/yoga/vrikshasana.png",
  "benefits": [
    "Improves balance and stability",
    "Strengthens legs, ankles, and spine",
    "Opens hips and groin",
    "Improves concentration and focus",
    "Relieves sciatica"
  ],
  "instructions": [
    "Begin in Mountain Pose (Tadasana)",
    "Shift weight onto left foot",
    "Bend right knee and place right foot on inner left thigh or calf (avoid knee)",
    "Press foot and leg together",
    "Bring hands to prayer position at chest",
    "Focus gaze on a fixed point for balance",
    "Optionally raise arms overhead",
    "Hold, then repeat on other side"
  ],
  "precautions": [
    "Avoid if you have recent knee or hip injury",
    "Use wall support if balance is challenging",
    "Never place foot directly on knee joint"
  ]
}
```

---

## Field Descriptions

### Required Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `id` | String | Unique identifier (lowercase, underscores) | `"vrikshasana"` |
| `name_english` | String | Common English name | `"Tree Pose"` |
| `name_sanskrit` | String | Sanskrit name with diacritics | `"Vṛkṣāsana"` |
| `category` | String | Pose category | `"Balancing"` |
| `difficulty` | String | Difficulty level | `"Beginner"` |
| `duration` | String | Recommended hold time | `"30-60 seconds per side"` |
| `image_path` | String | Path to pose image | `"assets/images/yoga/vrikshasana.png"` |
| `benefits` | Array[String] | List of health benefits | See above |
| `instructions` | Array[String] | Step-by-step instructions | See above |
| `precautions` | Array[String] | Safety warnings | See above |

---

## Valid Values

### Categories (6 options)
- `"Standing"`
- `"Sitting"`
- `"Lying"`
- `"Balancing"`
- `"Twisting"`
- `"Inversion"`

### Difficulty Levels (3 options)
- `"Beginner"`
- `"Intermediate"`
- `"Advanced"`

### Duration Format
- Use natural language
- Include "per side" for asymmetric poses
- Examples:
  - `"30-60 seconds"`
  - `"1-3 minutes"`
  - `"30-60 seconds per side"`
  - `"5-15 minutes"`

### Image Path Format
```
assets/images/yoga/{pose_id}.png
```
Where `{pose_id}` matches the `id` field exactly.

---

## How This Data Appears in the App

### In Yoga Poses List Screen

**Card Display:**
```
┌─────────────────────────┐
│                         │
│    [Balance Icon]       │  ← Category icon
│                         │
│   [Beginner Badge] ←────┼─ Difficulty badge (green)
│                         │
├─────────────────────────┤
│ Tree Pose              │  ← English name
│ Vṛkṣāsana              │  ← Sanskrit name
│ 🔄 Balancing           │  ← Category
└─────────────────────────┘
```

### In Yoga Pose Detail Screen

**Full View:**
```
┌─────────────────────────────────────┐
│                                     │
│         [Large Image Area]          │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  Tree Pose                          │ ← English name (28px, bold)
│  Vṛkṣāsana                          │ ← Sanskrit name (20px, italic)
│                                     │
│  [Balancing] [Beginner] [30-60s]   │ ← Info chips
│                                     │
│  🏆 Practiced 5 times               │ ← Practice counter (if > 0)
│                                     │
├─────────────────────────────────────┤
│                                     │
│  ❤️ Benefits                        │
│  ✓ Improves balance and stability   │
│  ✓ Strengthens legs, ankles, spine  │
│  ✓ Opens hips and groin             │
│  ✓ Improves concentration and focus │
│  ✓ Relieves sciatica                │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  📋 Step-by-Step Instructions       │
│  ① Begin in Mountain Pose           │
│  ② Shift weight onto left foot      │
│  ③ Bend right knee and place...    │
│  ④ Press foot and leg together      │
│  ⑤ Bring hands to prayer position   │
│  ⑥ Focus gaze on a fixed point      │
│  ⑦ Optionally raise arms overhead   │
│  ⑧ Hold, then repeat on other side  │
│                                     │
├─────────────────────────────────────┤
│                                     │
│  ⚠️ Precautions & Contraindications │
│  ℹ️ Avoid if you have recent knee   │
│     or hip injury                   │
│  ℹ️ Use wall support if balance is  │
│     challenging                     │
│  ℹ️ Never place foot directly on    │
│     knee joint                      │
│                                     │
└─────────────────────────────────────┘

         [Mark as Practiced] ←─────── Floating button
```

---

## Data Quality Guidelines

### Benefits
- List 4-6 specific benefits
- Focus on physical, mental, and therapeutic benefits
- Use clear, concise language
- Start with action verbs (Improves, Strengthens, Opens, Relieves, etc.)

### Instructions
- Provide 6-10 clear steps
- Start from a common starting position
- Use imperative mood ("Bend", "Place", "Press")
- Include breathing cues when relevant
- End with exit instructions or "hold"

### Precautions
- List 3-5 important safety notes
- Mention specific injuries or conditions to avoid
- Provide modifications when possible
- Use clear warning language

---

## Adding a New Pose

To add a new yoga pose to the app:

1. **Choose a unique ID**
   ```
   Example: "utthita_parsvakonasana"
   ```

2. **Create the JSON entry**
   ```json
   {
     "id": "utthita_parsvakonasana",
     "name_english": "Extended Side Angle Pose",
     "name_sanskrit": "Utthita Pārśvakoṇāsana",
     "category": "Standing",
     "difficulty": "Intermediate",
     "duration": "30-60 seconds per side",
     "image_path": "assets/images/yoga/utthita_parsvakonasana.png",
     "benefits": [
       "Strengthens legs, knees, and ankles",
       "Stretches groin, spine, and shoulders",
       "Stimulates abdominal organs",
       "Increases stamina"
     ],
     "instructions": [
       "Stand with feet wide apart",
       "Turn right foot out 90 degrees",
       "Bend right knee over right ankle",
       "Place right hand on floor outside right foot",
       "Extend left arm over head",
       "Look up at left hand",
       "Hold, then repeat on other side"
     ],
     "precautions": [
       "Avoid if you have knee injury",
       "Use block under hand if needed",
       "Don't overextend if you have neck problems"
     ]
   }
   ```

3. **Add to the poses array** in `yoga_poses.json`
   ```json
   {
     "poses": [
       { ... existing poses ... },
       { ... your new pose ... }
     ]
   }
   ```

4. **Add the image** (optional but recommended)
   - Create/obtain image for the pose
   - Name it: `utthita_parsvakonasana.png`
   - Place in: `assets/images/yoga/`

5. **Test in the app**
   - Hot restart the app
   - Navigate to Yoga Poses
   - Search for your new pose
   - Verify all data displays correctly

---

## Validation Checklist

Before adding a pose, verify:

- ✅ ID is unique and lowercase with underscores
- ✅ English name is correct and properly capitalized
- ✅ Sanskrit name uses proper diacritics (ā, ī, ū, ṛ, ṃ, ḥ, ś, ṣ, ṇ, etc.)
- ✅ Category is one of the 6 valid options
- ✅ Difficulty is Beginner, Intermediate, or Advanced
- ✅ Duration is in natural language
- ✅ Image path follows the correct format
- ✅ Benefits list has 4-6 items
- ✅ Instructions have 6-10 clear steps
- ✅ Precautions have 3-5 safety notes
- ✅ JSON is properly formatted (no trailing commas, proper quotes)

---

## Common Mistakes to Avoid

❌ **Wrong ID format**
```json
"id": "Tree Pose"  // Should be: "vrikshasana"
```

❌ **Missing diacritics**
```json
"name_sanskrit": "Vrksasana"  // Should be: "Vṛkṣāsana"
```

❌ **Invalid category**
```json
"category": "Balance"  // Should be: "Balancing"
```

❌ **Inconsistent image path**
```json
"id": "vrikshasana",
"image_path": "assets/images/yoga/tree_pose.png"  // Should match ID
```

❌ **Single string instead of array**
```json
"benefits": "Improves balance"  // Should be: ["Improves balance"]
```

---

## Sanskrit Diacritics Reference

Common Sanskrit characters with diacritics:

| Character | Unicode | Example |
|-----------|---------|---------|
| ā | \u0101 | Āsana |
| ī | \u012B | Śīrṣa |
| ū | \u016B | Ūrdhva |
| ṛ | \u1E5B | Vṛkṣa |
| ṃ | \u1E43 | Saṃ |
| ḥ | \u1E25 | Duḥkha |
| ś | \u015B | Śava |
| ṣ | \u1E63 | Viṣṇu |
| ṇ | \u1E47 | Pāṇi |
| ñ | \u00F1 | Añjali |

You can copy these characters or use a Sanskrit transliteration tool.

---

## Resources

- **Sanskrit Transliteration**: https://www.sanskritweb.net/itrans/
- **Yoga Pose Names**: https://www.yogajournal.com/poses/
- **Pose Benefits**: Consult yoga anatomy books or certified instructors
- **Safety Information**: Always verify precautions with medical sources

---

**This example demonstrates the complete data structure for a single yoga pose. Use it as a template when adding new poses to the collection.**
