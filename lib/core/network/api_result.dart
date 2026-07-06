sealed class ApiResult<T> {
  const ApiResult();

  R when<R>({
    required R Function(T data) success,
    required R Function(String message) failure,
  }) {
    final ApiResult<T> current = this;

    return switch (current) {
      ApiSuccess<T>(:final T data) => success(data),
      ApiFailure<T>(:final String message) => failure(message),
    };
  }
}

class ApiSuccess<T> extends ApiResult<T> {
  const ApiSuccess(this.data);

  final T data;
}

class ApiFailure<T> extends ApiResult<T> {
  const ApiFailure(this.message);

  final String message;
}
