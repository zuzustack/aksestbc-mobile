import 'package:akses_tb/views/guest/info_screen.dart';
import 'package:flutter/material.dart';
import 'guest/home_dashboard.dart';
// Import halaman lain nanti saat sudah dibuat
// import 'guest/info_screen.dart';
// import 'admin/management_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Daftar halaman yang akan ditampilkan sesuai tab yang dipilih
  final List<Widget> _pages = [
    const HomeDashboard(), // Index 0: Halaman yang ada di gambar Anda
    const InfoTbcScreen(), // Index 1: Placeholder
    const Center(child: Text('Halaman Management')), // Index 2: Placeholder
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body akan berubah sesuai index yang dipilih
      body: _pages[_selectedIndex],

      // Global Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF007B7A), // Warna hijau tosca AksesTBC
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Layanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Info TBC',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings_outlined),
            activeIcon: Icon(Icons.admin_panel_settings),
            label: 'Management',
          ),
        ],
      ),
    );
  }
}