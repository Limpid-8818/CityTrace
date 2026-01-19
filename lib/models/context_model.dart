import 'package:json_annotation/json_annotation.dart';

part 'context_model.g.dart';

@JsonSerializable()
class GeoLocationInfo {
  final String country;
  final String province;
  final String city;
  final String district;
  final String? name; // POI名称
  final String? address;

  GeoLocationInfo({
    required this.country,
    required this.province,
    required this.city,
    required this.district,
    this.name,
    this.address,
  });
  factory GeoLocationInfo.fromJson(Map<String, dynamic> json) =>
      _$GeoLocationInfoFromJson(json);
}

@JsonSerializable()
class WeatherInfo {
  final double temp;
  final String condition;
  final String? icon;

  WeatherInfo({required this.temp, required this.condition, this.icon});
  factory WeatherInfo.fromJson(Map<String, dynamic> json) =>
      _$WeatherInfoFromJson(json);
}
