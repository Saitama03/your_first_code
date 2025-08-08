insert into public.services (name, description, price_cents, duration_minutes) values
  ('Basic Haircut', 'Classic haircut and styling', 1500, 30),
  ('Beard Trim', 'Beard shaping and trim', 1000, 20),
  ('Haircut + Beard', 'Combo haircut and beard', 2300, 45),
  ('Kids Cut', 'Children haircut', 1200, 30);

-- Mon-Sun 10:00 - 20:00
insert into public.barbershop_hours (weekday, open_time, close_time) values
  (0, '10:00', '20:00'), (1, '10:00', '20:00'), (2, '10:00', '20:00'),
  (3, '10:00', '20:00'), (4, '10:00', '20:00'), (5, '10:00', '20:00'), (6, '10:00', '20:00');