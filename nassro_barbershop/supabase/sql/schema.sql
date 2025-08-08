-- Roles are handled via auth.users + RLS. We use a public profile table with role enum.

create type user_role as enum ('client', 'admin');

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  avatar_url text,
  role user_role not null default 'client',
  created_at timestamp with time zone default now()
);

alter table public.profiles enable row level security;

create policy "profiles are viewable by everyone" on public.profiles
  for select using (true);

create policy "users can insert their profile" on public.profiles
  for insert with check (auth.uid() = id);

create policy "users can update their own profile" on public.profiles
  for update using (auth.uid() = id);

-- Services
create table if not exists public.services (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  price_cents int not null,
  duration_minutes int not null default 30,
  is_active boolean not null default true,
  created_at timestamp with time zone default now()
);

alter table public.services enable row level security;
create policy "services readable by all" on public.services for select using (true);
create policy "services manageable by admin" on public.services for all using (
  exists(select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin')
);

-- Barbershop schedule (opening hours, optional)
create table if not exists public.barbershop_hours (
  id serial primary key,
  weekday smallint not null check (weekday between 0 and 6),
  open_time time not null,
  close_time time not null
);

alter table public.barbershop_hours enable row level security;
create policy "hours readable by all" on public.barbershop_hours for select using (true);
create policy "hours manageable by admin" on public.barbershop_hours for all using (
  exists(select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin')
);

-- Appointments
create type appointment_status as enum ('pending', 'approved', 'rejected', 'completed', 'cancelled');

create table if not exists public.appointments (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references public.profiles(id) on delete cascade,
  service_id uuid not null references public.services(id),
  start_at timestamp with time zone not null,
  end_at timestamp with time zone not null,
  status appointment_status not null default 'pending',
  notes text,
  created_at timestamp with time zone default now()
);

create index if not exists idx_appointments_client on public.appointments(client_id);
create index if not exists idx_appointments_time on public.appointments(start_at, end_at);

alter table public.appointments enable row level security;
create policy "appointments readable by owner or admin" on public.appointments for select using (
  client_id = auth.uid() or exists(select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin')
);
create policy "clients can insert their own appointments" on public.appointments for insert with check (
  client_id = auth.uid()
);
create policy "clients can update pending/cancel their own" on public.appointments for update using (
  client_id = auth.uid()
);
create policy "admin can manage all appointments" on public.appointments for all using (
  exists(select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin')
);

-- Reviews (only after completed appointment)
create table if not exists public.reviews (
  id uuid primary key default gen_random_uuid(),
  appointment_id uuid not null references public.appointments(id) on delete cascade,
  client_id uuid not null references public.profiles(id) on delete cascade,
  rating int not null check (rating between 1 and 5),
  comment text,
  created_at timestamp with time zone default now()
);

create index if not exists idx_reviews_client on public.reviews(client_id);

alter table public.reviews enable row level security;
create policy "reviews readable by all" on public.reviews for select using (true);
create policy "clients can insert review after completed" on public.reviews for insert with check (
  client_id = auth.uid() and exists (
    select 1 from public.appointments a
    where a.id = appointment_id and a.client_id = auth.uid() and a.status = 'completed'
  )
);

-- Chat messages
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  sender_id uuid not null references public.profiles(id) on delete cascade,
  recipient_id uuid not null references public.profiles(id) on delete cascade,
  content text not null,
  created_at timestamp with time zone default now(),
  read_at timestamp with time zone
);

create index if not exists idx_messages_pair on public.messages(sender_id, recipient_id, created_at);

alter table public.messages enable row level security;
create policy "messages visible to participants" on public.messages for select using (
  auth.uid() = sender_id or auth.uid() = recipient_id
);
create policy "user can send messages" on public.messages for insert with check (
  auth.uid() = sender_id
);

-- Notifications (stored for in-app center)
create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null,
  body text not null,
  data jsonb,
  created_at timestamp with time zone default now(),
  read boolean not null default false
);

create index if not exists idx_notifications_user on public.notifications(user_id, created_at);

alter table public.notifications enable row level security;
create policy "notifications visible to owner" on public.notifications for select using (user_id = auth.uid());
create policy "notifications insert by server or admin" on public.notifications for insert with check (
  auth.uid() = user_id or exists(select 1 from public.profiles p where p.id = auth.uid() and p.role = 'admin')
);

-- Storage buckets are managed in the dashboard: gallery, client_cuts, avatars