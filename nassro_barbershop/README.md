# Nassro Barbershop (Flutter + Supabase)

A full-featured, free barbershop booking app with three roles: Visitor, Client, Admin. Built with Flutter and Supabase.

## Features
- Visitor: view gallery, client cuts, services & prices, contact info (phone, email, Google Maps)
- Client: email/password auth, view/ book appointments, reviews, real-time chat, notifications
- Admin: manage images, services, appointments, respond to chat, notifications

## Tech Stack
- Flutter, Riverpod, GoRouter
- Supabase (Auth, Postgres, Realtime, Storage)
- Google Maps

## Prerequisites
- Flutter SDK 3.22+
- Supabase project (free tier)

## 1) Supabase Setup
1. Create a new Supabase project.
2. In the SQL editor, run the SQL in `supabase/sql/schema.sql`.
3. Enable Storage buckets:
   - `gallery`, `client_cuts`, `avatars` (public)
4. In Authentication > Providers, enable Email (Password) auth.
5. Set JWT secret is handled automatically.
6. Create RLS policies using `supabase/policies/policies.sql`.
7. (Optional) Seed sample data with `supabase/seed/seed.sql`.

## 2) Environment Variables
Create `.env` in project root:

```
SUPABASE_URL=your-url
SUPABASE_ANON_KEY=your-anon-key
GOOGLE_MAPS_API_KEY=your-maps-key
```

## 3) Flutter Setup
```
flutter pub get
flutter run
```

## 4) App Structure
- `lib/features/*`: modular features (auth, appointments, chat, reviews, admin, etc.)
- `lib/data/*`: models, repositories, providers
- `lib/routing`: routes
- `lib/theme`: theme
- `supabase/*`: SQL, policies, seed

## 5) Customization
- Update branding, images in `assets/images` and `assets/icons`.
- Change texts/colors in `lib/theme` and feature screens.
- Contact info in `lib/features/home/contact_screen.dart`.

## 6) Build/Release
- Android: `flutter build apk`
- iOS: `flutter build ipa` (requires macOS)

## 7) Notes
- Realtime chat uses `messages` table and Supabase Realtime subscriptions.
- Booking availability is computed from `barbershop_hours` + existing `appointments`.
- Reviews enabled only after appointment completion.
