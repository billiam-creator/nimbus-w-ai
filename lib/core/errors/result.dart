import 'package:nimbus/core/errors/exceptions.dart';

sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final AppException exception;
  const Failure(this.exception);
}

extension ResultExtension<T> on Result<T> {
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => isSuccess ? (this as Success<T>).data : null;
  AppException? get errorOrNull =>
      isFailure ? (this as Failure<T>).exception : null;

  R when<R>({
    required R Function(T data) success,
    required R Function(AppException error) failure,
  }) {
    return switch (this) {
      Success<T> s => success(s.data),
      Failure<T> f => failure(f.exception),
    };
  }
}
