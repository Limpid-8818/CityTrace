// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'context_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeoLocationInfo _$GeoLocationInfoFromJson(Map<String, dynamic> json) =>
    GeoLocationInfo(
      country: json['country'] as String,
      province: json['province'] as String,
      city: json['city'] as String,
      district: json['district'] as String,
      name: json['name'] as String?,
      address: json['address'] as String?,
    );

Map<String, dynamic> _$GeoLocationInfoToJson(GeoLocationInfo instance) =>
    <String, dynamic>{
      'country': instance.country,
      'province': instance.province,
      'city': instance.city,
      'district': instance.district,
      'name': instance.name,
      'address': instance.address,
    };

WeatherInfo _$WeatherInfoFromJson(Map<String, dynamic> json) => WeatherInfo(
  temp: (json['temp'] as num).toDouble(),
  condition: json['condition'] as String,
  icon: json['icon'] as String?,
);

Map<String, dynamic> _$WeatherInfoToJson(WeatherInfo instance) =>
    <String, dynamic>{
      'temp': instance.temp,
      'condition': instance.condition,
      'icon': instance.icon,
    };
