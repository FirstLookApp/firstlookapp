class ApiErrorResponse {
  const ApiErrorResponse({
    required this.message,
    this.code,
    this.details,
  });

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    return ApiErrorResponse(
      message: json['message'] as String? ??
          json['title'] as String? ??
          'Something went wrong.',
      code: json['status'] as int?,
      details: json['errors'],
    );
  }

  final String message;
  final int? code;
  final Object? details;
}
