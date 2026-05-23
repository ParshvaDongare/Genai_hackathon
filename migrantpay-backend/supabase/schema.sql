create extension if not exists pgcrypto;

create table if not exists public.users (
  id uuid primary key default gen_random_uuid(),
  phone text not null unique,
  name text not null,
  pin text,
  verified boolean not null default false,
  kyc_status text not null default 'pending',
  kyc_doc_type text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.wallets (
  user_id uuid primary key references public.users(id) on delete cascade,
  phone text not null unique,
  balance numeric(12,2) not null default 12500.00,
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.auth_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  phone text not null,
  token text not null unique,
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists idx_auth_sessions_phone_token
  on public.auth_sessions (phone, token);

create table if not exists public.otp_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.users(id) on delete cascade,
  phone text not null,
  otp text not null,
  expires_at timestamptz not null,
  used boolean not null default false,
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists idx_otp_requests_phone_created_at
  on public.otp_requests (phone, created_at desc);

create table if not exists public.transactions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(id) on delete cascade,
  public_id text not null unique,
  type text not null check (type in ('sent', 'received', 'addedMoney', 'withdrawn')),
  amount numeric(12,2) not null,
  fee numeric(12,2) not null default 0,
  status text not null default 'success',
  note text,
  blockchain_hash text,
  counterparty_name text,
  counterparty_phone text,
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists idx_transactions_user_created_at
  on public.transactions (user_id, created_at desc);

create table if not exists public.kyc_records (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references public.users(id) on delete cascade,
  phone text not null,
  document_type text,
  status text not null default 'pending',
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);
