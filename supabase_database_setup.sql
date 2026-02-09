-- 📊 Supabase Database Setup for Analytics Dashboard
-- Run this SQL in your Supabase SQL Editor

-- Create analytics_overview table
CREATE TABLE IF NOT EXISTS analytics_overview (
  id BIGSERIAL PRIMARY KEY,
  active_users TEXT NOT NULL,
  sessions TEXT NOT NULL,
  page_views TEXT NOT NULL,
  engagement_rate TEXT NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create analytics_daily_users table
CREATE TABLE IF NOT EXISTS analytics_daily_users (
  id BIGSERIAL PRIMARY KEY,
  date TEXT NOT NULL,
  users INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create analytics_top_countries table
CREATE TABLE IF NOT EXISTS analytics_top_countries (
  id BIGSERIAL PRIMARY KEY,
  country TEXT NOT NULL,
  users INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert sample data for testing
INSERT INTO analytics_overview (active_users, sessions, page_views, engagement_rate)
VALUES ('1,234', '5,678', '12,345', '67.8%');

INSERT INTO analytics_daily_users (date, users) VALUES
('2024-02-01', 100),
('2024-02-02', 150),
('2024-02-03', 120),
('2024-02-04', 180),
('2024-02-05', 200),
('2024-02-06', 170),
('2024-02-07', 190),
('2024-02-08', 210),
('2024-02-09', 195),
('2024-02-10', 220);

INSERT INTO analytics_top_countries (country, users) VALUES
('USA', 500),
('UK', 300),
('Canada', 200),
('Germany', 150),
('France', 100),
('Japan', 80),
('Australia', 70);

-- Enable Row Level Security (RLS)
ALTER TABLE analytics_overview ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_daily_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_top_countries ENABLE ROW LEVEL SECURITY;

-- Create policies to allow read access
CREATE POLICY "Allow public read access" ON analytics_overview FOR SELECT USING (true);
CREATE POLICY "Allow public read access" ON analytics_daily_users FOR SELECT USING (true);
CREATE POLICY "Allow public read access" ON analytics_top_countries FOR SELECT USING (true);
