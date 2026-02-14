-- FIX: Enable RLS Policies for Wallet and Transactions (Firebase Auth Support)
-- Since Firebase Auth users appear as "anon" to Supabase (unless custom claims are set),
-- we need to allow access to wallets and transactions for the application to function.
-- CAUTION: This allows any client with the anon key to read/write these tables.
-- In a production environment with strict security, you should implement custom JWT handling.

-- 1. Policies for Wallets
DROP POLICY IF EXISTS "Enable read wallets for all" ON public.wallets;
CREATE POLICY "Enable read wallets for all" ON public.wallets FOR SELECT USING (true);

DROP POLICY IF EXISTS "Enable update wallets for all" ON public.wallets;
CREATE POLICY "Enable update wallets for all" ON public.wallets FOR UPDATE USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Enable insert wallets for all" ON public.wallets;
CREATE POLICY "Enable insert wallets for all" ON public.wallets FOR INSERT WITH CHECK (true);

-- 2. Policies for Transactions
DROP POLICY IF EXISTS "Enable read transactions for all" ON public.transactions;
CREATE POLICY "Enable read transactions for all" ON public.transactions FOR SELECT USING (true);

DROP POLICY IF EXISTS "Enable insert transactions for all" ON public.transactions;
CREATE POLICY "Enable insert transactions for all" ON public.transactions FOR INSERT WITH CHECK (true);

-- 3. Ensure RLS is enabled (just in case)
ALTER TABLE public.wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;
