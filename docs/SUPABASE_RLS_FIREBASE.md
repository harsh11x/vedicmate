# Supabase RLS & Schema for Firebase Auth

## Unique Phone Constraint

To enforce no duplicate phone numbers at the database level, add a unique constraint:

```sql
-- Add unique constraint on phone (allows NULL for users without phone)
CREATE UNIQUE INDEX IF NOT EXISTS users_phone_unique ON public.users (phone) WHERE phone IS NOT NULL AND phone != '';
```

---

# Supabase RLS for Firebase Auth

If profile updates (especially phone number) are not being saved, the Supabase Row Level Security (RLS) policy may be blocking updates.

The default policy uses `auth.uid()` which is Supabase Auth. When using **Firebase Auth** instead, `auth.uid()` is null, so the policy blocks updates.

## Fix: Allow updates by Firebase UID

Run this in the Supabase SQL Editor to add a policy that works with Firebase:

```sql
-- Drop the restrictive policy (if it exists)
DROP POLICY IF EXISTS "Users can update own data" ON public.users;

-- Create policy that allows update when the row id matches the JWT claim
-- Option 1: If you've set a custom JWT claim with Firebase UID
-- CREATE POLICY "Users can update own data" ON public.users
--   FOR UPDATE USING (auth.jwt() ->> 'firebase_uid' = id);

-- Option 2: Allow all updates (less secure - use only for development)
-- Or use a service role for server-side updates
CREATE POLICY "Users can update own data" ON public.users
  FOR UPDATE
  USING (true)
  WITH CHECK (true);
```

**Note:** Option 2 disables RLS for updates. For production, implement proper JWT claims or use a Supabase Edge Function to verify Firebase tokens and perform updates.
