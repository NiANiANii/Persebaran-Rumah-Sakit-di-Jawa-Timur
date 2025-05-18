class RegionData {
  final String regionName; // Nama kabupaten/kota
  final int population; // Jumlah penduduk
  final int hospitalCount; // Jumlah rumah sakit
  final double ratio; // Rasio penduduk per rumah sakit

  RegionData({
    required this.regionName,
    required this.population,
    required this.hospitalCount,
    required this.ratio,
  });

  factory RegionData.fromJson(Map<String, dynamic> json) {
    return RegionData(
      regionName: json['Kabupaten/Kota'] ?? '',
      population: json['Jumlah Penduduk Laki - Laki dan Perempuan'] ?? 0,
      hospitalCount: json['Jumlah RS'] ?? 0,
      ratio: (json['Rasio Penduduk per RS'] is num)
          ? (json['Rasio Penduduk per RS']).toDouble()
          : double.tryParse(json['Rasio Penduduk per RS'].toString()) ?? 0.0,
    );
  }
}