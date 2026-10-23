import 'package:rick_and_morty_catalog/core/error/app_failure.dart';

abstract final class FailureMessage {
  static String forError(Object error) => error is AppFailure
      ? switch (error.kind) {
          FailureKind.timeout =>
            'Сервер отвечает слишком долго. Попробуйте ещё раз.',
          FailureKind.connection =>
            'Не удалось подключиться. Проверьте интернет-соединение.',
          FailureKind.rateLimit =>
            'Слишком много запросов. Подождите немного и повторите.',
          FailureKind.server =>
            'Сервис временно недоступен. Попробуйте ещё раз позже.',
          FailureKind.invalidData => 'Сервис вернул некорректные данные.',
          FailureKind.unexpected =>
            'Не удалось получить данные. Попробуйте ещё раз.',
        }
      : 'Не удалось загрузить персонажей. Попробуйте ещё раз.';
}
