-- Migration: Allow SELECT and UPDATE on users table when using Firebase Auth
-- With Firebase Auth, Supabase auth.uid() is NULL, so policies using auth.uid()::text = id block operations.
-- Run this in Supabase SQL Editor if Edit Profile doesn't load/save email and phone.

-- Fix SELECT (supabase_schema uses "Users can read own data")
DROP POLICY IF EXISTS "Users can read own data" ON public.users;
CREATE POLICY "Users can read own data" ON public.users FOR SELECT USING (true);

-- Fix UPDATE
DROP POLICY IF EXISTS "Users can update own data" ON public.users;
DROP POLICY IF EXISTS "Users can edit own profile" ON public.users;
CREATE POLICY "Allow users table update for Firebase Auth" ON public.users
    FOR UPDATE USING (true) WITH CHECK (true);
