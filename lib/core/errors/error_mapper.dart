import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firstlook/core/errors/app_exception.dart';

abstract final class ErrorMapper {
  static AppException mapDioError(DioException error) {
    final Object? data = error.response?.data;
    final int? statusCode = error.response?.statusCode;

    if (statusCode == 401) {
      return const AppException(
        message: 'Your session expired. Please sign in again.',
        code: 401,
        identifier: 'session_expired',
      );
    }

    if (statusCode == 403) {
      return const AppException(
        message: 'You do not have permission to perform this action.',
        code: 403,
        identifier: 'forbidden',
      );
    }

    if (statusCode == 404) {
      return const AppException(
        message: 'The requested resource could not be found.',
        code: 404,
        identifier: 'not_found',
      );
    }

    if (statusCode != null && statusCode >= 500) {
      return const AppException(
        message: 'The service is temporarily unavailable. Please try again.',
        code: 500,
        identifier: 'server_error',
      );
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const AppException(
        message: 'The request timed out. Please check your connection.',
        identifier: 'timeout',
      );
    }

    if (error.type == DioExceptionType.connectionError) {
      return const AppException(
        message: 'No internet connection was detected.',
        identifier: 'connection_error',
      );
    }

    if (error.error is SocketException ||
        (error.message?.contains('SocketException') ?? false) ||
        (error.message?.contains('Connection reset by peer') ?? false)) {
      return const AppException(
        message: 'The service is temporarily unavailable. Please try again.',
        identifier: 'socket_error',
      );
    }

    if (data is Map<String, dynamic>) {
      final String? message = data['message'] as String?;
      final String? title = data['title'] as String?;

      if (message != null && message.isNotEmpty) {
        return AppException(
          message: message,
          code: statusCode,
        );
      }

      if (title != null && title.isNotEmpty) {
        return AppException(
          message: title,
          code: statusCode,
        );
      }
    }

    return AppException(
      message: error.message ?? 'Something went wrong. Please try again.',
      code: statusCode,
      identifier: 'unknown_error',
    );
  }
}
