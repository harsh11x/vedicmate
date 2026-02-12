-- Orders Table for Supabase
-- Run this SQL in your Supabase SQL Editor to create the orders table

CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id TEXT NOT NULL,
  order_id TEXT UNIQUE NOT NULL,
  items JSONB NOT NULL,
  subtotal DECIMAL(10,2) NOT NULL,
  tax DECIMAL(10,2) DEFAULT 0,
  delivery_charge DECIMAL(10,2) DEFAULT 0,
  total_amount DECIMAL(10,2) NOT NULL,
  payment_id TEXT,
  payment_status TEXT DEFAULT 'pending',
  delivery_status TEXT DEFAULT 'processing',
  shipping_address JSONB NOT NULL,
  expected_delivery_date TIMESTAMP,
  actual_delivery_date TIMESTAMP,
  tracking_number TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_order_id ON orders(order_id);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_orders_payment_status ON orders(payment_status);
CREATE INDEX IF NOT EXISTS idx_orders_delivery_status ON orders(delivery_status);

-- Enable Row Level Security (RLS)
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- Create policy: Users can only view their own orders
CREATE POLICY "Users can view own orders"
  ON orders
  FOR SELECT
  USING (auth.uid()::text = user_id);

-- Create policy: Users can insert their own orders
CREATE POLICY "Users can create own orders"
  ON orders
  FOR INSERT
  WITH CHECK (auth.uid()::text = user_id);

-- Create policy: Users can update their own orders (for cancellation)
CREATE POLICY "Users can update own orders"
  ON orders
  FOR UPDATE
  USING (auth.uid()::text = user_id);

-- Example JSONB structure for items:
-- [
--   {
--     "id": "remedy_1",
--     "title": "Rudraksha Mala",
--     "image": "https://example.com/image.jpg",
--     "price": 999.00,
--     "quantity": 1
--   }
-- ]

-- Example JSONB structure for shipping_address:
-- {
--   "name": "John Doe",
--   "email": "john@example.com",
--   "phone": "+919876543210",
--   "addressLine1": "123 Main Street, Apt 4B",
--   "city": "Mumbai",
--   "state": "Maharashtra",
--   "zip": "400001"
-- }

COMMENT ON TABLE orders IS 'Stores product purchase orders from the Vedic Mate app';
COMMENT ON COLUMN orders.user_id IS 'Firebase UID of the user who placed the order';
COMMENT ON COLUMN orders.order_id IS 'Human-readable order ID (e.g., VED-2024-1234)';
COMMENT ON COLUMN orders.items IS 'Array of order items in JSONB format';
COMMENT ON COLUMN orders.payment_status IS 'Payment status: pending, completed, failed, refunded';
COMMENT ON COLUMN orders.delivery_status IS 'Delivery status: processing, confirmed, shipped, outForDelivery, delivered, cancelled';
