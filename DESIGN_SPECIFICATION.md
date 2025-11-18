# Minimalist Welcome Screen Design Specification

## Color Tokens

### Background Colors
- **Dark Charcoal Background**: `#2B2B2F`
- **White Card Background**: `#FFFFFF`

### Graphic Elements
- **Disk Center (Light Gray)**: `#E0E0E0`
- **Disk Edge (Warm Gray)**: `#9E9E9E`
- **Spokes and Rings (Charcoal)**: `#2B2B2F` with 70% opacity
- **Orbits (Antique Gold)**: `#B38859` with 60% opacity
- **Planets (Antique Gold)**: `#B38859`

### Text
- **Primary Text**: `#2B2B2F` (Dark Charcoal)
- **Active Pagination Dot**: `#FFE66B` (Pale Yellow)
- **Inactive Pagination Dots**: `#B8B8B8` (Light Gray)
- **CTA Diamond**: `#000000` (Black)
- **CTA Arrow**: `#FFFFFF` (White)

## Typography

### Font Family
- **Primary Font**: Poppins (with fallback to system geometric sans-serif)

### Font Sizes
- **Body Text**: 24pt (fontWeight: 500)
- **Pagination Dots**: 8pt
- **CTA Arrow Icon**: 24pt

### Line Heights
- **Body Text**: 1.4x font size

## Layout Specifications

### Container
- **Width**: 85% of screen width (max 360pt)
- **Corner Radius**: 48pt
- **Padding**: 40pt all sides
- **Vertical Alignment**: Centered

### Geometric Graphic
- **Size**: 180pt × 180pt
- **Disk Radius**: 63pt (70% of half container width)
- **Inner Ring Radius**: 50.4pt (80% of disk radius)
- **Outer Ring Radius**: 59.85pt (95% of disk radius)

### Spokes
- **Count**: 60 spokes
- **Stroke Width**: 1.5pt
- **Pattern**: 3-pointed star formation using sine wave modulation

### Orbits
- **Primary Orbit**: Horizontal ellipse (width: 144pt, height: 108pt)
- **Secondary Orbit**: Diagonal ellipse (width: 126pt, height: 81pt) rotated 30°
- **Planet Sizes**: 2.5pt to 4pt

### Pagination
- **Dot Size**: 8pt circles
- **Spacing**: 8pt between dots
- **Position**: Bottom-left of card

### CTA (Call to Action)
- **Diamond Size**: 56pt × 56pt
- **Corner Radius**: 8pt
- **Position**: Bottom-right of card
- **Touchable Area**: Minimum 44pt × 44pt
- **Arrow Icon**: 24pt, centered

## Animation Specifications

### Entrance Sequence
1. **Graphic Animation** (0-600ms):
   - Scale: 0.95 → 1.0 (easeOut curve)
   - Fade: 0.0 → 1.0 (easeIn curve, 0-480ms)

2. **Text Animation** (300-800ms):
   - Fade: 0.0 → 1.0 (easeInOut curve)
   - Slide: 30% down → position (easeOut curve)

3. **CTA Animation** (700-1100ms):
   - Scale: 0.9 → 1.05 (elasticOut curve)

### Timing
- **Total Animation Duration**: 1100ms
- **Auto-advance to Login**: 2500ms after CTA animation

## Export Assets

### APK
- **File**: `VedicMate-Minimalist-20251116-1710.apk`
- **Location**: Desktop
- **Size**: 54MB

### Vector Assets
For Figma, SVG, and PNG exports, please contact the design team for the complete asset package including:
- Geometric graphic as SVG
- Individual planets as SVG layers
- Arrow icon as SVG
- All color variants at @1x, @2x, and @3x resolutions

## Implementation Notes

### Flutter CustomPainter
The geometric graphic is implemented using Flutter's CustomPainter with mathematical calculations for:
- Radial gradient disk
- Spoke patterns forming triangular shapes
- Elliptical orbits with rotation
- Precisely positioned planets

### Responsive Design
- Container adapts to screen width while maintaining maximum 360pt constraint
- All measurements use scalable units (pt) for cross-device consistency
- Typography scales appropriately on different screen densities

### Accessibility
- High contrast ratio between text and background (WCAG AA compliant)
- Sufficient touch target size for CTA (56pt vs minimum 44pt)
- Clear visual hierarchy and focus states
