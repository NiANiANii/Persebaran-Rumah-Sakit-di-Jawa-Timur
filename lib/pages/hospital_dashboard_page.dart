import 'package:flutter/material.dart';
import '../models/region_data.dart';
import '../services/region_data_service.dart';

class HospitalDashboardPage extends StatefulWidget {
  const HospitalDashboardPage({Key? key}) : super(key: key);

  @override
  State<HospitalDashboardPage> createState() => _HospitalDashboardPageState();
}

class _HospitalDashboardPageState extends State<HospitalDashboardPage> {
  final RegionDataService _regionService = RegionDataService();
  bool _isLoading = true;
  List<RegionData> _regionData = [];
  int _totalPopulation = 0;
  int _totalHospitals = 0;
  double _averageRatio = 0;
  
  // Track the selected tab
  int _selectedTabIndex = 0;
  final List<String> _tabTitles = ['Ikhtisar', 'Rasio', 'Rumah Sakit', 'Tabel'];

  // Define blue color palette
  final Color _lightestBlue = Color(0xFFE3F2FD);
  final Color _lighterBlue = Color(0xFF90CAF9);
  final Color _lightBlue = Color(0xFF42A5F5);
  final Color _mediumBlue = Color(0xFF1E88E5);
  final Color _darkBlue = Color(0xFF0D47A1);
  
  // Background color
  final Color _backgroundColor = Color(0xFFF5F7FA);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final regionData = await _regionService.loadRegionData();
      
      // Calculate totals
      int totalPopulation = 0;
      int totalHospitals = 0;
      double totalRatio = 0;
      int validRegions = 0;
      
      for (var region in regionData) {
        totalPopulation += region.population;
        totalHospitals += region.hospitalCount;
        
        if (region.ratio > 0) {
          totalRatio += region.ratio;
          validRegions++;
        }
      }
      
      // Average ratio
      double averageRatio = validRegions > 0 ? totalRatio / validRegions : 0;
      
      setState(() {
        _regionData = regionData;
        _totalPopulation = totalPopulation;
        _totalHospitals = totalHospitals;
        _averageRatio = averageRatio;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _darkBlue,
        title: const Text(
          "Dashboard Rumah Sakit",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _mediumBlue))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCards(),
                    const SizedBox(height: 16),
                    _buildTabBar(),
                    const SizedBox(height: 16),
                    _getSelectedTabContent(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            "Total Penduduk",
            _formatNumber(_totalPopulation),
            "Seluruh Jawa Timur",
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildInfoCard(
            "Total RS",
            _totalHospitals.toString(),
            "Seluruh Jawa Timur",
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildInfoCard(
            "Rata-rata",
            _formatNumber(_averageRatio.round()),
            "Penduduk per RS",
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, String subtitle) {
    return Container(
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
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: _darkBlue,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _mediumBlue,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: _lightBlue,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: _lightestBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: List.generate(
          _tabTitles.length,
          (index) => Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _selectedTabIndex == index
                      ? _mediumBlue
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _tabTitles[index],
                  style: TextStyle(
                    color: _selectedTabIndex == index
                        ? Colors.white
                        : _darkBlue,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getSelectedTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildRatioTab();
      case 2:
        return _buildHospitalsTab();
      case 3:
        return _buildTableTab();
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          "10 Kabupaten/Kota dengan Rasio Tertinggi",
          "Daerah dengan akses rumah sakit paling terbatas",
          _buildRatioBarChart(limit: 10),
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          "10 Kabupaten/Kota dengan Jumlah RS Terbanyak",
          "Daerah dengan jumlah rumah sakit terbanyak",
          _buildHospitalCountBarChart(limit: 10),
        ),
      ],
    );
  }

  Widget _buildSectionCard(String title, String subtitle, Widget content) {
    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _darkBlue,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: _lightBlue,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildRatioTab() {
    return _buildSectionCard(
      "Rasio Penduduk per Rumah Sakit",
      "Perbandingan rasio penduduk per rumah sakit di setiap kabupaten/kota",
      _buildRatioBarChart(limit: 20),
    );
  }

  Widget _buildHospitalsTab() {
    return _buildSectionCard(
      "Jumlah Rumah Sakit per Kabupaten/Kota",
      "Perbandingan jumlah rumah sakit di setiap kabupaten/kota",
      _buildHospitalCountBarChart(limit: 20),
    );
  }

  Widget _buildRatioBarChart({int? limit}) {
    // Filter out regions with no hospitals
    final filteredData = _regionData.where((region) => region.hospitalCount > 0).toList();
    
    // Sort by ratio in descending order
    filteredData.sort((a, b) => b.ratio.compareTo(a.ratio));
    
    // Limit data if specified
    final limitedData = limit != null ? filteredData.take(limit).toList() : filteredData;
    
    // Get max value for percentage calculation
    final maxRatio = limitedData.isNotEmpty ? limitedData.first.ratio : 0;
    
    return Column(
      children: limitedData.map((region) {
        // Calculate percentage for bar width
        final percentage = maxRatio > 0 ? region.ratio / maxRatio : 0;
        
        // Get color based on ratio value
        final color = _getColorByRatio(region.ratio);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      region.regionName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _darkBlue,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatShortNumber(region.ratio.round()),
                    style: TextStyle(
                      fontSize: 12,
                      color: _mediumBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                height: 24,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _lightestBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FractionallySizedBox(
                  widthFactor: percentage.toDouble(),
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHospitalCountBarChart({int? limit}) {
    // Sort by hospital count in descending order
    final sortedData = List<RegionData>.from(_regionData)
      ..sort((a, b) => b.hospitalCount.compareTo(a.hospitalCount));
    
    // Limit data if specified
    final limitedData = limit != null ? sortedData.take(limit).toList() : sortedData;
    
    // Get max value for percentage calculation
    final maxCount = limitedData.isNotEmpty ? limitedData.first.hospitalCount : 0;
    
    return Column(
      children: limitedData.map((region) {
        // Calculate percentage for bar width
        final percentage = maxCount > 0 ? region.hospitalCount / maxCount : 0;
        
        // Get color based on hospital count
        final color = _getColorByHospitalCount(region.hospitalCount);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      region.regionName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _darkBlue,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    region.hospitalCount.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: _mediumBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Container(
                height: 24,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _lightestBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FractionallySizedBox(
                  widthFactor: percentage.toDouble(),
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTableTab() {
    return _buildSectionCard(
      "Data Lengkap",
      "Tabel data lengkap jumlah penduduk dan rumah sakit di Jawa Timur",
      _buildDataTable(),
    );
  }

  Widget _buildDataTable() {
    // Sort regions by ratio in descending order
    final sortedRegions = List<RegionData>.from(_regionData)
      ..sort((a, b) => b.ratio.compareTo(a.ratio));
    
    return Column(
      children: [
        // Search field
        TextField(
          decoration: InputDecoration(
            hintText: 'Cari kabupaten/kota...',
            hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
            prefixIcon: Icon(Icons.search, size: 18, color: _mediumBlue),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: _lighterBlue),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: _lighterBlue),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: _mediumBlue),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          ),
          style: TextStyle(fontSize: 12),
          onChanged: (value) {
            // Implement search functionality if needed
          },
        ),
        const SizedBox(height: 16),
        
        // Table header
        Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: _lightestBlue,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Text(
                  'Kabupaten/Kota',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _darkBlue,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  'Penduduk',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _darkBlue,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'RS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _darkBlue,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Rasio',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _darkBlue,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        
        // Table body
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            border: Border.all(color: _lightestBlue),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: sortedRegions.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: _lightestBlue,
              indent: 12,
              endIndent: 12,
            ),
            itemBuilder: (context, index) {
              final region = sortedRegions[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Text(
                        region.regionName,
                        style: TextStyle(
                          fontSize: 12,
                          color: _darkBlue,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        _formatNumber(region.population),
                        style: TextStyle(
                          fontSize: 12,
                          color: _mediumBlue,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        region.hospitalCount.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: _mediumBlue,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        region.ratio > 0 ? _formatShortNumber(region.ratio.round()) : '-',
                        style: TextStyle(
                          fontSize: 12,
                          color: _mediumBlue,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Helper method to get color based on ratio value
  Color _getColorByRatio(double value) {
    if (value <= 192800) return _lightestBlue;
    if (value <= 428900) return _lighterBlue;
    if (value <= 678300) return _lightBlue;
    if (value <= 984200) return _mediumBlue;
    return _darkBlue;
  }

  // Helper method to get color based on hospital count
  Color _getColorByHospitalCount(int value) {
    if (value <= 2) return _lighterBlue;
    if (value <= 5) return _lightBlue;
    if (value <= 10) return _mediumBlue;
    return _darkBlue;
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},'
    );
  }

  String _formatShortNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}