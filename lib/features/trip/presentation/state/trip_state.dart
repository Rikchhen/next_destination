import 'package:equatable/equatable.dart';
import 'package:next_destination/features/trip/domain/entity/trip_entity.dart';

enum TripStatus {
  initial,
  loading,
  created,
  updated,
  deleted,
  fetchedById,
  fetchedMine,
  searched,
  error,
}

class TripState extends Equatable {
  final TripStatus status;
  final TripEntity? selectedTrip;
  final List<TripEntity> myTrips;
  final List<TripEntity> searchedTrips;
  final int total;
  final int page;
  final int limit;
  final int pages;
  final String? errorMessage;

  const TripState({
    this.status = TripStatus.initial,
    this.selectedTrip,
    this.myTrips = const [],
    this.searchedTrips = const [],
    this.total = 0,
    this.page = 1,
    this.limit = 10,
    this.pages = 1,
    this.errorMessage,
  });

  TripState copyWith({
    TripStatus? status,
    TripEntity? selectedTrip,
    List<TripEntity>? myTrips,
    List<TripEntity>? searchedTrips,
    int? total,
    int? page,
    int? limit,
    int? pages,
    String? errorMessage,
  }) {
    return TripState(
      status: status ?? this.status,
      selectedTrip: selectedTrip ?? this.selectedTrip,
      myTrips: myTrips ?? this.myTrips,
      searchedTrips: searchedTrips ?? this.searchedTrips,
      total: total ?? this.total,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      pages: pages ?? this.pages,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    selectedTrip,
    myTrips,
    searchedTrips,
    total,
    page,
    limit,
    pages,
    errorMessage,
  ];
}
