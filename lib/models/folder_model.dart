import 'package:json_annotation/json_annotation.dart';

part 'folder_model.g.dart';

@JsonSerializable()
class FolderModel {
  final String folderId;
  final String name;
  final String? description;
  final String? createTime;
  final String? journeyCount; // 用于列表简略显示

  FolderModel({
    required this.folderId,
    required this.name,
    this.description,
    this.createTime,
    this.journeyCount,
  });
  factory FolderModel.fromJson(Map<String, dynamic> json) =>
      _$FolderModelFromJson(json);
}
