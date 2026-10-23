# Rick & Morty Catalog

Flutter-приложение для просмотра и поиска персонажей Rick and Morty.

## Возможности

- Поиск по имени и фильтрация по статусу.
- Постраничная загрузка при прокрутке.
- Обновление свайпом вниз.
- Детальный экран с происхождением, локацией и сведениями о персонаже.
- Сохранение поиска и позиции списка при возврате.
- Скелетоны загрузки, пустое состояние и повтор неудачного запроса.
- Адаптивная сетка и поддержка увеличенного системного текста.

## Запуск

Flutter 3.35.4, Dart 3.9.2. Для iOS требуется macOS, Xcode и iOS 15.0 или выше.

```sh
flutter pub get
flutter run
```

Запуск в браузере:

```sh
flutter run -d chrome
```

Для физического iPhone выберите свою signing team в Xcode. Для Android требуется Android SDK и JDK.

## Структура

```text
lib/
  app/                      # конфигурация, DI и запуск
  core/                     # сеть, отмена запросов, ошибки и тема
  features/characters/
    domain/                 # сущности, контракты, use cases
    data/                   # API-сервис, DTO, мапперы и репозиторий
    presentation/           # каталог, детали и общие компоненты
test/
  architecture/             # границы слоёв
  core/
  features/characters/
  support/
```

Управление состоянием — Cubit, HTTP-клиент — Dio. Зависимости передаются через конструкторы и собираются в `AppDependencies`.

Подробнее: [архитектура](docs/architecture.md).

## Проверки

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test --no-pub
flutter build web --no-pub --no-web-resources-cdn
```

Эти проверки также выполняются в GitHub Actions. Тесты используют подменные ответы и не требуют подключения к API.

## API

Данные и изображения: [Rick and Morty API](https://rickandmortyapi.com/documentation). Ключ не требуется.

Адрес можно переопределить через `--dart-define=API_BASE_URL=...`. Состояние списка хранится в памяти; постоянного offline-кеша нет.
