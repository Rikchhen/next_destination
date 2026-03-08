import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:next_destination/core/error/failures.dart';
import 'package:next_destination/core/services/connectivity/network_info.dart';
import 'package:next_destination/core/services/hive/hive_service.dart';
import 'package:next_destination/core/services/storage/user_session_storage.dart';
import 'package:next_destination/features/ticket/data/datasource/remote/ticket_remote_datasource.dart';
import 'package:next_destination/features/ticket/data/datasource/ticket_datasource.dart';
import 'package:next_destination/features/ticket/data/model/ticket_api_model.dart';
import 'package:next_destination/features/ticket/domain/entity/ticket_entity.dart';
import 'package:next_destination/features/ticket/domain/repository/ticket_repository.dart';
import 'package:next_destination/features/ticket/domain/usecases/void_ticket_usecase.dart';

final ticketRepositoryProvider = Provider<ITicketRepository>((ref) {
  final remoteDatasource = ref.read(ticketRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  final hiveService = ref.read(hiveServiceProvider);
  final userSessionService = ref.read(userSessionServiceProvider);

  return TicketRepository(
    ticketRemoteDatasource: remoteDatasource,
    networkInfo: networkInfo,
    hiveService: hiveService,
    userSessionService: userSessionService,
  );
});

class TicketRepository implements ITicketRepository {
  final ITicketRemoteDatasource _ticketRemoteDatasource;
  final NetworkInfo _networkInfo;
  final HiveService _hiveService;
  final UserSessionService _userSessionService;

  TicketRepository({
    required ITicketRemoteDatasource ticketRemoteDatasource,
    required NetworkInfo networkInfo,
    required HiveService hiveService,
    required UserSessionService userSessionService,
  }) : _ticketRemoteDatasource = ticketRemoteDatasource,
       _networkInfo = networkInfo,
       _hiveService = hiveService,
       _userSessionService = userSessionService;

  @override
  Future<Either<Failure, TicketEntity>> getTicketById(String ticketId) async {
    if (await _networkInfo.isConnected) {
      try {
        final ticket = await _ticketRemoteDatasource.getTicketById(ticketId);
        final entity = ticket.toEntity();
        await _cacheTickets([entity]);
        return Right(entity);
      } on DioException catch (e) {
        final cached = _getCachedTicketById(ticketId);
        if (cached != null) {
          return Right(cached);
        }
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Ticket not found',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        final cached = _getCachedTicketById(ticketId);
        if (cached != null) {
          return Right(cached);
        }
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      final cached = _getCachedTicketById(ticketId);
      if (cached != null) {
        return Right(cached);
      }
      return Left(NetworkFailure(message: 'Internet Required To Fetch Ticket'));
    }
  }

  @override
  Future<Either<Failure, List<TicketEntity>>> getTicketsByBooking(
    String bookingId,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final tickets = await _ticketRemoteDatasource.getTicketsByBooking(bookingId);
        final entities = TicketApiModel.toEntityList(tickets);
        await _cacheTickets(entities);
        return Right(entities);
      } on DioException catch (e) {
        final cached = _getCachedTicketsByBooking(bookingId);
        if (cached.isNotEmpty) {
          return Right(cached);
        }
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to fetch tickets',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        final cached = _getCachedTicketsByBooking(bookingId);
        if (cached.isNotEmpty) {
          return Right(cached);
        }
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      final cached = _getCachedTicketsByBooking(bookingId);
      if (cached.isNotEmpty) {
        return Right(cached);
      }
      return Left(NetworkFailure(message: 'Internet Required To Fetch Tickets'));
    }
  }

  @override
  Future<Either<Failure, TicketEntity>> scanTicket(String qrToken) async {
    if (await _networkInfo.isConnected) {
      try {
        final ticket = await _ticketRemoteDatasource.scanTicket(qrToken);
        final entity = ticket.toEntity();
        await _cacheTickets([entity]);
        return Right(entity);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Ticket scan failed',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'Internet Required For Ticket Scan'));
    }
  }

  @override
  Future<Either<Failure, TicketEntity>> voidTicket(
    VoidTicketUsecaseParams params,
  ) async {
    if (await _networkInfo.isConnected) {
      try {
        final ticket = await _ticketRemoteDatasource.voidTicket(
          params.ticketId,
          reason: params.reason,
        );
        final entity = ticket.toEntity();
        await _cacheTickets([entity]);
        return Right(entity);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Failed to void ticket',
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      return Left(NetworkFailure(message: 'Internet Required To Void Ticket'));
    }
  }

  String get _userScope {
    final currentUser = _userSessionService.getCurrentUserId();
    if (currentUser != null && currentUser.isNotEmpty) {
      return currentUser;
    }
    return 'default';
  }

  Future<void> _cacheTickets(List<TicketEntity> tickets) async {
    await _hiveService.cacheTickets(
      userScope: _userScope,
      tickets: tickets.map(_ticketToMap).toList(),
      maxRecent: 10,
    );
  }

  TicketEntity? _getCachedTicketById(String ticketId) {
    final raw = _hiveService.getCachedTicketById(
      userScope: _userScope,
      ticketId: ticketId,
    );
    if (raw == null) {
      return null;
    }
    return _ticketFromMap(raw);
  }

  List<TicketEntity> _getCachedTicketsByBooking(String bookingId) {
    final rawList = _hiveService.getCachedTicketsByBooking(
      userScope: _userScope,
      bookingId: bookingId,
    );
    return rawList.map(_ticketFromMap).toList();
  }

  Map<String, dynamic> _ticketToMap(TicketEntity ticket) {
    return <String, dynamic>{
      'ticketId': ticket.ticketId,
      'booking': ticket.booking,
      'trip': ticket.trip,
      'bookedBy': ticket.bookedBy,
      'passengerName': ticket.passengerName,
      'seatNumber': ticket.seatNumber,
      'qrToken': ticket.qrToken,
      'status': ticket.status,
      'issuedAt': ticket.issuedAt?.toIso8601String(),
      'usedAt': ticket.usedAt?.toIso8601String(),
      'expiresAt': ticket.expiresAt?.toIso8601String(),
      'voidReason': ticket.voidReason,
    };
  }

  TicketEntity _ticketFromMap(Map<String, dynamic> json) {
    return TicketEntity(
      ticketId: json['ticketId']?.toString(),
      booking: (json['booking'] ?? '').toString(),
      trip: (json['trip'] ?? '').toString(),
      bookedBy: (json['bookedBy'] ?? '').toString(),
      passengerName: (json['passengerName'] ?? '').toString(),
      seatNumber: (json['seatNumber'] ?? '').toString(),
      qrToken: (json['qrToken'] ?? '').toString(),
      status: (json['status'] ?? 'issued').toString(),
      issuedAt: json['issuedAt'] == null
          ? null
          : DateTime.tryParse(json['issuedAt'].toString()),
      usedAt: json['usedAt'] == null
          ? null
          : DateTime.tryParse(json['usedAt'].toString()),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.tryParse(json['expiresAt'].toString()),
      voidReason: json['voidReason']?.toString(),
    );
  }
}
