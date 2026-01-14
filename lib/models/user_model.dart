import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String userId;
  final String account;
  final String username;
  final String? avatar;

  UserModel({
    required this.userId,
    required this.account,
    required this.username,
    this.avatar,
  });

  // 反序列化：JSON -> Object
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  // 序列化：Object -> JSON
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
