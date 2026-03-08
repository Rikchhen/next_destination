import 'package:next_destination/features/trip/data/model/trip_api_model.dart';
import 'package:next_destination/features/trip/domain/entity/trip_search_result_entity.dart';

class TripSearchResultApiModel {
  final List<TripApiModel> items;
  final int total;
  final int page;
  final int limit;
  final int pages;

  TripSearchResultApiModel({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory TripSearchResultApiModel.fromJson(Map<String, dynamic> json) {
    final list = (json['items'] as List<dynamic>? ?? [])
        .map((e) => TripApiModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return TripSearchResultApiModel(
      items: list,
      total: (json['total'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
      pages: (json['pages'] as num?)?.toInt() ?? 1,
    );
  }

  TripSearchResultEntity toEntity() {
    return TripSearchResultEntity(
      items: TripApiModel.toEntityList(items),
      total: total,
      page: page,
      limit: limit,
      pages: pages,
    );
  }
}
