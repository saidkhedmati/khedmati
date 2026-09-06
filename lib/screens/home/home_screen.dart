import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../requests/requests_screen.dart';
import '../publish/publish_service_screen.dart';
import 'account_menu_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _pages = const [
    AccountMenuScreen(),
    RequestsScreen(),
    PublishServiceScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textSecondary,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'حسابي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'الطلبات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, color: AppColors.primaryBlue, size: 30),
            label: 'نشر خدمة',
          ),
        ],
      ),
    );
  }
}
