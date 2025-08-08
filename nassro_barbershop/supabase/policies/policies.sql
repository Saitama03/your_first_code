-- Helper function to check admin
create or replace function public.is_admin(uid uuid)
returns boolean language sql stable as $$
  select exists(select 1 from public.profiles p where p.id = uid and p.role = 'admin');
$$;

-- Ensure policies reference this function where appropriate
-- Example: services manageable by admin (already in schema)