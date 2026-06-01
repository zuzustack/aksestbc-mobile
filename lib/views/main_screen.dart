import 'package:akses_tb/views/guest/info_screen.dart';
import 'package:flutter/material.dart';
import 'guest/home_dashboard.dart';
import 'admin/login_screen.dart';
import 'admin/admin_dashboard.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isAdminLoggedIn = false;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Membangun daftar halaman secara dinamis untuk menyalurkan callback dan state login
    final List<Widget> pages = [
      HomeDashboard(
        onProfilePressed: () => _onItemTapped(2),
      ),
      InfoTbcScreen(
        onAdminLoginPressed: () => _onItemTapped(2),
      ),
      _isAdminLoggedIn
          ? AdminDashboardScreen(
              onLogout: () {
                setState(() {
                  _isAdminLoggedIn = false;
                });
              },
            )
          : LoginAdminScreen(
              onLoginSuccess: () {
                setState(() {
                  _isAdminLoggedIn = true;
                });
              },
              // Jika user berada di tab login dan menekan tombol kembali, kembalikan ke tab Home (Dashboard)
              onBack: () => _onItemTapped(0),
            ),
    ];

    return Scaffold(
      // Body akan berubah sesuai index yang dipilih
      body: pages[_selectedIndex],

      // Global Bottom Navigation Bar with premium M3 pill container for selected icons
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.04),
              blurRadius: 8,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF005F5D), // Match deep teal theme
          unselectedItemColor: const Color(0xFF94A3B8), // Cool grey-slate
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, height: 1.5),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11.5, height: 1.5),
          showUnselectedLabels: true,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Icon(Icons.map_outlined, size: 22),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F4F4), // Light green capsule background
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.map, color: Color(0xFF005F5D), size: 22),
              ),
              label: 'Layanan',
            ),
            BottomNavigationBarItem(
              icon: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Icon(Icons.menu_book_outlined, size: 22),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F4F4), // Light green capsule background
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.menu_book, color: Color(0xFF005F5D), size: 22),
              ),
              label: 'Info TBC',
            ),
            BottomNavigationBarItem(
              icon: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Icon(Icons.admin_panel_settings_outlined, size: 22),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F4F4), // Light green capsule background
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.admin_panel_settings, color: Color(0xFF005F5D), size: 22),
              ),
              label: 'Management',
            ),
          ],
        ),
      ),
    );
  }
}