import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        bottom: TabBar(
          controller: _controller,
          tabs: const [
            Tab(text: 'Services'),
            Tab(text: 'Appointments'),
            Tab(text: 'Chat'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: const [
          Center(child: Text('Manage Services')),
          Center(child: Text('Manage Appointments')),
          Center(child: Text('Chat with Clients')),
        ],
      ),
    );
  }
}
