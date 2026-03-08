import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/features/trip/domain/usecases/create_trip_usecase.dart';
import 'package:next_destination/features/trip/domain/usecases/delete_trip_usecase.dart';
import 'package:next_destination/features/trip/domain/usecases/get_trip_by_id_usecase.dart';
import 'package:next_destination/features/trip/domain/usecases/get_trips_by_business_usecase.dart';
import 'package:next_destination/features/trip/domain/usecases/search_trips_usecase.dart';
import 'package:next_destination/features/trip/domain/usecases/update_trip_usecase.dart';
import 'package:next_destination/features/trip/presentation/state/trip_state.dart';

final tripViewModelProvider = NotifierProvider<TripViewModel, TripState>(
  () => TripViewModel(),
);

class TripViewModel extends Notifier<TripState> {
  late final CreateTripUsecase _createTripUsecase;
  late final GetTripByIdUsecase _getTripByIdUsecase;
  late final GetTripsByBusinessUsecase _getTripsByBusinessUsecase;
  late final SearchTripsUsecase _searchTripsUsecase;
  late final UpdateTripUsecase _updateTripUsecase;
  late final DeleteTripUsecase _deleteTripUsecase;

  @override
  TripState build() {
    _createTripUsecase = ref.read(createTripUsecaseProvider);
    _getTripByIdUsecase = ref.read(getTripByIdUsecaseProvider);
    _getTripsByBusinessUsecase = ref.read(getTripsByBusinessUsecaseProvider);
    _searchTripsUsecase = ref.read(searchTripsUsecaseProvider);
    _updateTripUsecase = ref.read(updateTripUsecaseProvider);
    _deleteTripUsecase = ref.read(deleteTripUsecaseProvider);

    return const TripState();
  }

  Future<void> createTrip({
    required String type,
    required String from,
    required String to,
    required DateTime departureAt,
    DateTime? arrivalAt,
    required double price,
    required int totalSeats,
    required String status,
  }) async {
    state = state.copyWith(status: TripStatus.loading);

    final params = CreateTripUsecaseParams(
      type: type,
      from: from,
      to: to,
      departureAt: departureAt,
      arrivalAt: arrivalAt,
      price: price,
      totalSeats: totalSeats,
      status: status,
    );

    final result = await _createTripUsecase.call(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: TripStatus.error,
          errorMessage: failure.message,
        );
      },
      (trip) {
        final updatedTrips = [trip, ...state.myTrips];
        state = state.copyWith(
          status: TripStatus.created,
          selectedTrip: trip,
          myTrips: updatedTrips,
        );
      },
    );
  }

  Future<void> getTripById(String tripId) async {
    state = state.copyWith(status: TripStatus.loading);

    final result = await _getTripByIdUsecase.call(tripId);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: TripStatus.error,
          errorMessage: failure.message,
        );
      },
      (trip) {
        state = state.copyWith(status: TripStatus.fetchedById, selectedTrip: trip);
      },
    );
  }

  Future<void> getMyTrips({int page = 1, int limit = 10}) async {
    state = state.copyWith(status: TripStatus.loading);

    final params = GetTripsByBusinessUsecaseParams(page: page, limit: limit);
    final result = await _getTripsByBusinessUsecase.call(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: TripStatus.error,
          errorMessage: failure.message,
        );
      },
      (trips) {
        state = state.copyWith(status: TripStatus.fetchedMine, myTrips: trips);
      },
    );
  }

  Future<void> searchTrips({
    String? type,
    String? from,
    String? to,
    String? status,
    DateTime? departureFrom,
    DateTime? departureTo,
    int page = 1,
    int limit = 10,
  }) async {
    state = state.copyWith(status: TripStatus.loading);

    final params = SearchTripsUsecaseParams(
      type: type,
      from: from,
      to: to,
      status: status,
      departureFrom: departureFrom,
      departureTo: departureTo,
      page: page,
      limit: limit,
    );

    final result = await _searchTripsUsecase.call(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: TripStatus.error,
          errorMessage: failure.message,
        );
      },
      (searchResult) {
        state = state.copyWith(
          status: TripStatus.searched,
          searchedTrips: searchResult.items,
          total: searchResult.total,
          page: searchResult.page,
          limit: searchResult.limit,
          pages: searchResult.pages,
        );
      },
    );
  }

  Future<void> updateTrip({
    required String tripId,
    required String type,
    required String from,
    required String to,
    required DateTime departureAt,
    DateTime? arrivalAt,
    required double price,
    required int totalSeats,
    required int availableSeats,
    required String status,
  }) async {
    state = state.copyWith(status: TripStatus.loading);

    final params = UpdateTripUsecaseParams(
      tripId: tripId,
      type: type,
      from: from,
      to: to,
      departureAt: departureAt,
      arrivalAt: arrivalAt,
      price: price,
      totalSeats: totalSeats,
      availableSeats: availableSeats,
      status: status,
    );

    final result = await _updateTripUsecase.call(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: TripStatus.error,
          errorMessage: failure.message,
        );
      },
      (updatedTrip) {
        final updatedTrips = state.myTrips
            .map((trip) => trip.tripId == updatedTrip.tripId ? updatedTrip : trip)
            .toList();

        state = state.copyWith(
          status: TripStatus.updated,
          selectedTrip: updatedTrip,
          myTrips: updatedTrips,
        );
      },
    );
  }

  Future<void> deleteTrip(String tripId) async {
    state = state.copyWith(status: TripStatus.loading);

    final result = await _deleteTripUsecase.call(tripId);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: TripStatus.error,
          errorMessage: failure.message,
        );
      },
      (isDeleted) {
        if (isDeleted) {
          final updatedTrips = state.myTrips
              .where((trip) => trip.tripId != tripId)
              .toList();

          state = state.copyWith(status: TripStatus.deleted, myTrips: updatedTrips);
        } else {
          state = state.copyWith(
            status: TripStatus.error,
            errorMessage: 'Trip delete failed',
          );
        }
      },
    );
  }
}
