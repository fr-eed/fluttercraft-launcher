import 'package:json_annotation/json_annotation.dart';

part 'cape.g.dart';

@JsonSerializable()
class Cape {
  final String id;
  final String state;
  final String url;
  final String alias;

  Cape({
    required this.id,
    required this.state,
    required this.url,
    required this.alias,
  });

  factory Cape.fromJson(Map<String, dynamic> json) => _$CapeFromJson(json);

  Map<String, dynamic> toJson() => _$CapeToJson(this);
}
