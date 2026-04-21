import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:garudahub/features/auth/providers/auth_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.surface,
        title: Text(
          'Halo, ${user?.name.split(' ').first ?? 'Garuda'}',
          style: TextStyle(
            color: cs.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: cs.primaryContainer,
              backgroundImage: user?.profilePhoto != null && user!.profilePhoto!.isNotEmpty
                  ? NetworkImage(user.profilePhoto!)
                  : null,
              child: (user?.profilePhoto == null || user!.profilePhoto!.isEmpty)
                  ? Text(
                      user?.name.isNotEmpty == true
                          ? user!.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            )
          ),
        ],
      ),
      body: const SizedBox(),
    );
  }
}