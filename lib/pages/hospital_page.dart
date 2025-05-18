import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/hospital.dart';
import '../services/hospital_service.dart';

class HospitalMapPage extends StatefulWidget {
  const HospitalMapPage({super.key});

  @override
  State<HospitalMapPage> createState() => _HospitalMapPageState();
}

class _HospitalMapPageState extends State<HospitalMapPage> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  final HospitalService _hospitalService = HospitalService();
  final TextEditingController _searchController = TextEditingController();
  
  // Default center on East Java (Jawa Timur)
  double latitude = -7.5360639;
  double longitude = 112.2384017;
  var mapType = MapType.normal;
  
  bool _isLoading = true;
  List<Hospital> _hospitals = [];
  List<Hospital> _filteredHospitals = [];
  Set<Marker> _markers = {};
  
  // Currently selected hospital for detail view
  Hospital? _selectedHospital;

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
    _loadHospitals();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHospitals() async {
    try {
      final hospitals = await _hospitalService.loadHospitals();
      
      // Filter out hospitals with missing coordinates
      final validHospitals = hospitals.where((hospital) => 
        hospital.latitude != 0 && 
        hospital.longitude != 0 &&
        hospital.name.isNotEmpty
      ).toList();
      
      // Create markers for each hospital
      final markers = validHospitals.map((hospital) {
        return Marker(
          markerId: MarkerId(hospital.name),
          position: LatLng(hospital.latitude, hospital.longitude),
          infoWindow: InfoWindow(
            title: hospital.name,
            snippet: hospital.address,
          ),
          onTap: () {
            setState(() {
              _selectedHospital = hospital;
            });
            _onClickPlaceCard(hospital.latitude, hospital.longitude);
          },
        );
      }).toSet();
      
      setState(() {
        _hospitals = validHospitals;
        _filteredHospitals = validHospitals;
        _markers = markers;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading hospitals: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterHospitals(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredHospitals = _hospitals;
      });
    } else {
      setState(() {
        _filteredHospitals = _hospitals
            .where((hospital) => 
                hospital.name.toLowerCase().contains(query.toLowerCase()) ||
                hospital.address.toLowerCase().contains(query.toLowerCase()) ||
                hospital.district.toLowerCase().contains(query.toLowerCase()) ||
                hospital.province.toLowerCase().contains(query.toLowerCase()))
            .toList();
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
        title: Text(
          "Lokasi Rumah Sakit",
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
        actions: [
          PopupMenuButton(
            onSelected: onSelectedMapType,
            icon: Icon(Icons.layers, color: _mediumBlue),
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  value: MapType.normal,
                  child: Text(
                    "Normal",
                    style: TextStyle(color: _darkBlue, fontSize: 14),
                  ),
                ),
                PopupMenuItem(
                  value: MapType.hybrid,
                  child: Text(
                    "Hybrid",
                    style: TextStyle(color: _darkBlue, fontSize: 14),
                  ),
                ),
                PopupMenuItem(
                  value: MapType.terrain,
                  child: Text(
                    "Terrain",
                    style: TextStyle(color: _darkBlue, fontSize: 14),
                  ),
                ),
                PopupMenuItem(
                  value: MapType.satellite,
                  child: Text(
                    "Satellite",
                    style: TextStyle(color: _darkBlue, fontSize: 14),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _mediumBlue))
          : Stack(
              children: [
                _buildGoogleMaps(),
                _buildSearchBar(),
                _buildDetailCard(),
              ],
            ),
    );
  }

  Widget _buildSearchBar() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Cari rumah sakit...',
            hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
            prefixIcon: Icon(Icons.search, color: _mediumBlue, size: 20),
            suffixIcon: IconButton(
              icon: Icon(Icons.clear, color: _mediumBlue, size: 20),
              onPressed: () {
                _searchController.clear();
                _filterHospitals('');
              },
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: TextStyle(fontSize: 14, color: _darkBlue),
          onChanged: _filterHospitals,
        ),
      ),
    );
  }

  Widget _buildGoogleMaps() {
    return GoogleMap(
      mapType: mapType,
      initialCameraPosition: CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 8,
      ),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      markers: _markers,
    );
  }

  void onSelectedMapType(MapType value) {
    setState(() {
      mapType = value;
    });
  }

  Widget _buildDetailCard() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 150,
        padding: EdgeInsets.only(bottom: 16),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _filteredHospitals.length,
          itemBuilder: (context, index) {
            final hospital = _filteredHospitals[index];
            return Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 16 : 8,
                right: 8,
              ),
              child: _displayHospitalCard(
                hospital.name,
                hospital.address,
                hospital.type,
                hospital.hospitalClass,
                hospital.latitude,
                hospital.longitude,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _displayHospitalCard(
    String name,
    String address,
    String type,
    String hospitalClass,
    double lat,
    double lng,
  ) {
    return GestureDetector(
      onTap: () {
        _onClickPlaceCard(lat, lng);
      },
      child: Container(
        width: MediaQuery.of(context).size.width - 48,
        margin: const EdgeInsets.only(bottom: 8),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.1),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _lightestBlue,
                ),
                child: Icon(
                  Icons.local_hospital,
                  color: _mediumBlue,
                  size: 32,
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _darkBlue,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address,
                        style: TextStyle(color: _mediumBlue, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _lightestBlue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "Tipe: $type",
                              style: TextStyle(
                                color: _mediumBlue,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _lightestBlue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "Kelas: $hospitalClass",
                              style: TextStyle(
                                color: _mediumBlue,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onClickPlaceCard(double lat, double lng) async {
    setState(() {
      latitude = lat;
      longitude = lng;
    });
    GoogleMapController controller = await _controller.future;
    final cameraPosition = CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: 17,
      bearing: 192,
      tilt: 55,
    );
    final cameraUpdate = CameraUpdate.newCameraPosition(cameraPosition);
    controller.animateCamera(cameraUpdate);
  }
}