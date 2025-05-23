import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_google_maps/data_dummy.dart';
import 'package:flutter_google_maps/map_type_google.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsV1Page extends StatefulWidget {
  const MapsV1Page({super.key});

  @override
  State<MapsV1Page> createState() => _MapsV1PageState();
}

class _MapsV1PageState extends State<MapsV1Page> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  double latitude = -7.2804494;
  double longitude = 112.7947228;
  var mapType = MapType.normal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Maps V1"),
        actions: [
          PopupMenuButton(
            onSelected: onSelectedMapType,
            itemBuilder: (context) {
              return googleMapTypes.map((typeGoogle) {
                return PopupMenuItem(
                  value: typeGoogle.type,
                  child: Text(typeGoogle.type.name),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildGoogleMaps(),
          _buildDetailCard(), // detail card ditambahkan di bawah Google Map
        ],
      ),
    );
  }

  Widget _buildGoogleMaps() {
    return GoogleMap(
      mapType: mapType,
      initialCameraPosition: CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 14,
      ),
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      markers: markers,
    );
  }

  void onSelectedMapType(Type value) {
    setState(() {
      switch (value) {
        case Type.Normal:
          mapType = MapType.normal;
          break;
        case Type.Hybrid:
          mapType = MapType.hybrid;
          break;
        case Type.Terrain:
          mapType = MapType.terrain;
          break;
        case Type.Satellite:
          mapType = MapType.satellite;
          break;
      }
    });
  }

  Widget _buildDetailCard() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: 150,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            const SizedBox(width: 10),
            _displayPlaceCard(
              "https://www.pens.ac.id/wp-content/uploads/2022/04/Gedung-PENS-hibah-dari-Pemerintah-Indonesia-.jpg",
              "Politeknik Elektronika Negeri Surabaya",
              -7.2758471,
              112.7937557,
            ),
            const SizedBox(width: 10),
            _displayPlaceCard(
              "https://www.its.ac.id/wp-content/uploads/2021/03/Rektorat.jpg",
              "Institut Teknologi Sepuluh Nopember",
              -7.282356,
              112.7949253,
            ),
            const SizedBox(width: 10),
            _displayPlaceCard(
              "https://galaxymall.co.id/wp-content/uploads/2022/11/one_galaxy_tampak_01-600x600.jpg",
              "Galaxy Mall 3",
              -7.2756967,
              112.7806254,
            ),
            const SizedBox(width: 10),
            _displayPlaceCard(
              "https://bpkad.surabaya.go.id/siwagefile/images/arifrahman/convention7.jpg",
              "Convention Hall Arief Rahman Hakim",
              -7.2886493,
              112.7836333,
            ),
            const SizedBox(width: 10),
            _displayPlaceCard(
              "https://www.pakuwonjati.com/upload/2020/11/5fb7ad1b9cedd-press-release-openingpcm.jpg",
              "Pakuwon City Mall",
              -7.2768784,
              112.8061882,
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  Widget _displayPlaceCard(
    String imageUrl,
    String name,
    double lat,
    double lgn,
  ) {
    return GestureDetector(
      onTap: () {
        _onClickPlaceCard(lat, lgn);
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
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
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
                      Row(
                        children: [
                          const Text("4.9", style: TextStyle(fontSize: 15)),
                          const SizedBox(width: 5),
                          Row(children: stars()),
                        ],
                      ),
                      const Text(
                        "Indonesia · Kota Surabaya",
                        style: TextStyle(color: Colors.black, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const Text(
                        "Closed · Open 09.00 Monday",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
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

  List<Widget> stars() {
    List<Widget> list1 = [];
    for (var i = 0; i < 5; i++) {
      list1.add(const Icon(Icons.star, color: Colors.orange, size: 15));
    }
    return list1;
  }

  void _onClickPlaceCard(double lat, double lgn) async {
    setState(() {
      latitude = lat;
      longitude = lgn;
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
