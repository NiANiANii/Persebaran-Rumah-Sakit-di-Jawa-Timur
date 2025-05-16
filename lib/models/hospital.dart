class Hospital {
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final String type;
  final String hospitalClass;
  final String district;
  final String province;
  final String hospitalType;

  Hospital({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.type,
    required this.hospitalClass,
    required this.district,
    required this.province,
    required this.hospitalType,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      name: json['Name'] ?? '',
      latitude: json['Lat'] is double ? json['Lat'] : double.parse(json['Lat'].toString()),
      longitude: json['Long'] is double ? json['Long'] : double.parse(json['Long'].toString()),
      address: json['Address'] ?? '',
      type: json['Type'] ?? '',
      hospitalClass: json['Class'] != null ? json['Class'].toString() : '',
      district: json['District'] ?? '',
      province: json['Province'] ?? '',
      hospitalType: json['Hospital'] ?? '',
    );
  }
}