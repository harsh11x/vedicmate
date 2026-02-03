#!/bin/bash
# Resize screenshots to App Store required dimensions
# Usage: ./resize_screenshots.sh <input.png>
# Or: ./resize_screenshots.sh *.png

# Required dimensions:
# 1242 × 2688 px (portrait 6.5")
# 2688 × 1242 px (landscape 6.5")
# 1284 × 2778 px (portrait 6.7")
# 2778 × 1284 px (landscape 6.7")

OUTPUT_DIR="app_store_screenshots"
mkdir -p "$OUTPUT_DIR"

for img in "$@"; do
  [ -f "$img" ] || continue
  base=$(basename "$img" .png)
  base=$(basename "$base" .PNG)
  
  echo "Processing $img..."
  
  # Create all 4 required sizes
  sips -z 2688 1242 "$img" --out "$OUTPUT_DIR/${base}_1242x2688.png" 2>/dev/null
  sips -z 1242 2688 "$img" --out "$OUTPUT_DIR/${base}_2688x1242.png" 2>/dev/null
  sips -z 2778 1284 "$img" --out "$OUTPUT_DIR/${base}_1284x2778.png" 2>/dev/null
  sips -z 1284 2778 "$img" --out "$OUTPUT_DIR/${base}_2778x1284.png" 2>/dev/null
done

echo "Done! Check the $OUTPUT_DIR folder."
