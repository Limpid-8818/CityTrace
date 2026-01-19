import 'package:json_annotation/json_annotation.dart';

part 'journey_model.g.dart';

@JsonSerializable()
class JourneyModel {
  final String journeyId;
  final String title;
  final String? description;
  final String cover;
  final String status; // ongoing, ended
  final String startTime;
  final String? endTime;
  final String? folderId;
  final List<String>? moments; // 瞬间 ID 列表

  JourneyModel({
    required this.journeyId,
    required this.title,
    this.description,
    required this.cover,
    required this.status,
    required this.startTime,
    this.endTime,
    this.folderId,
    this.moments,
  });

  factory JourneyModel.fromJson(Map<String, dynamic> json) =>
      _$JourneyModelFromJson(json);
  Map<String, dynamic> toJson() => _$JourneyModelToJson(this);
}
