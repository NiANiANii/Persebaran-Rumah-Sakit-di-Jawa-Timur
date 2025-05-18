import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/region_data.dart';

class RegionDataService {
  Future<List<RegionData>> loadRegionData() async {
    // Memuat file JSON dengan data perbandingan (rasio penduduk per RS)
    final String response = await rootBundle.loadString('assets/data_perbandingan.json');
    final data = await json.decode(response);
    
    if (data is List) {
      return data.map((item) => RegionData.fromJson(item)).toList();
    } else if (data['data'] is List) {
      return (data['data'] as List).map((item) => RegionData.fromJson(item)).toList();
    }
    
    return [];
  }
  
  Future<String> loadGeoJson() async {
    // Memuat file GeoJSON untuk peta Jawa Timur
    return await rootBundle.loadString('assets/jawa-timur.geojson');
  }

  // Method tambahan untuk mendapatkan data region berdasarkan nama kabupaten/kota
  Future<RegionData?> getRegionByName(String name) async {
    final regions = await loadRegionData();
    try {
      return regions.firstWhere(
        (region) => region.regionName.toLowerCase() == name.toLowerCase() ||
                   region.regionName.toLowerCase().contains(name.toLowerCase()),
      );
    } catch (e) {
      return null;
    }
  }
  
  // Method untuk mendapatkan region dengan rasio tertinggi
  Future<RegionData?> getHighestRatioRegion() async {
    final regions = await loadRegionData();
    if (regions.isEmpty) return null;
    
    // Filter region yang memiliki rasio > 0 (menghindari data Batu yang rasionya 0)
    final validRegions = regions.where((region) => region.ratio > 0).toList();
    if (validRegions.isEmpty) return null;
    
    return validRegions.reduce((curr, next) => curr.ratio > next.ratio ? curr : next);
  }

  // Method untuk mendapatkan region dengan rasio terendah
  Future<RegionData?> getLowestRatioRegion() async {
    final regions = await loadRegionData();
    if (regions.isEmpty) return null;
    
    // Filter region yang memiliki rasio > 0 (menghindari data Batu yang rasionya 0)
    final validRegions = regions.where((region) => region.ratio > 0).toList();
    if (validRegions.isEmpty) return null;
    
    return validRegions.reduce((curr, next) => curr.ratio < next.ratio ? curr : next);
  }
}