#!/usr/bin/env python3
"""Create app icon: logo centered on solid white background."""
from PIL import Image
import os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
LOGO_PATH = os.path.join(PROJECT_ROOT, "assets", "images", "logo.png")
OUTPUT_PATH = os.path.join(PROJECT_ROOT, "assets", "images", "app_icon_1024.jpg")

SIZE = 1024
BG_COLOR = (255, 255, 255)
PADDING = 80  # Padding around logo
# Transparent or pure black background → white
BLACK_THRESHOLD = 25


def replace_black_with_white(img: Image.Image) -> Image.Image:
    """Replace transparent or black background pixels with solid white."""
    data = img.getdata()
    new_data = []
    for item in data:
        if len(item) == 4:  # RGBA
            r, g, b, a = item
            # Transparent OR near-black (background) → white
            is_transparent = a < 128
            is_black = r < BLACK_THRESHOLD and g < BLACK_THRESHOLD and b < BLACK_THRESHOLD
            if is_transparent or is_black:
                new_data.append(BG_COLOR + (255,))
            else:
                new_data.append(item)
        else:
            r, g, b = item[:3]
            if r < BLACK_THRESHOLD and g < BLACK_THRESHOLD and b < BLACK_THRESHOLD:
                new_data.append(BG_COLOR)
            else:
                new_data.append(item)
    out = Image.new(img.mode, img.size)
    out.putdata(new_data)
    return out


def main():
    logo = Image.open(LOGO_PATH).convert("RGBA")
    # Replace black/transparent background with white
    logo = replace_black_with_white(logo)
    w, h = logo.size

    # Create solid white background (RGB, no alpha)
    bg = Image.new("RGB", (SIZE, SIZE), BG_COLOR)

    # Scale logo to fit with padding
    max_logo = SIZE - 2 * PADDING
    scale = min(max_logo / w, max_logo / h)
    new_w = int(w * scale)
    new_h = int(h * scale)
    logo_resized = logo.resize((new_w, new_h), Image.Resampling.LANCZOS)

    # Composite onto white, then flatten to RGB (no alpha)
    paste_x = (SIZE - new_w) // 2
    paste_y = (SIZE - new_h) // 2
    if logo_resized.mode == "RGBA":
        bg_rgba = Image.new("RGBA", (SIZE, SIZE), BG_COLOR + (255,))
        bg_rgba.paste(logo_resized, (paste_x, paste_y), logo_resized)
        # Flatten to RGB - no transparency in output
        result = bg_rgba.convert("RGB")
    else:
        bg.paste(logo_resized, (paste_x, paste_y))
        result = bg

    # Save as JPG (no transparency, solid white background)
    result.save(OUTPUT_PATH, "JPEG", quality=95)
    print(f"Created {OUTPUT_PATH}")

if __name__ == "__main__":
    main()
