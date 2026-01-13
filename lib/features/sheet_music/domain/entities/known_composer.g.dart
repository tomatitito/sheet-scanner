// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'known_composer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$KnownComposerImpl _$$KnownComposerImplFromJson(Map<String, dynamic> json) =>
    _$KnownComposerImpl(
      name: json['name'] as String,
      completeName: json['completeName'] as String,
      epoch: json['epoch'] as String,
      birth: json['birth'] as String?,
      death: json['death'] as String?,
      isPopular: json['isPopular'] as bool? ?? false,
      isRecommended: json['isRecommended'] as bool? ?? false,
    );

Map<String, dynamic> _$$KnownComposerImplToJson(_$KnownComposerImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'completeName': instance.completeName,
      'epoch': instance.epoch,
      'birth': instance.birth,
      'death': instance.death,
      'isPopular': instance.isPopular,
      'isRecommended': instance.isRecommended,
    };
