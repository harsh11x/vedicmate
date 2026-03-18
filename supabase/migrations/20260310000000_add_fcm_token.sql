-- Add FCM token column to users for push notifications
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS fcm_token TEXT;
