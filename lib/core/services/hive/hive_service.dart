import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:next_destination/core/constants/hive_table_constant.dart';
import 'package:next_destination/features/auth/data/models/user_hive_model.dart';
import 'package:path_provider/path_provider.dart';

// Hivfe Srevice Provider
final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();

    final path = '${directory.path}/${HiveTableConstant.dbName}';
    Hive.init(path);
    _registerAdapter();
    await openBoxes();
  }

  // RegisterAdapter
  void _registerAdapter() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.userTypeId)) {
      Hive.registerAdapter(UserHiveModelAdapter());
    }
  }

  // Open Boxes
  Future<void> openBoxes() async {
    await Hive.openBox<UserHiveModel>(HiveTableConstant.userTable);
    await Hive.openBox<dynamic>(HiveTableConstant.profileCacheTable);
    await Hive.openBox<dynamic>(HiveTableConstant.bookingCacheTable);
    await Hive.openBox<dynamic>(HiveTableConstant.ticketCacheTable);
    await Hive.openBox<dynamic>(HiveTableConstant.tripCacheTable);
  }

  // Close Boxes
  Future<void> close() async {
    await Hive.close();
  }

  // ================================================= User Queries =====================================================================//

  // Makina a box for user things.
  Box<UserHiveModel> get _userBox => Hive.box(HiveTableConstant.userTable);
  Box<dynamic> get _profileCacheBox => Hive.box(HiveTableConstant.profileCacheTable);
  Box<dynamic> get _bookingCacheBox => Hive.box(HiveTableConstant.bookingCacheTable);
  Box<dynamic> get _ticketCacheBox => Hive.box(HiveTableConstant.ticketCacheTable);
  Box<dynamic> get _tripCacheBox => Hive.box(HiveTableConstant.tripCacheTable);

  // register user
  Future<UserHiveModel> registerUser(UserHiveModel model) async {
    await _userBox.put(model.userId, model);
    return model;
  }

  // User Login
  Future<UserHiveModel?> loginUser(String phoneNumber, String password) async {
    final users = _userBox.values.where(
      (user) => user.phoneNumber == phoneNumber && user.password == password,
    );
    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  }

  // user logout
  Future<void> logout() async {}

  // Get Current User.
  UserHiveModel? getCurrentUser(String userId) {
    return _userBox.get(userId);
  }

  bool isEmailExists(String email) {
    final users = _userBox.values.where((user) => user.email == email);
    return users.isNotEmpty;
  }

  Future<void> cacheProfile({
    required String userScope,
    required Map<String, dynamic> profile,
  }) async {
    await _profileCacheBox.put(_profileKey(userScope), profile);
  }

  Map<String, dynamic>? getCachedProfile(String userScope) {
    final raw = _profileCacheBox.get(_profileKey(userScope));
    return _mapFromDynamic(raw);
  }

  Future<void> cacheBusinessProfile({
    required String businessScope,
    required Map<String, dynamic> profile,
  }) async {
    await _profileCacheBox.put(_businessProfileKey(businessScope), profile);
  }

  Map<String, dynamic>? getCachedBusinessProfile(String businessScope) {
    final raw = _profileCacheBox.get(_businessProfileKey(businessScope));
    return _mapFromDynamic(raw);
  }

  Future<void> cacheBookingDetail({
    required String userScope,
    required String bookingId,
    required String bookingRef,
    required Map<String, dynamic> detail,
  }) async {
    await _bookingCacheBox.put(_bookingDetailKey(userScope, bookingId), detail);
    await _bookingCacheBox.put(_bookingRefKey(userScope, bookingRef), bookingId);
  }

  Map<String, dynamic>? getCachedBookingDetailById({
    required String userScope,
    required String bookingId,
  }) {
    final raw = _bookingCacheBox.get(_bookingDetailKey(userScope, bookingId));
    return _mapFromDynamic(raw);
  }

  Map<String, dynamic>? getCachedBookingDetailByRef({
    required String userScope,
    required String bookingRef,
  }) {
    final bookingId = _bookingCacheBox.get(_bookingRefKey(userScope, bookingRef));
    if (bookingId is! String || bookingId.isEmpty) {
      return null;
    }
    return getCachedBookingDetailById(userScope: userScope, bookingId: bookingId);
  }

  Future<void> cacheMyBookings({
    required String userScope,
    required List<Map<String, dynamic>> bookings,
  }) async {
    await _bookingCacheBox.put(_myBookingsKey(userScope), bookings);
  }

  List<Map<String, dynamic>> getCachedMyBookings(String userScope) {
    final raw = _bookingCacheBox.get(_myBookingsKey(userScope));
    if (raw is! List) {
      return const [];
    }
    return raw
        .map<Map<String, dynamic>>((e) => _mapFromDynamic(e) ?? const <String, dynamic>{})
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> cacheTickets({
    required String userScope,
    required List<Map<String, dynamic>> tickets,
    int maxRecent = 10,
  }) async {
    final ticketByIdRaw = _ticketCacheBox.get(_ticketByIdKey(userScope));
    final ticketById = _mapFromDynamic(ticketByIdRaw) ?? <String, dynamic>{};

    final bookingToIdsRaw = _ticketCacheBox.get(_bookingTicketIdsKey(userScope));
    final bookingToIds = _mapFromDynamic(bookingToIdsRaw) ?? <String, dynamic>{};

    final recentRaw = _ticketCacheBox.get(_recentTicketIdsKey(userScope));
    final recentIds = _stringListFromDynamic(recentRaw);

    for (final ticket in tickets) {
      final ticketId = (ticket['ticketId'] ?? '').toString();
      if (ticketId.isEmpty) {
        continue;
      }

      ticketById[ticketId] = ticket;

      final bookingId = (ticket['booking'] ?? '').toString();
      if (bookingId.isNotEmpty) {
        final bookingIds = _stringListFromDynamic(bookingToIds[bookingId]);
        if (!bookingIds.contains(ticketId)) {
          bookingIds.add(ticketId);
        }
        bookingToIds[bookingId] = bookingIds;
      }

      recentIds.remove(ticketId);
      recentIds.insert(0, ticketId);
    }

    while (recentIds.length > maxRecent) {
      recentIds.removeLast();
    }

    await _ticketCacheBox.put(_ticketByIdKey(userScope), ticketById);
    await _ticketCacheBox.put(_bookingTicketIdsKey(userScope), bookingToIds);
    await _ticketCacheBox.put(_recentTicketIdsKey(userScope), recentIds);
  }

  Map<String, dynamic>? getCachedTicketById({
    required String userScope,
    required String ticketId,
  }) {
    final ticketById = _mapFromDynamic(_ticketCacheBox.get(_ticketByIdKey(userScope)));
    if (ticketById == null) {
      return null;
    }
    return _mapFromDynamic(ticketById[ticketId]);
  }

  List<Map<String, dynamic>> getCachedTicketsByBooking({
    required String userScope,
    required String bookingId,
  }) {
    final ticketById = _mapFromDynamic(_ticketCacheBox.get(_ticketByIdKey(userScope)));
    final bookingToIds = _mapFromDynamic(_ticketCacheBox.get(_bookingTicketIdsKey(userScope)));
    if (ticketById == null || bookingToIds == null) {
      return const [];
    }

    final ticketIds = _stringListFromDynamic(bookingToIds[bookingId]);
    return ticketIds
        .map((id) => _mapFromDynamic(ticketById[id]))
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  List<Map<String, dynamic>> getRecentCachedTickets({
    required String userScope,
    int limit = 10,
  }) {
    final ticketById = _mapFromDynamic(_ticketCacheBox.get(_ticketByIdKey(userScope)));
    if (ticketById == null) {
      return const [];
    }

    final recentIds = _stringListFromDynamic(_ticketCacheBox.get(_recentTicketIdsKey(userScope)));

    return recentIds
        .take(limit)
        .map((id) => _mapFromDynamic(ticketById[id]))
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  List<Map<String, dynamic>> getAllCachedTickets({
    required String userScope,
  }) {
    final ticketById = _mapFromDynamic(_ticketCacheBox.get(_ticketByIdKey(userScope)));
    if (ticketById == null) {
      return const [];
    }

    return ticketById.values
        .map((e) => _mapFromDynamic(e))
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  List<Map<String, dynamic>> getCachedTicketsByTrip({
    required String userScope,
    required String tripId,
  }) {
    if (tripId.isEmpty) {
      return const [];
    }

    return getAllCachedTickets(userScope: userScope)
        .where((ticket) => (ticket['trip'] ?? '').toString() == tripId)
        .toList();
  }

  Future<void> cacheMyTrips({
    required String userScope,
    required List<Map<String, dynamic>> trips,
  }) async {
    await _tripCacheBox.put(_myTripsKey(userScope), trips);
  }

  List<Map<String, dynamic>> getCachedMyTripsForBusiness(String userScope) {
    final raw = _tripCacheBox.get(_myTripsKey(userScope));
    if (raw is! List) {
      return const [];
    }

    return raw
        .map<Map<String, dynamic>>((e) => _mapFromDynamic(e) ?? const <String, dynamic>{})
        .where((e) => e.isNotEmpty)
        .toList();
  }

  String _profileKey(String userScope) => 'profile:$userScope';
  String _businessProfileKey(String businessScope) => 'business_profile:$businessScope';
  String _bookingDetailKey(String userScope, String bookingId) =>
      'booking_detail:$userScope:$bookingId';
  String _bookingRefKey(String userScope, String bookingRef) =>
      'booking_ref:$userScope:$bookingRef';
  String _myBookingsKey(String userScope) => 'my_bookings:$userScope';
  String _ticketByIdKey(String userScope) => 'ticket_by_id:$userScope';
  String _bookingTicketIdsKey(String userScope) => 'booking_ticket_ids:$userScope';
  String _recentTicketIdsKey(String userScope) => 'recent_ticket_ids:$userScope';
  String _myTripsKey(String userScope) => 'my_trips:$userScope';

  Map<String, dynamic>? _mapFromDynamic(dynamic raw) {
    if (raw is Map) {
      return raw.map((key, value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  List<String> _stringListFromDynamic(dynamic raw) {
    if (raw is! List) {
      return <String>[];
    }
    return raw.map((e) => e.toString()).toList();
  }
}
