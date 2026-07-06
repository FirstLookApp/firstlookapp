class AppException implements Exception {
  const AppException({
    required this.message,
    this.code,
    this.identifier,
  });

  final String message;
  final int? code;
  final String? identifier;

  @override
  String toString() => 'AppException(code: $code, message: $message)';
}
