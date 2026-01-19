// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MomentModel _$MomentModelFromJson(Map<String, dynamic> json) => MomentModel(
  momentId: json['momentId'] as String,
  journeyId: json['journeyId'] as String,
  time: json['time'] as String,
  type: json['type'] as String,
  title: json['title'] as String?,
  location: LocationData.fromJson(json['location'] as Map<String, dynamic>),
  context: json['context'] as String?,
  media: json['media'] as String?,
  mediaDescription: json['mediaDescription'] as String?,
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$MomentModelToJson(MomentModel instance) =>
    <String, dynamic>{
      'momentId': instance.momentId,
      'journeyId': instance.journeyId,
      'time': instance.time,
      'type': instance.type,
      'title': instance.title,
      'location': instance.location,
      'context': instance.context,
      'media': instance.media,
      'mediaDescription': instance.mediaDescription,
      'tags': instance.tags,
    };

LocationData _$LocationDataFromJson(Map<String, dynamic> json) => LocationData(
  lat: json['lat'] as String,
  lon: json['lon'] as String,
  name: json['name'] as String?,
);

Map<String, dynamic> _$LocationDataToJson(LocationData instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lon': instance.lon,
      'name': instance.name,
    };
