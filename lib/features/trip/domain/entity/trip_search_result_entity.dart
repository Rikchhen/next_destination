import 'package:equatable/equatable.dart';
import 'package:next_destination/features/trip/domain/entity/trip_entity.dart';

class TripSearchResultEntity extends Equatable {
  final List<TripEntity> items;
  final int total;
  final int page;
  final int limit;
  final int pages;

  const TripSearchResultEntity({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  @override
  List<Object?> get props => [items, total, page, limit, pages];
}
