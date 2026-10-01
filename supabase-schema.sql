-- Indiana Notary Services — Supabase schema
-- Run once in Supabase SQL Editor.

create extension if not exists pgcrypto;

create table if not exists public.notary_settings (
  id text primary key default 'main',
  recipient_email text not null default 'IndianaNotaryServices@gmail.com',
  business_email text not null default 'IndianaNotaryServices@gmail.com',
  business_phone text not null default '317-728-7537',
  base_address text not null default 'Fairland, IN 46126',
  max_miles numeric not null default 20,
  mileage_rate numeric not null default 0.76,
  notarial_act_fee numeric not null default 10,
  slot_minutes integer not null default 15,
  weekday_open time not null default '17:00',
  weekday_close time not null default '21:00',
  weekend_open time not null default '07:00',
  weekend_close time not null default '21:00',
  square_payment_url text not null default '',
  venmo_payment_url text not null default '',
  time_zone text not null default 'America/Indiana/Indianapolis',
  confirm_template text not null default 'Hello {{name}},\n\nYour appointment request {{reference}} can be confirmed for {{date}} at {{time}}.\n\nEstimated total: {{amount}}\nPayment link: {{paymentLink}}\n\nPlease use the payment link to complete payment. Your appointment details are attached as a PDF.\n\nIndiana Notary Services',
  alternative_template text not null default 'Hello {{name}},\n\nUnfortunately I am not available at the requested time for {{reference}}. I can offer {{alternative}} instead.\n\nIf that works for you, please reply to confirm. Payment can then be made here: {{paymentLink}}\n\nIndiana Notary Services',
  receipt_template text not null default 'Hello {{name}},\n\nThank you. Your appointment request {{reference}} has been received for {{date}} at {{time}}. This is a request only and is not confirmed until availability has been reviewed.\n\nEstimated total: {{amount}}\n\nIndiana Notary Services',
  updated_at timestamptz not null default now()
);
insert into public.notary_settings(id) values ('main') on conflict (id) do nothing;

create table if not exists public.notary_bookings (
  id uuid primary key default gen_random_uuid(),
  reference text unique not null,
  status text not null default 'requested' check (status in ('requested','awaiting_customer','confirmed_unpaid','confirmed_paid','declined')),
  full_name text not null,
  phone text not null,
  email text not null,
  service_type text not null,
  act_count integer not null default 1,
  service_notes text,
  requested_date date not null,
  requested_time time not null,
  confirmed_date date,
  confirmed_time time,
  proposed_date date,
  proposed_time time,
  address1 text not null,
  city text not null,
  state text not null,
  zip text not null,
  distance_miles numeric,
  charge_miles numeric,
  payment_preference text,
  payment_link text,
  estimated_total numeric not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists idx_notary_bookings_status on public.notary_bookings(status);
create index if not exists idx_notary_bookings_requested on public.notary_bookings(requested_date, requested_time);
create index if not exists idx_notary_bookings_confirmed on public.notary_bookings(confirmed_date, confirmed_time);

create table if not exists public.notary_messages (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid not null references public.notary_bookings(id) on delete cascade,
  direction text not null default 'outbound',
  template_type text,
  subject text,
  body text,
  sent_to text,
  email_sent boolean not null default false,
  created_at timestamptz not null default now()
);
create index if not exists idx_notary_messages_booking on public.notary_messages(booking_id, created_at);

create table if not exists public.notary_busy_events (
  id uuid primary key default gen_random_uuid(),
  date date not null,
  start_time time not null,
  end_time time not null,
  title text not null default 'Unavailable',
  source text not null default 'admin',
  created_at timestamptz not null default now(),
  constraint notary_busy_valid check (end_time > start_time)
);
create index if not exists idx_notary_busy_date on public.notary_busy_events(date, start_time);

-- The browser never talks directly to Supabase; only the Vercel API uses the service-role key.
alter table public.notary_settings enable row level security;
alter table public.notary_bookings enable row level security;
alter table public.notary_messages enable row level security;
alter table public.notary_busy_events enable row level security;

-- Intentionally no anon/authenticated policies. Keep all access server-side.
