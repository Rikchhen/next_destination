import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Configuration
  static const bool isPhysicalDevice = false;
  static const String _ipAddress = '192.168.68.117';
  static const int _port = 5000;

  // Base URLs
  static String get _host {
    if (isPhysicalDevice) return _ipAddress;
    if (kIsWeb || Platform.isIOS) return 'localhost';
    if (Platform.isAndroid) return '10.0.2.2';
    return 'localhost';
  }

  static String get serverUrl => 'http://$_host:$_port';
  static String get baseUrl => '$serverUrl/api';
  static String get mediaServerUrl => serverUrl;

  static String get profileImages => '$mediaServerUrl/uploads';
  static String resolveUploadUrl(String raw, {String? defaultFolder}) {
    final value = raw.trim().replaceAll('\\', '/');
    if (value.isEmpty) return '';

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    if (value.startsWith('/uploads/')) {
      return '$mediaServerUrl$value';
    }

    if (value.startsWith('uploads/')) {
      return '$mediaServerUrl/$value';
    }

    if (value.contains('/')) {
      return '$profileImages/$value';
    }

    if (defaultFolder != null && defaultFolder.isNotEmpty) {
      return '$profileImages/$defaultFolder/$value';
    }

    return '$profileImages/$value';
  }

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============ User Endpoints =============
  static const String users = '/user';
  static const String userLogin = '/user/login';
  static const String userRegister = '/user/register';
  static String userById(String id) => '/user/$id';
  static const String getProfile = '/user/me';
  static const String editProfile = '/user/me';

  // Business
  static const String businesses = '/business';
  static const String businessRegister = '/business/register';
  static const String businessLogin = '/business/login';
  static const String businessProfile = '/business/profile';
  static const String businessEditProfile = '/business/profile/edit';
  static const String businessUploadDocument = '/business/upload-document';

  // Trip
  static const String trips = '/trip';
  static const String tripSearch = '/trip/search';
  static String tripById(String id) => '/trip/$id';
  static const String tripCreate = '/trip/create';
  static const String tripBusinessMine = '/trip/business/mine';
  static String tripEditById(String id) => '/trip/edit/$id';
  static String tripDeleteById(String id) => '/trip/delete/$id';

  // Booking
  static const String bookings = '/booking';
  static const String bookingCreate = '/booking/create';
  static const String bookingMine = '/booking/mine';
  static String bookingByRef(String ref) => '/booking/ref/$ref';
  static String bookingById(String id) => '/booking/$id';
  static String bookingCancelById(String id) => '/booking/cancel/$id';

  // Ticket
  static const String tickets = '/ticket';
  static String ticketById(String id) => '/ticket/$id';
  static String ticketsByBooking(String bookingId) =>
      '/ticket/booking/$bookingId';
  static const String ticketScan = '/ticket/scan';
  static String ticketVoidById(String id) => '/ticket/void/$id';

  // Payment
  static const String payments = '/payment';
  static const String paymentKhaltiInitiate = '/payment/khalti/initiate';
  static const String paymentKhaltiVerify = '/payment/khalti/verify';
  static String paymentByBooking(String bookingId) =>
      '/payment/booking/$bookingId';
  static const String paymentMine = '/payment/mine';

  // Wallet
  static const String walletBalance = '/wallet/balance';
  static const String walletTransactions = '/wallet/transactions';
  static const String businessWalletBalance = '/wallet/business/balance';
  static const String businessWalletTransactions =
      '/wallet/business/transactions';

  // Admin -> Business operations
  static const String adminBase = '/admin';
  static const String adminGetAllBusinesses = '/admin/all-businesses';
  static String adminApproveBusiness(String businessId) =>
      '/admin/approve-business/$businessId';

  // ============ Batch Endpoints ============
  static const String batches = '/batches';
  static String batchById(String id) => '/batches/$id';

  // ============ Category Endpoints ============
  static const String categories = '/categories';
  static String categoryById(String id) => '/categories/$id';

  // ============ Student Endpoints ============
  static const String students = '/students';
  static const String studentLogin = '/students/login';
  static const String studentRegister = '/students/register';
  static String studentById(String id) => '/students/$id';
  static String studentPhoto(String id) => '/students/$id/photo';

  // ============ Item Endpoints ============
  static const String items = '/items';
  static String itemById(String id) => '/items/$id';
  static String itemClaim(String id) => '/items/$id/claim';
}
