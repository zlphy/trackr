import 'package:json_annotation/json_annotation.dart';

part 'llm_response_model.g.dart';

@JsonSerializable()
class LLMResponseModel {
  final String category;
  final String? reasoning;
  final double? confidence;

  const LLMResponseModel({
    required this.category,
    this.reasoning,
    this.confidence,
  });

  factory LLMResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LLMResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$LLMResponseModelToJson(this);
}

@JsonSerializable()
class GeminiRequestModel {
  final List<GeminiContent> contents;

  const GeminiRequestModel({required this.contents});

  factory GeminiRequestModel.fromJson(Map<String, dynamic> json) =>
      _$GeminiRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiRequestModelToJson(this);
}

@JsonSerializable()
class GeminiContent {
  final List<GeminiPart> parts;

  const GeminiContent({required this.parts});

  factory GeminiContent.fromJson(Map<String, dynamic> json) =>
      _$GeminiContentFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiContentToJson(this);
}

@JsonSerializable()
class GeminiPart {
  final String text;

  const GeminiPart({required this.text});

  factory GeminiPart.fromJson(Map<String, dynamic> json) =>
      _$GeminiPartFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiPartToJson(this);
}

@JsonSerializable()
class GeminiResponseModel {
  final List<GeminiCandidate>? candidates;

  const GeminiResponseModel({this.candidates});

  factory GeminiResponseModel.fromJson(Map<String, dynamic> json) =>
      _$GeminiResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiResponseModelToJson(this);

  String? get text {
    return candidates?.firstOrNull?.content?.parts.firstOrNull?.text;
  }
}

@JsonSerializable()
class GeminiCandidate {
  final GeminiContent? content;

  const GeminiCandidate({this.content});

  factory GeminiCandidate.fromJson(Map<String, dynamic> json) =>
      _$GeminiCandidateFromJson(json);

  Map<String, dynamic> toJson() => _$GeminiCandidateToJson(this);
}
