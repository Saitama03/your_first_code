import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception('Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env');
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  runApp(const ProviderScope(child: NassroApp()));
}

class NassroApp extends ConsumerWidget {
  const NassroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const VisitorHomeScreen(),
          routes: [
            GoRoute(
              path: 'login',
              builder: (context, state) => const AuthScreen(),
            ),
            GoRoute(
              path: 'admin',
              builder: (context, state) => const AdminDashboardScreen(),
            ),
          ],
        ),
      ],
      redirect: (context, state) {
        // Placeholder for role-based redirects later
        return null;
      },
    );

    return MaterialApp.router(
      title: 'Nassro Barbershop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F172A)),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}

class VisitorHomeScreen extends StatelessWidget {
  const VisitorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nassro Barbershop')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Welcome to Nassro Barbershop',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context.go('/login'),
            child: const Text('Sign in to book'),
          ),
          const SizedBox(height: 24),
          const Placeholder(fallbackHeight: 160),
          const SizedBox(height: 12),
          const Placeholder(fallbackHeight: 160),
          const SizedBox(height: 12),
          const Placeholder(fallbackHeight: 160),
        ],
      ),
    );
  }
}

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  String? errorText;

  Future<void> _signIn() async {
    setState(() => isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      if (mounted) context.go('/');
    } on AuthException catch (e) {
      setState(() => errorText = e.message);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _signUp() async {
    setState(() => isLoading = true);
    try {
      await Supabase.instance.client.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      if (mounted) context.go('/');
    } on AuthException catch (e) {
      setState(() => errorText = e.message);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (errorText != null)
              Text(errorText!, style: const TextStyle(color: Colors.red)),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: isLoading ? null : _signIn,
                    child: const Text('Sign in'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : _signUp,
                    child: const Text('Create account'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: const Center(child: Text('Admin tools here')),
    );
  }
}
