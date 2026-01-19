import 'package:json_annotation/json_annotation.dart';

part 'moment_model.g.dart';

@JsonSerializable()
class MomentModel {
  final String momentId;
  final String journeyId;
  final String time;
  final String type; // image, audio, text, location
  final String? title;
  final LocationData location;
  final String? context;
  final String? media;
  final String? mediaDescription;
  final List<String>? tags;

  MomentModel({
    required this.momentId,
    required this.journeyId,
    required this.time,
    required this.type,
    this.title,
    required this.location,
    this.context,
    this.media,
    this.mediaDescription,
    this.tags,
  });

  factory MomentModel.fromJson(Map<String, dynamic> json) =>
      _$MomentModelFromJson(json);
  Map<String, dynamic> toJson() => _$MomentModelToJson(this);
}

@JsonSerializable()
class LocationData {
  final String lat;
  final String lon;
  final String? name;

  LocationData({required this.lat, required this.lon, this.name});

  factory LocationData.fromJson(Map<String, dynamic> json) =>
      _$LocationDataFromJson(json);
  Map<String, dynamic> toJson() => _$LocationDataToJson(this);
}
