import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

class StubAdapter implements HttpClientAdapter {
  StubAdapter({this.code = 200, this.body, this.failure, this.recoverAfter});

  final int? recoverAfter;
  int calls = 0;

  final int code;
  final Object? body;
  final DioExceptionType? failure;
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    calls++;
    if (failure != null) {
      throw DioException(requestOptions: options, type: failure!);
    }
    return ResponseBody.fromString(
      jsonEncode(body),
      recoverAfter != null && calls > recoverAfter! ? 200 : code,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
