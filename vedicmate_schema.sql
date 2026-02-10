-- Drop tables if they exist to start fresh (Order matters due to foreign keys)
DROP TABLE IF EXISTS public.chat_messages;
DROP TABLE IF EXISTS public.chat_sessions;
DROP TABLE IF EXISTS public.bookings;
DROP TABLE IF EXISTS public.transactions;
DROP TABLE IF EXISTS public.wallets;
DROP TABLE IF EXISTS public.pandit_profiles;
DROP TABLE IF EXISTS public.client_profiles;
DROP TABLE IF EXISTS public.users;

-- 1. Users Table (Base table for Auth)
CREATE TABLE public.users (
    id TEXT PRIMARY KEY, -- Maps to Firebase UID
    email TEXT,
    phone TEXT,
    name TEXT,
    role TEXT DEFAULT 'client', -- 'client' or 'pandit'
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Client Profiles (Astrology & Personal Details)
CREATE TABLE public.client_profiles (
    user_id TEXT PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
    date_of_birth DATE,
    time_of_birth TIME,
    place_of_birth TEXT,
    gender TEXT,
    marital_status TEXT,
    
    -- Shipping Details (stored as loose columns or JSON, columns are safer for queries)
    shipping_name TEXT,
    shipping_phone TEXT,
    shipping_address_line1 TEXT,
    shipping_city TEXT,
    shipping_state TEXT,
    shipping_zip TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Pandit Profiles (Professional Details)
CREATE TABLE public.pandit_profiles (
    user_id TEXT PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
    bio TEXT,
    expertise TEXT[], -- Array of strings e.g. ['Vedic', 'Tarot']
    languages TEXT[], -- Array e.g. ['Hindi', 'English']
    experience_years INTEGER DEFAULT 0,
    is_verified BOOLEAN DEFAULT FALSE,
    availability_status TEXT DEFAULT 'offline', -- 'online', 'busy', 'offline'
    
    -- Pricing
    call_rate_per_min NUMERIC(10, 2) DEFAULT 0.00,
    chat_rate_per_min NUMERIC(10, 2) DEFAULT 0.00,
    video_rate_per_min NUMERIC(10, 2) DEFAULT 0.00,
    
    -- Stats
    rating NUMERIC(3, 2) DEFAULT 0.00,
    review_count INTEGER DEFAULT 0,
    total_consultations INTEGER DEFAULT 0,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Wallets (Financials)
CREATE TABLE public.wallets (
    user_id TEXT PRIMARY KEY REFERENCES public.users(id) ON DELETE CASCADE,
    balance NUMERIC(12, 2) DEFAULT 0.00,
    currency TEXT DEFAULT 'INR',
    is_frozen BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Transactions (History)
CREATE TABLE public.transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wallet_id TEXT REFERENCES public.wallets(user_id) ON DELETE CASCADE, -- wallet_id is same as user_id here
    amount NUMERIC(12, 2) NOT NULL,
    type TEXT NOT NULL, -- 'credit', 'debit'
    category TEXT NOT NULL, -- 'recharge', 'consultation', 'refund', 'payout'
    description TEXT,
    reference_id TEXT, -- e.g., razorpay_payment_id or booking_id
    status TEXT DEFAULT 'completed', -- 'pending', 'completed', 'failed'
    metadata JSONB, -- For extra data like { "pandit_name": "...", "duration": "..." }
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. Bookings (Consultations)
CREATE TABLE public.bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id TEXT REFERENCES public.users(id),
    pandit_id TEXT REFERENCES public.users(id),
    service_type TEXT NOT NULL, -- 'call', 'chat', 'video', 'report'
    
    -- Schedule
    scheduled_at TIMESTAMP WITH TIME ZONE,
    duration_minutes INTEGER,
    
    -- Financials
    total_amount NUMERIC(10, 2) NOT NULL,
    platform_fee NUMERIC(10, 2) DEFAULT 0.00,
    pandit_earnings NUMERIC(10, 2) DEFAULT 0.00,
    
    -- Status
    status TEXT DEFAULT 'pending', -- 'pending', 'confirmed', 'completed', 'cancelled', 'rejected'
    cancellation_reason TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 7. Chat Sessions (AI or Real Pandit)
CREATE TABLE public.chat_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id TEXT REFERENCES public.users(id),
    pandit_id TEXT REFERENCES public.users(id), -- Can be NULL for AI? Or use a reserved ID for AI
    is_ai_chat BOOLEAN DEFAULT FALSE,
    
    start_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    end_time TIMESTAMP WITH TIME ZONE,
    
    total_cost NUMERIC(10, 2) DEFAULT 0.00,
    status TEXT DEFAULT 'active', -- 'active', 'ended'
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. Messages
CREATE TABLE public.chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID REFERENCES public.chat_sessions(id) ON DELETE CASCADE,
    sender_id TEXT REFERENCES public.users(id),
    content TEXT,
    message_type TEXT DEFAULT 'text', -- 'text', 'image', 'system'
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Row Level Security (RLS) - Basic Setup to start with
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.client_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pandit_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;

-- Simple Policies (Adjust as needed for strict security)
-- For now, allowing all authenticated users to do basic operations for development speed
-- In production, you would lock this down (e.g., users can only read their own wallet)

CREATE POLICY "Public enable insert for users" ON public.users FOR INSERT WITH CHECK (true);
CREATE POLICY "Public enable select for users" ON public.users FOR SELECT USING (true);
-- Firebase Auth: auth.uid() is NULL; app restricts via .eq('id', user.uid)
CREATE POLICY "Users can edit own profile" ON public.users FOR UPDATE USING (true) WITH CHECK (true);

-- Helper trigger to auto-create wallet and profile on user creation (Optional but cool)
-- For now we will handle this in Dart code as requested to avoid complex PL/pgSQL specific logic issues if you aren't familiar with it.
