import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/core/services/connectivity/network_info.dart';
import 'package:next_destination/core/services/hive/hive_service.dart';
import 'package:next_destination/core/services/storage/user_session_storage.dart';
import 'package:next_destination/features/booking/data/datasource/booking_datasource.dart';
import 'package:next_destination/features/booking/data/datasource/remote/booking_remote_datasource.dart';
import 'package:next_destination/features/booking/data/model/passenger_api_model.dart';
import 'package:next_destination/features/booking/domain/entity/booking_detail_entity.dart';
import 'package:next_destination/features/booking/domain/entity/booking_entity.dart';
import 'package:next_destination/features/booking/domain/entity/passenger_entity.dart';
import 'package:next_destination/features/booking/domain/entity/ticket_entity.dart'
    as booking_domain;
import 'package:next_destination/features/booking/domain/repository/booking_repository.dart';
import 'package:next_destination/features/booking/domain/usecases/cancel_booking_usecase.dart';
import 'package:next_destination/features/booking/domain/usecases/get_my_bookings_usecase.dart';

final bookingRepositoryProvider = Provider<IBookingRepository>((ref) {
  final remoteDatasource = ref.read(bookingRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  final hiveService = ref.read(hiveServiceProvider);
  final userSessionService = ref.read(userSessionServiceProvider);

  return BookingRepository(
    bookingRemoteDatasource: remoteDatasource,
    networkInfo: networkInfo,
    hiveService: hiveService,
    userSessionService: userSessionService,
  );
});

class BookingRepository implements IBookingRepository {
  final IBookingRemoteDatasource _bookingRemoteDatasource;
  final NetworkInfo _networkInfo;
  final HiveService _hiveService;
  final UserSessionService _userSessionService;

  BookingRepository({
    required IBookingRemoteDatasource bookingRemoteDatasource,
    required NetworkInfo networkInfo,
    required HiveService hiveService,
    required UserSessionService userSessionService,
  }) : _bookingRemoteDatasource = bookingRemoteDatasource,
       _networkInfo = networkInfo,
       _hiveService = hiveService,
       _userSessionService = userSessionService;

  @override
  Future<Either<Failure, BookingDetailEntity>> createBooking({
    required String trip,
    required List<PassengerEntity> passengers,
    required String contactEmail,
    required String contactPhone,
  }) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _bookingRemoteDatasource.createBooking(
          trip: trip,
          passengers: passengers
              .map((e) => PassengerApiModel.fromEntity(e).toJson())
              .toList(),
          contactEmail: contactEmail,
          contactPhone: contactPhone,
        );
        final detail = result.toEntity();
        await _cacheBookingDetail(detail);
        return Right(detail);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Booking creation failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'Internet Required For Booking'));
    }
  }

  @override
  Future<Either<Failure, BookingDetailEntity>> getBookingById(
    String bookingId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _bookingRemoteDatasource.getBookingById(bookingId);
        final detail = result.toEntity();
        await _cacheBookingDetail(detail);
        return Right(detail);
      } on DioException catch (e) {
        final cached = _getCachedBookingById(bookingId);
        if (cached != null) {
          return Right(cached);
        }
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to fetch booking',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        final cached = _getCachedBookingById(bookingId);
        if (cached != null) {
          return Right(cached);
        }
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      final cached = _getCachedBookingById(bookingId);
      if (cached != null) {
        return Right(cached);
      }
      return Left(NetworkFailure(message: 'Internet Required To Fetch Booking'));
    }
  }

  @override
  Future<Either<Failure, BookingDetailEntity>> getBookingByRef(
    String bookingRef,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final result = await _bookingRemoteDatasource.getBookingByRef(bookingRef);
        final detail = result.toEntity();
        await _cacheBookingDetail(detail);
        return Right(detail);
      } on DioException catch (e) {
        final cached = _getCachedBookingByRef(bookingRef);
        if (cached != null) {
          return Right(cached);
        }
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Booking not found',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        final cached = _getCachedBookingByRef(bookingRef);
        if (cached != null) {
          return Right(cached);
        }
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      final cached = _getCachedBookingByRef(bookingRef);
      if (cached != null) {
        return Right(cached);
      }
      return Left(NetworkFailure(message: 'Internet Required To Fetch Booking'));
    }
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> getMyBookings(
    GetMyBookingsUsecaseParams params,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final bookings = await _bookingRemoteDatasource.getMyBookings(
          page: params.page,
          limit: params.limit,
        );
        final entities = bookings.map((e) => e.toEntity()).toList();
        await _hiveService.cacheMyBookings(
          userScope: _userScope,
          bookings: entities.map(_bookingToMap).toList(),
        );

        return Right(entities);
      } on DioException catch (e) {
        final cached = _getCachedMyBookings();
        if (cached.isNotEmpty) {
          return Right(cached);
        }
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to fetch bookings',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        final cached = _getCachedMyBookings();
        if (cached.isNotEmpty) {
          return Right(cached);
        }
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      final cached = _getCachedMyBookings();
      if (cached.isNotEmpty) {
        return Right(cached);
      }
      return Left(NetworkFailure(message: 'Internet Required To Fetch Bookings'));
    }
  }

  @override
  Future<Either<Failure, BookingEntity>> cancelBooking(
    CancelBookingUsecaseParams params,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final booking = await _bookingRemoteDatasource.cancelBooking(
          params.bookingId,
          reason: params.reason,
        );
        final entity = booking.toEntity();
        await _syncCancelledBookingCache(entity);
        return Right(entity);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Booking cancellation failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(
        NetworkFailure(message: 'Internet Required To Cancel Booking'),
      );
    }
  }

  String get _userScope {
    final currentUser = _userSessionService.getCurrentUserId();
    if (currentUser != null && currentUser.isNotEmpty) {
      return currentUser;
    }
    return 'default';
  }

  Future<void> _cacheBookingDetail(BookingDetailEntity detail) async {
    final bookingId = detail.booking.bookingId;
    if (bookingId == null || bookingId.isEmpty) {
      return;
    }

    await _hiveService.cacheBookingDetail(
      userScope: _userScope,
      bookingId: bookingId,
      bookingRef: detail.booking.bookingRef,
      detail: _detailToMap(detail),
    );

    await _hiveService.cacheTickets(
      userScope: _userScope,
      tickets: detail.tickets.map(_bookingTicketToMap).toList(),
      maxRecent: 10,
    );

    final existing = _getCachedMyBookings();
    final upserted = _upsertBooking(existing, detail.booking);
    await _hiveService.cacheMyBookings(
      userScope: _userScope,
      bookings: upserted.map(_bookingToMap).toList(),
    );
  }

  BookingDetailEntity? _getCachedBookingById(String bookingId) {
    final raw = _hiveService.getCachedBookingDetailById(
      userScope: _userScope,
      bookingId: bookingId,
    );
    if (raw == null) {
      return null;
    }
    return _detailFromMap(raw);
  }

  BookingDetailEntity? _getCachedBookingByRef(String bookingRef) {
    final raw = _hiveService.getCachedBookingDetailByRef(
      userScope: _userScope,
      bookingRef: bookingRef,
    );
    if (raw == null) {
      return null;
    }
    return _detailFromMap(raw);
  }

  List<BookingEntity> _getCachedMyBookings() {
    final cached = _hiveService.getCachedMyBookings(_userScope);
    return cached.map(_bookingFromMap).toList();
  }

  Future<void> _syncCancelledBookingCache(BookingEntity cancelledBooking) async {
    final bookingId = cancelledBooking.bookingId;
    if (bookingId == null || bookingId.isEmpty) {
      return;
    }

    final detail = _getCachedBookingById(bookingId);
    if (detail != null) {
      await _cacheBookingDetail(
        BookingDetailEntity(booking: cancelledBooking, tickets: detail.tickets),
      );
    }

    final updatedBookings = _upsertBooking(_getCachedMyBookings(), cancelledBooking);
    await _hiveService.cacheMyBookings(
      userScope: _userScope,
      bookings: updatedBookings.map(_bookingToMap).toList(),
    );
  }

  List<BookingEntity> _upsertBooking(
    List<BookingEntity> current,
    BookingEntity updated,
  ) {
    final updatedList = current
        .where((e) => e.bookingId != updated.bookingId)
        .toList(growable: true);
    updatedList.insert(0, updated);
    return updatedList;
  }

  Map<String, dynamic> _detailToMap(BookingDetailEntity detail) {
    return <String, dynamic>{
      'booking': _bookingToMap(detail.booking),
      'tickets': detail.tickets.map(_bookingTicketToMap).toList(),
    };
  }

  BookingDetailEntity _detailFromMap(Map<String, dynamic> json) {
    final bookingMap = (json['booking'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final ticketListRaw = json['tickets'] as List? ?? const [];

    return BookingDetailEntity(
      booking: _bookingFromMap(bookingMap),
      tickets: ticketListRaw
          .whereType<Map>()
          .map((e) => _bookingTicketFromMap(e.cast<String, dynamic>()))
          .toList(),
    );
  }

  Map<String, dynamic> _bookingToMap(BookingEntity booking) {
    return <String, dynamic>{
      'bookingId': booking.bookingId,
      'bookedBy': booking.bookedBy,
      'trip': booking.trip,
      'bookingRef': booking.bookingRef,
      'status': booking.status,
      'passengers': booking.passengers.map(_passengerToMap).toList(),
      'contactEmail': booking.contactEmail,
      'contactPhone': booking.contactPhone,
      'totalAmount': booking.totalAmount,
      'cancelReason': booking.cancelReason,
      'createdAt': booking.createdAt?.toIso8601String(),
    };
  }

  BookingEntity _bookingFromMap(Map<String, dynamic> json) {
    final passengersRaw = json['passengers'] as List? ?? const [];
    return BookingEntity(
      bookingId: json['bookingId']?.toString(),
      bookedBy: (json['bookedBy'] ?? '').toString(),
      trip: (json['trip'] ?? '').toString(),
      bookingRef: (json['bookingRef'] ?? '').toString(),
      status: (json['status'] ?? 'pending').toString(),
      passengers: passengersRaw
          .whereType<Map>()
          .map((e) => _passengerFromMap(e.cast<String, dynamic>()))
          .toList(),
      contactEmail: (json['contactEmail'] ?? '').toString(),
      contactPhone: (json['contactPhone'] ?? '').toString(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      cancelReason: json['cancelReason']?.toString(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.tryParse(json['createdAt'].toString()),
    );
  }

  Map<String, dynamic> _passengerToMap(PassengerEntity passenger) {
    return <String, dynamic>{
      'fullName': passenger.fullName,
      'age': passenger.age,
      'gender': passenger.gender,
      'seatNumber': passenger.seatNumber,
    };
  }

  PassengerEntity _passengerFromMap(Map<String, dynamic> json) {
    return PassengerEntity(
      fullName: (json['fullName'] ?? '').toString(),
      age: (json['age'] as num?)?.toInt() ?? 0,
      gender: (json['gender'] ?? '').toString(),
      seatNumber: (json['seatNumber'] ?? '').toString(),
    );
  }

  Map<String, dynamic> _bookingTicketToMap(
    booking_domain.TicketEntity ticket,
  ) {
    return <String, dynamic>{
      'ticketId': ticket.ticketId,
      'booking': ticket.bookingId,
      'trip': ticket.tripId,
      'bookedBy': ticket.bookedBy,
      'passengerName': ticket.passengerName,
      'seatNumber': ticket.seatNumber,
      'qrToken': ticket.qrToken,
      'status': ticket.status,
      'issuedAt': ticket.issuedAt?.toIso8601String(),
      'expiresAt': ticket.expiresAt?.toIso8601String(),
    };
  }

  booking_domain.TicketEntity _bookingTicketFromMap(Map<String, dynamic> json) {
    return booking_domain.TicketEntity(
      ticketId: json['ticketId']?.toString(),
      bookingId: json['booking']?.toString(),
      tripId: json['trip']?.toString(),
      bookedBy: json['bookedBy']?.toString(),
      passengerName: (json['passengerName'] ?? '').toString(),
      seatNumber: (json['seatNumber'] ?? '').toString(),
      status: (json['status'] ?? 'issued').toString(),
      qrToken: json['qrToken']?.toString(),
      issuedAt: json['issuedAt'] == null
          ? null
          : DateTime.tryParse(json['issuedAt'].toString()),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.tryParse(json['expiresAt'].toString()),
    );
  }
}
