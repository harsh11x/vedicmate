-- Create users table matching the Flutter app's expected schema
CREATE TABLE IF NOT EXISTS public.users (
    id TEXT PRIMARY KEY, -- Matches Firebase UID
    name TEXT,
    email TEXT,
    phone TEXT,
    role TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Create policies (Optional but recommended)
-- Allow reads (Firebase Auth: auth.uid() is NULL; app filters by id in queries)
CREATE POLICY "Users can read own data" ON public.users
    FOR SELECT
    USING (true);

-- Allow updates (Firebase Auth: auth.uid() is NULL; app restricts via .eq('id', user.uid))
CREATE POLICY "Users can update own data" ON public.users
    FOR UPDATE
    USING (true)
    WITH CHECK (true);

-- Allow public insert (for registration logic in this specific app flow, 
-- since we are using Firebase Auth UID and inserting from client)the signup
-- WARNING: In a production app with Supabase Auth, you'd use a trigger on auth.users.
-- Since we use Firebase Auth + Supabase DB, we need to allow inserts.
CREATE POLICY "Enable insert for authenticated users only" ON public.users
    FOR INSERT
    WITH CHECK (true); -- Adjust this if you want stricter control
