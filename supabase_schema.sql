-- ═══════════════════════════════════════════════════════
-- AlcreoVault — Supabase SQL Schema
-- الصق هذا الكود كاملاً في SQL Editor في Supabase ثم Run
-- ═══════════════════════════════════════════════════════

-- Enable UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ─── PROFILES ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS profiles (
  id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name   TEXT,
  avatar_url  TEXT,
  currency    TEXT DEFAULT 'DZD',
  language    TEXT DEFAULT 'fr',
  theme       TEXT DEFAULT 'dark',
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ─── CATEGORIES ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS categories (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  name_fr     TEXT NOT NULL,
  name_ar     TEXT NOT NULL,
  name_en     TEXT NOT NULL,
  color       TEXT DEFAULT '#6366F1',
  icon        TEXT DEFAULT 'wallet',
  type        TEXT CHECK (type IN ('income','expense')) NOT NULL,
  is_default  BOOLEAN DEFAULT FALSE,
  is_active   BOOLEAN DEFAULT TRUE,
  sort_order  INTEGER DEFAULT 0,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ─── TRANSACTIONS ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS transactions (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id       UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  category_id   UUID REFERENCES categories(id) ON DELETE SET NULL,
  amount        DECIMAL(15,2) NOT NULL CHECK (amount > 0),
  type          TEXT CHECK (type IN ('income','expense')) NOT NULL,
  date          DATE NOT NULL,
  beneficiary   TEXT,
  note          TEXT,
  is_recurring  BOOLEAN DEFAULT FALSE,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  updated_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ─── MONTHLY BALANCES ────────────────────────────────────
CREATE TABLE IF NOT EXISTS monthly_balances (
  id               UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id          UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  month_year       TEXT NOT NULL,
  opening_balance  DECIMAL(15,2) DEFAULT 0,
  closing_balance  DECIMAL(15,2) DEFAULT 0,
  is_locked        BOOLEAN DEFAULT FALSE,
  created_at       TIMESTAMPTZ DEFAULT NOW(),
  updated_at       TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, month_year)
);

-- ─── REMINDERS ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS reminders (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id      UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  title        TEXT NOT NULL,
  description  TEXT,
  remind_at    TIMESTAMPTZ NOT NULL,
  repeat_type  TEXT DEFAULT 'once' CHECK (repeat_type IN ('once','daily','weekly','monthly','yearly')),
  is_active    BOOLEAN DEFAULT TRUE,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- ═══════════════════════════════════════════════════════
-- ROW LEVEL SECURITY
-- ═══════════════════════════════════════════════════════
ALTER TABLE profiles          ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories        ENABLE ROW LEVEL SECURITY;
ALTER TABLE transactions      ENABLE ROW LEVEL SECURITY;
ALTER TABLE monthly_balances  ENABLE ROW LEVEL SECURITY;
ALTER TABLE reminders         ENABLE ROW LEVEL SECURITY;

-- Drop old policies if exist
DROP POLICY IF EXISTS "profiles_own"         ON profiles;
DROP POLICY IF EXISTS "categories_own"       ON categories;
DROP POLICY IF EXISTS "transactions_own"     ON transactions;
DROP POLICY IF EXISTS "monthly_balances_own" ON monthly_balances;
DROP POLICY IF EXISTS "reminders_own"        ON reminders;

-- Create policies
CREATE POLICY "profiles_own"         ON profiles          FOR ALL USING (auth.uid() = id);
CREATE POLICY "categories_own"       ON categories        FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "transactions_own"     ON transactions      FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "monthly_balances_own" ON monthly_balances  FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "reminders_own"        ON reminders         FOR ALL USING (auth.uid() = user_id);

-- ═══════════════════════════════════════════════════════
-- TRIGGERS
-- ═══════════════════════════════════════════════════════

-- 1. Auto-create profile on signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO profiles (id, full_name)
  VALUES (NEW.id, NEW.raw_user_meta_data->>'full_name')
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- 2. Auto-insert 10 default categories for new user
CREATE OR REPLACE FUNCTION insert_default_categories()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO categories (user_id,name_fr,name_ar,name_en,color,icon,type,is_default,sort_order) VALUES
    (NEW.id,'Salaire',       'الراتب',     'Salary',       '#6366F1','briefcase','income', true,1),
    (NEW.id,'Freelance',     'عمل حر',     'Freelance',    '#84CC16','laptop',   'income', true,2),
    (NEW.id,'Loyer',         'الإيجار',    'Rent',         '#F43F5E','home',     'expense',true,3),
    (NEW.id,'Alimentation',  'الغذاء',     'Food',         '#F59E0B','coffee',   'expense',true,4),
    (NEW.id,'Transport',     'النقل',      'Transport',    '#3B82F6','car',      'expense',true,5),
    (NEW.id,'Shopping',      'التسوق',     'Shopping',     '#8B5CF6','bag',      'expense',true,6),
    (NEW.id,'Santé',         'الصحة',      'Health',       '#10B981','heart',    'expense',true,7),
    (NEW.id,'Factures',      'الفواتير',   'Bills',        '#EF4444','zap',      'expense',true,8),
    (NEW.id,'Divertissement','الترفيه',    'Entertainment','#EC4899','star',     'expense',true,9),
    (NEW.id,'Éducation',     'التعليم',    'Education',    '#06B6D4','book',     'expense',true,10);
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_profile_created ON profiles;
CREATE TRIGGER on_profile_created
  AFTER INSERT ON profiles
  FOR EACH ROW EXECUTE FUNCTION insert_default_categories();

-- 3. Auto-update closing_balance when transaction changes
CREATE OR REPLACE FUNCTION update_monthly_balance()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_month  TEXT;
  v_uid    UUID;
  v_income DECIMAL;
  v_exp    DECIMAL;
  v_open   DECIMAL;
BEGIN
  v_month := TO_CHAR(COALESCE(NEW.date, OLD.date), 'YYYY-MM');
  v_uid   := COALESCE(NEW.user_id, OLD.user_id);

  -- Ensure monthly_balances row exists
  INSERT INTO monthly_balances (user_id, month_year, opening_balance)
  VALUES (v_uid, v_month, 0)
  ON CONFLICT (user_id, month_year) DO NOTHING;

  -- Get opening balance
  SELECT opening_balance INTO v_open
  FROM monthly_balances WHERE user_id=v_uid AND month_year=v_month;

  -- Recalculate
  SELECT
    COALESCE(SUM(CASE WHEN type='income'  THEN amount ELSE 0 END),0),
    COALESCE(SUM(CASE WHEN type='expense' THEN amount ELSE 0 END),0)
  INTO v_income, v_exp
  FROM transactions
  WHERE user_id=v_uid AND TO_CHAR(date,'YYYY-MM')=v_month;

  UPDATE monthly_balances
  SET closing_balance = v_open + v_income - v_exp, updated_at = NOW()
  WHERE user_id=v_uid AND month_year=v_month;

  RETURN COALESCE(NEW, OLD);
END;
$$;

DROP TRIGGER IF EXISTS on_transaction_change ON transactions;
CREATE TRIGGER on_transaction_change
  AFTER INSERT OR UPDATE OR DELETE ON transactions
  FOR EACH ROW EXECUTE FUNCTION update_monthly_balance();

-- ═══════════════════════════════════════════════════════
-- INDEXES
-- ═══════════════════════════════════════════════════════
CREATE INDEX IF NOT EXISTS idx_tx_user_date ON transactions(user_id, date DESC);
CREATE INDEX IF NOT EXISTS idx_tx_cat       ON transactions(category_id);
CREATE INDEX IF NOT EXISTS idx_cat_user     ON categories(user_id);
CREATE INDEX IF NOT EXISTS idx_mb_user_month ON monthly_balances(user_id, month_year);
CREATE INDEX IF NOT EXISTS idx_rem_user     ON reminders(user_id, remind_at);
