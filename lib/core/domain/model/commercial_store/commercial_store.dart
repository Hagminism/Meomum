import 'package:freezed_annotation/freezed_annotation.dart';

part 'commercial_store.freezed.dart';
part 'commercial_store.g.dart';

@freezed
abstract class CommercialStore with _$CommercialStore {
  const factory CommercialStore({
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    String? branchName,
    String? industryLargeCode,
    String? industryLargeName,
    String? address,
  }) = _CommercialStore;

  factory CommercialStore.fromJson(Map<String, dynamic> json) =>
      _$CommercialStoreFromJson(json);
}
