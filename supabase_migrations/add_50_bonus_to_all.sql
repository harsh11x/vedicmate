-- Migration: Add ₹50 bonus to all existing accounts
-- Run this in Supabase SQL Editor or via psql

-- This script adds ₹50 to all wallets that haven't received a signup bonus yet
-- It also creates a transaction record for each bonus

DO $$
DECLARE
    wallet_record RECORD;
    existing_bonus RECORD;
    new_balance NUMERIC;
BEGIN
    -- Loop through all wallets
    FOR wallet_record IN 
        SELECT user_id, balance 
        FROM public.wallets
    LOOP
        -- Check if this wallet already has a signup bonus transaction
        SELECT id INTO existing_bonus
        FROM public.transactions
        WHERE wallet_id = wallet_record.user_id
        AND (
            description = 'Signup Bonus' 
            OR description = 'Signup Bonus (Late)'
            OR description = 'Guest Welcome Bonus'
            OR description = 'Admin Bonus Grant'
        )
        LIMIT 1;

        -- If no bonus found, add ₹50
        IF existing_bonus.id IS NULL THEN
            -- Calculate new balance
            new_balance := wallet_record.balance + 50.0;

            -- Update wallet balance
            UPDATE public.wallets
            SET balance = new_balance
            WHERE user_id = wallet_record.user_id;

            -- Create transaction record
            INSERT INTO public.transactions (
                wallet_id,
                amount,
                type,
                category,
                description,
                reference_id,
                status,
                created_at
            ) VALUES (
                wallet_record.user_id,
                50.0,
                'credit',
                'recharge',
                'Admin Bonus Grant',
                'ADMIN_BONUS_' || wallet_record.user_id || '_' || EXTRACT(EPOCH FROM NOW())::TEXT,
                'completed',
                NOW()
            );

            RAISE NOTICE 'Added ₹50 bonus to wallet: %', wallet_record.user_id;
        ELSE
            RAISE NOTICE 'Wallet % already has a bonus, skipping', wallet_record.user_id;
        END IF;
    END LOOP;

    RAISE NOTICE 'Bonus migration completed!';
END $$;

-- Verify the results
SELECT 
    COUNT(*) as total_wallets,
    SUM(CASE WHEN balance >= 50 THEN 1 ELSE 0 END) as wallets_with_balance
FROM public.wallets;

SELECT 
    COUNT(*) as bonus_transactions
FROM public.transactions
WHERE description LIKE '%Bonus%';
