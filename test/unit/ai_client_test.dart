import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leaf_flutter/core/errors.dart';
import 'package:leaf_flutter/services/pipeline/ai_client.dart';

void main() {
  test('retries after server failure and succeeds', () async {
    final adapter = _QueueAdapter(<ResponseBody>[
      ResponseBody.fromString('{"error":"busy"}', 500),
      ResponseBody.fromString(
        jsonEncode(<String, Object?>{
          'candidates': <Object?>[
            <String, Object?>{
              'content': <String, Object?>{
                'parts': <Object?>[
                  <String, Object?>{'text': 'cleaned text'},
                ],
              },
            },
          ],
        }),
        200,
        headers: <String, List<String>>{
          Headers.contentTypeHeader: <String>['application/json'],
        },
      ),
    ]);
    final dio = Dio()..httpClientAdapter = adapter;
    final client = AiClient(dio: dio, delay: (_) async {});

    final result = await client.cleanChunk(
      pageNumber: 1,
      prompt: 'prompt',
      apiKey: 'key',
    );

    expect(result, 'cleaned text');
    expect(adapter.calls, 2);
  });

  test('returns empty string on bad request', () async {
    final dio = Dio()
      ..httpClientAdapter = _QueueAdapter(<ResponseBody>[
        ResponseBody.fromString('{"error":"bad request"}', 400),
      ]);
    final client = AiClient(dio: dio, delay: (_) async {});

    final result = await client.cleanChunk(
      pageNumber: 12,
      prompt: 'prompt',
      apiKey: 'key',
    );

    expect(result, '');
  });

  test('throws when api key is missing', () async {
    final client = AiClient(dio: Dio(), delay: (_) async {});

    expect(
      () => client.cleanChunk(pageNumber: 1, prompt: 'prompt', apiKey: ''),
      throwsA(isA<SettingsException>()),
    );
  });
}

class _QueueAdapter implements HttpClientAdapter {
  _QueueAdapter(this._responses);

  final List<ResponseBody> _responses;
  int calls = 0;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls += 1;
    if (_responses.isEmpty) {
      throw DioException(
        requestOptions: options,
        response: Response<dynamic>(requestOptions: options, statusCode: 500),
      );
    }
    return _responses.removeAt(0);
  }
}
