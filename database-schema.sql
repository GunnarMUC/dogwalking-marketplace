-- ==========================================
-- DogWalking App - Database Schema
-- ==========================================
-- Copy and paste this entire file into Neon SQL Editor

-- Users table (both owners and walkers)
CREATE TABLE IF NOT EXISTS auth_users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash TEXT,
  name VARCHAR(255),
  phone_number VARCHAR(50),
  address TEXT,
  user_type VARCHAR(20) CHECK (user_type IN ('owner', 'walker')),
  image TEXT,
  "emailVerified" TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Auth accounts table (for credentials storage)
CREATE TABLE IF NOT EXISTS auth_accounts (
  id SERIAL PRIMARY KEY,
  "userId" INTEGER REFERENCES auth_users(id) ON DELETE CASCADE,
  provider VARCHAR(50) NOT NULL,
  type VARCHAR(50),
  "providerAccountId" VARCHAR(255) NOT NULL,
  access_token TEXT,
  expires_at BIGINT,
  refresh_token TEXT,
  id_token TEXT,
  scope TEXT,
  session_state TEXT,
  token_type TEXT,
  password TEXT,
  UNIQUE("providerAccountId", provider)
);

-- Auth sessions table
CREATE TABLE IF NOT EXISTS auth_sessions (
  id SERIAL PRIMARY KEY,
  "userId" INTEGER REFERENCES auth_users(id) ON DELETE CASCADE,
  expires TIMESTAMP NOT NULL,
  "sessionToken" VARCHAR(255) UNIQUE NOT NULL
);

-- Auth verification tokens
CREATE TABLE IF NOT EXISTS auth_verification_token (
  identifier VARCHAR(255) NOT NULL,
  token VARCHAR(255) NOT NULL,
  expires TIMESTAMP NOT NULL,
  PRIMARY KEY (identifier, token)
);

-- Pets table
CREATE TABLE IF NOT EXISTS pets (
  id SERIAL PRIMARY KEY,
  owner_id INTEGER REFERENCES auth_users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  breed VARCHAR(255),
  age INTEGER,
  weight DECIMAL(5,2),
  photo_url TEXT,
  special_instructions TEXT,
  medical_info TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Walker profiles table
CREATE TABLE IF NOT EXISTS walker_profiles (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES auth_users(id) ON DELETE CASCADE UNIQUE,
  bio TEXT,
  experience_years INTEGER,
  hourly_rate DECIMAL(6,2) DEFAULT 25.00,
  service_radius INTEGER DEFAULT 10,
  service_areas TEXT,
  is_available BOOLEAN DEFAULT true,
  certifications TEXT[],
  average_rating DECIMAL(3,2) DEFAULT 0,
  total_walks INTEGER DEFAULT 0,
  latitude DECIMAL(10,8),
  longitude DECIMAL(11,8),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Bookings table
CREATE TABLE IF NOT EXISTS bookings (
  id SERIAL PRIMARY KEY,
  owner_id INTEGER REFERENCES auth_users(id) ON DELETE CASCADE,
  walker_id INTEGER REFERENCES auth_users(id) ON DELETE CASCADE,
  pet_id INTEGER REFERENCES pets(id) ON DELETE CASCADE,
  scheduled_date TIMESTAMP NOT NULL,
  duration_minutes INTEGER DEFAULT 30,
  status VARCHAR(20) CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled')) DEFAULT 'pending',
  price DECIMAL(8,2),
  special_requests TEXT,
  walk_notes TEXT,
  photo_urls TEXT[],
  created_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_pets_owner ON pets(owner_id);
CREATE INDEX IF NOT EXISTS idx_bookings_owner ON bookings(owner_id);
CREATE INDEX IF NOT EXISTS idx_bookings_walker ON bookings(walker_id);
CREATE INDEX IF NOT EXISTS idx_bookings_status ON bookings(status);
CREATE INDEX IF NOT EXISTS idx_bookings_scheduled_date ON bookings(scheduled_date);
CREATE INDEX IF NOT EXISTS idx_walker_profiles_user ON walker_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_walker_profiles_available ON walker_profiles(is_available);
CREATE INDEX IF NOT EXISTS idx_walker_profiles_rate ON walker_profiles(hourly_rate);
CREATE INDEX IF NOT EXISTS idx_auth_sessions_token ON auth_sessions("sessionToken");
CREATE INDEX IF NOT EXISTS idx_auth_accounts_user ON auth_accounts("userId");

-- Insert a test user (optional - for testing)
-- Password for test user will be 'test1234' (hashed)
-- You can uncomment these after running the app once to hash the password

-- INSERT INTO auth_users (email, name, user_type) 
-- VALUES ('test@example.com', 'Test User', 'owner')
-- ON CONFLICT (email) DO NOTHING;

-- Grant necessary permissions (Neon usually handles this automatically)
-- But if needed, you can uncomment:
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO your_neon_user;
-- GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO your_neon_user;

-- Verify tables were created
SELECT 
  table_name,
  (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name) as column_count
FROM information_schema.tables t
WHERE table_schema = 'public'
ORDER BY table_name;

