import 'package:flutter/material.dart';
import 'package:flutter_google_maps/pages/hospital_page.dart';
import 'package:flutter_google_maps/pages/hospital_dashboard_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Define blue color palette - use static const for class level constants
  static const Color _lightestBlue = Color(0xFFE3F2FD);
  static const Color _lighterBlue = Color(0xFF90CAF9);
  static const Color _lightBlue = Color(0xFF42A5F5);
  static const Color _mediumBlue = Color(0xFF1E88E5);
  static const Color _darkBlue = Color(0xFF0D47A1);

  // Background color
  static const Color _backgroundColor = Color(0xFFF5F7FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildContent(context),
            ),
          ],
        ),
      ),
    );
  }

  // Rest of your code remains the same

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _lightestBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.map,
              color: _mediumBlue,
              size: 28,
            ),
          ),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hospital Maps',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _darkBlue,
                ),
              ),
              Text(
                'Jawa Timur',
                style: TextStyle(
                  fontSize: 14,
                  color: _mediumBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Menu Utama',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _darkBlue,
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildMenuCard(
                  context,
                  'Dashboard',
                  Icons.dashboard,
                  _lightBlue,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HospitalDashboardPage(),
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  context,
                  'Hospital Maps',
                  Icons.local_hospital,
                  _mediumBlue,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HospitalMapPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _darkBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}