import 'package:json_annotation/json_annotation.dart';

part 'folder_model.g.dart';

@JsonSerializable()
class FolderModel {
  final String folderId;
  final String title;
  final String? description;
  final String? createTime;
  final int? journeyCount; // 用于列表简略显示

  FolderModel({
    required this.folderId,
    required this.title,
    this.description,
    this.createTime,
    this.journeyCount,
  });
  factory FolderModel.fromJson(Map<String, dynamic> json) =>
      _$FolderModelFromJson(json);
}
