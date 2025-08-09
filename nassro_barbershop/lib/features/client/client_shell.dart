import 'package:flutter/material.dart';
import '../services/services_screen.dart';
import '../appointments/appointments_screen.dart';
import '../chat/chat_screen.dart';
import '../reviews/reviews_screen.dart';
import '../notifications/notifications_screen.dart';
import '../home/contact_screen.dart';

class ClientShell extends StatefulWidget {
  const ClientShell({super.key});

  @override
  State<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<ClientShell> {
  int index = 0;
  final pages = const [
    ServicesScreen(),
    AppointmentsScreen(),
    ChatScreen(),
    ReviewsScreen(),
    NotificationsScreen(),
    ContactScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.cut), label: 'Services'),
          NavigationDestination(icon: Icon(Icons.event), label: 'Bookings'),
          NavigationDestination(icon: Icon(Icons.chat), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.reviews), label: 'Reviews'),
          NavigationDestination(
              icon: Icon(Icons.notifications), label: 'Alerts'),
          NavigationDestination(
              icon: Icon(Icons.contact_phone), label: 'Contact'),
        ],
      ),
    );
  }
}
