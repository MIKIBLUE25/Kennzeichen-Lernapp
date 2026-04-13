import 'package:flutter/material.dart';
import '../screens/statistik_seite.dart';
import '../screens/suche_seite.dart';
import '../main.dart'; // für StartSeite

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int index = 2; // 🔥 Start ist Mitte

  final pages = [
    const StatistikSeite(),
    const ComingSoonSeite(),
    const StartSeite(),
    const SucheSeite(),
    const ComingSoonSeite(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        type: BottomNavigationBarType.fixed,
        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Stats",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.extension),
            label: "Extra",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Start",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Suche",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Account",
          ),
        ],
      ),
    );
  }
}