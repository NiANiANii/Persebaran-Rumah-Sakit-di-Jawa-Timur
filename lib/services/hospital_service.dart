import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/hospital.dart';

class HospitalService {
  Future<List<Hospital>> loadHospitals() async {
    // Membaca file JSON dari assets - path updated to match actual location
    final String response = await rootBundle.loadString('assets/hospital.json');
    final data = await json.decode(response);
    
    // The hospitals.json file contains a direct list of hospitals
    if (data is List) {
      return data.map((item) => Hospital.fromJson(item)).toList();
    } else if (data['data'] is List) {
      // Jika data ada dalam properti 'data'
      return (data['data'] as List).map((item) => Hospital.fromJson(item)).toList();
    }
    
    return [];
  }
}