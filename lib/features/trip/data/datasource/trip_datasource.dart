import 'package:next_destination/features/trip/data/model/trip_api_model.dart';
import 'package:next_destination/features/trip/data/model/trip_search_result_api_model.dart';

abstract interface class ITripRemoteDatasource {
  Future<TripApiModel> createTrip(TripApiModel model);
  Future<TripApiModel> getTripById(String tripId);
  Future<List<TripApiModel>> getTripsByBusiness({int page = 1, int limit = 10});
  Future<TripSearchResultApiModel> searchTrips({
    String? type,
    String? from,
    String? to,
    String? status,
    DateTime? departureFrom,
    DateTime? departureTo,
    int page = 1,
    int limit = 10,
  });
  Future<TripApiModel> updateTrip(String tripId, TripApiModel model);
  Future<bool> deleteTrip(String tripId);
}
