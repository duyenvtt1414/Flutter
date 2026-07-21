import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/json_report_service.dart';
import 'manager_screen.dart';
import 'staff_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.user, required this.role});

  final User user;
  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final databaseService = DatabaseService.instance;
    final reportService = JsonReportService();
    final isManager = role == UserRole.manager;

    return Scaffold(
      appBar: AppBar(
        title: Text(isManager ? 'Manager Claims' : 'My Expense Claims'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: AuthService().signOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: isManager
          ? ManagerScreen(
              user: user,
              databaseService: databaseService,
              reportService: reportService,
            )
          : StaffScreen(user: user, databaseService: databaseService),
    );
  }
}
