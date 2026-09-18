import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../home/home_page.dart';
import '../history/history_page.dart';
import '../scan/scan_page.dart';
import '../impact/impact_page.dart';
import '../profile/profile_page.dart';
import '../shared/widgets/revuelta_bottom_nav_bar.dart';

/// Main navigation shell holding the 5 primary campus tabs from the student mockup:
/// - [0] Inicio (HomePage)
/// - [1] Historial (HistoryPage)
/// - [2] Escanear (ScanPage)
/// - [3] Impacto (ImpactPage)
/// - [4] Perfil (ProfilePage)
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onScanTap: () => _onTabSelected(2)),
      const HistoryPage(),
      const ScanPage(),
      const ImpactPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: RevueltaBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
