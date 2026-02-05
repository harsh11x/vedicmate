# Reels Storage

This folder contains all reel content:
- **videos/** - Video files (reel_xxx.mp4) uploaded via admin panel
- **reels.json** - Metadata (description, likes, comments, etc.)

**Flow:**
1. Admin uploads reel → video saved to `videos/`, metadata to `reels.json`
2. Admin deletes reel → video file removed, entry removed from `reels.json`
3. Mobile app fetches reels from server → server reads from this folder

**Deployment:** Ensure this entire `reels/` folder is included and persisted (e.g. use a volume in Docker).
