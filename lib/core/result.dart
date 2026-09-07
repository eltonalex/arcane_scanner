/// Resultado tipado para operações que podem falhar (Scryfall, IA, OCR, DB).
/// Evita exceções vazando para a UI e força tratamento explícito.
sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok<T>;
  const factory Result.err(AppFailure failure) = Err<T>;

  bool get isOk => this is Ok<T>;

  R when<R>({
    required R Function(T value) ok,
    required R Function(AppFailure failure) err,
  }) =>
      switch (this) {
        Ok<T>(:final value) => ok(value),
        Err<T>(:final failure) => err(failure),
      };

  Result<R> map<R>(R Function(T value) transform) => switch (this) {
        Ok<T>(:final value) => Result.ok(transform(value)),
        Err<T>(:final failure) => Result.err(failure),
      };
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final AppFailure failure;
}

/// Falha com mensagem amigável em PT-BR (nunca stack trace na UI).
class AppFailure {
  const AppFailure(this.message, {this.cause});

  final String message;
  final Object? cause; // preservado para logs, nunca exibido

  @override
  String toString() => 'AppFailure($message)';
}
