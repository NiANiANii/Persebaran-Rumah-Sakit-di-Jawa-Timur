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
      appBar: AppBar(
        title: const Text("Hospital Locations"),
        actions: [
          PopupMenuButton(
            onSelected: onSelectedMapType,
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: MapType.normal,
                  child: Text("Normal"),
                ),
                const PopupMenuItem(
                  value: MapType.hybrid,
                  child: Text("Hybrid"),
                ),
                const PopupMenuItem(
                  value: MapType.terrain,
                  child: Text("Terrain"),
                ),
                const PopupMenuItem(
                  value: MapType.satellite,
                  child: Text("Satellite"),
                ),
              ];
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search for hospitals...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _filterHospitals('');
              },
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
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
      child: SizedBox(
        height: 150,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _filteredHospitals.length,
          itemBuilder: (context, index) {
            final hospital = _filteredHospitals[index];
            return Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 10 : 0,
                right: 10,
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
        width: MediaQuery.of(context).size.width - 30,
        height: 90,
        margin: const EdgeInsets.only(bottom: 30),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          elevation: 10,
          child: Row(
            children: [
              Container(
                width: 90,
                height: 90,
                margin: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.red.shade100,
                ),
                child: const Icon(
                  Icons.local_hospital,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        address,
                        style: const TextStyle(color: Colors.black, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Row(
                        children: [
                          Text(
                            "Type: $type",
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "Class: $hospitalClass",
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 14,
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