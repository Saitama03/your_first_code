import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  static const phoneNumber = '+1234567890';
  static const email = 'contact@nassro.barber';
  static const mapsQuery = 'Nassro Barbershop';

  Future<void> _call() async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _email() async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _maps() async {
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(mapsQuery)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Us')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Phone'),
              subtitle: const Text(phoneNumber),
              onTap: _call,
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: const Text(email),
              onTap: _email,
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Location'),
              subtitle: const Text(mapsQuery),
              onTap: _maps,
            ),
          ],
        ),
      ),
    );
  }
}
