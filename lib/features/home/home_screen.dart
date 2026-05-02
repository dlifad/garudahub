import 'package:flutter/material.dart';
import 'package:garudahub/features/dashboard/screens/dashboard_screen.dart';
import 'package:garudahub/features/match/screens/match_screen.dart';
import 'package:garudahub/features/player/screens/player_list_screen.dart';
import 'package:garudahub/features/profile/screens/profile_screen.dart';
import 'package:garudahub/features/shop/shop_screen.dart';
import 'package:garudahub/shared/widgets/floating_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    DashboardScreen(),
    MatchScreen(),
    PlayerListScreen(),
    ShopScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Extend body ke bawah supaya konten bisa terlihat di belakang floating nav
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: FloatingBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
