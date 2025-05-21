// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'layout_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gradientColorHash() => r'14bb760ee270fb8ba0ac4a49a694b160cc6968ea';

/// 渐变颜色状态提供者
///
/// Copied from [GradientColor].
@ProviderFor(GradientColor)
final gradientColorProvider =
    AutoDisposeNotifierProvider<GradientColor, List<Color>>.internal(
  GradientColor.new,
  name: r'gradientColorProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$gradientColorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GradientColor = AutoDisposeNotifier<List<Color>>;
String _$languageHash() => r'ecfe428f486aa59c5436b40233a8b3ffed4e9e8a';

/// See also [Language].
@ProviderFor(Language)
final languageProvider = AutoDisposeNotifierProvider<Language, String>.internal(
  Language.new,
  name: r'languageProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$languageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Language = AutoDisposeNotifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
