// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'folder_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FolderModel _$FolderModelFromJson(Map<String, dynamic> json) => FolderModel(
  folderId: json['folderId'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  createTime: json['createTime'] as String?,
  journeyCount: json['journeyCount'] as String?,
);

Map<String, dynamic> _$FolderModelToJson(FolderModel instance) =>
    <String, dynamic>{
      'folderId': instance.folderId,
      'name': instance.name,
      'description': instance.description,
      'createTime': instance.createTime,
      'journeyCount': instance.journeyCount,
    };
