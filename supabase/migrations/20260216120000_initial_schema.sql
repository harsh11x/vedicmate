-- 1. Scriptures & Content
CREATE TYPE scripture_type AS ENUM ('gita', 'upanishad', 'veda', 'purana', 'other');

CREATE TABLE scriptures (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug TEXT UNIQUE NOT NULL,
  title_en TEXT NOT NULL,
  title_sans TEXT NOT NULL,
  type scripture_type NOT NULL,
  description TEXT,
  author TEXT,
  chapter_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE scripture_chapters (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  scripture_id UUID REFERENCES scriptures(id) ON DELETE CASCADE,
  chapter_number INTEGER NOT NULL,
  title_en TEXT NOT NULL,
  title_sans TEXT NOT NULL,
  summary_en TEXT,
  verse_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(scripture_id, chapter_number)
);

CREATE TABLE scripture_verses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chapter_id UUID REFERENCES scripture_chapters(id) ON DELETE CASCADE,
  verse_number INTEGER NOT NULL,
  text_sans TEXT NOT NULL, -- Devanagari
  text_iast TEXT, -- Transliteration
  meaning_en TEXT, -- Word-by-word or short meaning
  translation_en TEXT NOT NULL, -- Full translation
  commentary_en TEXT, -- Detailed commentary
  audio_url TEXT, -- Link to chanting audio
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(chapter_id, verse_number)
);

-- 2. User Progress & Personalization
CREATE TABLE user_scripture_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  scripture_id UUID REFERENCES scriptures(id) ON DELETE CASCADE,
  chapter_id UUID REFERENCES scripture_chapters(id) ON DELETE CASCADE,
  completed_verses INTEGER[] DEFAULT '{}', -- Array of verse numbers completed
  is_completed BOOLEAN DEFAULT FALSE,
  last_read_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, chapter_id)
);

CREATE TABLE user_bookmarks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    verse_id UUID REFERENCES scripture_verses(id) ON DELETE CASCADE,
    note TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Historical Timeline
CREATE TABLE historical_periods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    start_year_bce INTEGER, -- Negative for BCE, Positive for CE
    end_year_bce INTEGER,
    description TEXT
);

CREATE TABLE historical_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    period_id UUID REFERENCES historical_periods(id),
    title TEXT NOT NULL,
    year_bce INTEGER,
    description TEXT,
    image_url TEXT,
    scripture_reference_id UUID REFERENCES scriptures(id)
);

-- 4. Astronomical & User Profile Extensions
-- Note: Assuming 'profiles' or similar table exists for users. If not, create it.
-- This part modifies the existing user profile if it exists, otherwise creates a dedicated one.
-- Checking existing tables first is safer, but for migration we can use IF EXISTS or create a new table.

CREATE TABLE IF NOT EXISTS user_astrology_profiles (
    user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    birth_date DATE,
    birth_time TIME,
    birth_place_name TEXT,
    birth_latitude DECIMAL(9,6),
    birth_longitude DECIMAL(9,6),
    birth_timezone TEXT, -- e.g., 'Asia/Kolkata'
    preferred_ayanamsa TEXT DEFAULT 'lahiri',
    preferred_chart_style TEXT DEFAULT 'north_indian',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Lifestyle & Habits
CREATE TABLE habits (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    category TEXT CHECK (category IN ('brahmacharya', 'svadhyaya', 'dhyana', 'seva', 'tapas', 'other')),
    frequency TEXT DEFAULT 'daily',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    is_archived BOOLEAN DEFAULT FALSE
);

CREATE TABLE habit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    habit_id UUID REFERENCES habits(id) ON DELETE CASCADE,
    completed_at DATE NOT NULL,
    notes TEXT,
    rating INTEGER CHECK (rating >= 1 AND rating <= 10),
    UNIQUE(habit_id, completed_at)
);

-- 6. Journal
CREATE TABLE journal_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    entry_date DATE NOT NULL,
    content_encrypted TEXT NOT NULL, -- Client-side encrypted content
    mood_rating INTEGER, -- 1-10
    energy_rating INTEGER, -- 1-10
    tags TEXT[],
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_user_astrology_profiles_updated_at
BEFORE UPDATE ON user_astrology_profiles
FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_journal_entries_updated_at
BEFORE UPDATE ON journal_entries
FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();
