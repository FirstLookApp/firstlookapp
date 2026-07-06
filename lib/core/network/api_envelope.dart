class ApiEnvelope<T> {
  const ApiEnvelope({
    required this.success,
    required this.data,
    this.message,
    this.errors,
  });

  factory ApiEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJson,
  ) {
    return ApiEnvelope<T>(
      success: json['success'] as bool? ?? false,
      data: fromJson(json['data']),
      message: json['message'] as String?,
      errors: json['errors'],
    );
  }

  final bool success;
  final T data;
  final String? message;
  final Object? errors;
}

class PagedResult<T> {
  const PagedResult({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalCount,
  });

  factory PagedResult.fromJson(
    Object? json,
    T Function(Map<String, dynamic> json) itemFromJson,
  ) {
    final Map<String, dynamic> map =
        json is Map<String, dynamic> ? json : <String, dynamic>{};
    final List<Object?> rawItems = map['items'] is List<Object?>
        ? map['items'] as List<Object?>
        : <Object?>[];

    return PagedResult<T>(
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map<T>(itemFromJson)
          .toList(growable: false),
      pageNumber: map['pageNumber'] as int? ?? 1,
      pageSize: map['pageSize'] as int? ?? rawItems.length,
      totalCount: map['totalCount'] as int? ?? rawItems.length,
    );
  }

  final List<T> items;
  final int pageNumber;
  final int pageSize;
  final int totalCount;
}
