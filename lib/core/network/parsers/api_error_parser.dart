import 'package:dio/dio.dart';
import 'package:firstlook/core/errors/app_exception.dart';
import 'package:firstlook/core/errors/error_mapper.dart';

class ApiErrorParser {
  const ApiErrorParser();

  AppException parse(Object error) {
    if (error is AppException) {
      return error;
    }

    if (error is DioException) {
      return ErrorMapper.mapDioError(error);
    }

    return AppException(message: error.toString());
  }
}
