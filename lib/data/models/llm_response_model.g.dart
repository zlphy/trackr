// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'llm_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LLMResponseModel _$LLMResponseModelFromJson(Map<String, dynamic> json) =>
    LLMResponseModel(
      category: json['category'] as String,
      reasoning: json['reasoning'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$LLMResponseModelToJson(LLMResponseModel instance) =>
    <String, dynamic>{
      'category': instance.category,
      'reasoning': instance.reasoning,
      'confidence': instance.confidence,
    };

GeminiRequestModel _$GeminiRequestModelFromJson(Map<String, dynamic> json) =>
    GeminiRequestModel(
      contents: (json['contents'] as List<dynamic>)
          .map((e) => GeminiContent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GeminiRequestModelToJson(GeminiRequestModel instance) =>
    <String, dynamic>{
      'contents': instance.contents,
    };

GeminiContent _$GeminiContentFromJson(Map<String, dynamic> json) =>
    GeminiContent(
      parts: (json['parts'] as List<dynamic>)
          .map((e) => GeminiPart.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GeminiContentToJson(GeminiContent instance) =>
    <String, dynamic>{
      'parts': instance.parts,
    };

GeminiPart _$GeminiPartFromJson(Map<String, dynamic> json) => GeminiPart(
      text: json['text'] as String,
    );

Map<String, dynamic> _$GeminiPartToJson(GeminiPart instance) =>
    <String, dynamic>{
      'text': instance.text,
    };

GeminiResponseModel _$GeminiResponseModelFromJson(Map<String, dynamic> json) =>
    GeminiResponseModel(
      candidates: (json['candidates'] as List<dynamic>?)
          ?.map((e) => GeminiCandidate.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GeminiResponseModelToJson(
        GeminiResponseModel instance) =>
    <String, dynamic>{
      'candidates': instance.candidates,
    };

GeminiCandidate _$GeminiCandidateFromJson(Map<String, dynamic> json) =>
    GeminiCandidate(
      content: json['content'] == null
          ? null
          : GeminiContent.fromJson(json['content'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GeminiCandidateToJson(GeminiCandidate instance) =>
    <String, dynamic>{
      'content': instance.content,
    };
