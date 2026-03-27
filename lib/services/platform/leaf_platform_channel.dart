import 'package:flutter/services.dart';

import '../../core/constants.dart';

class LeafPlatformChannel {
  LeafPlatformChannel({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(AppConstants.nativeChannel);

  final MethodChannel _channel;

  Future<void> initTesseract() async {
    await _channel.invokeMethod<void>('initTesseract');
  }

  Future<void> destroyTesseract() async {
    await _channel.invokeMethod<void>('destroyTesseract');
  }

  Future<int> getPageCount(String pdfPath) async {
    final Map<Object?, Object?>? response = await _channel
        .invokeMapMethod<Object?, Object?>('getPageCount', <String, Object?>{
          'pdfPath': pdfPath,
        });
    return (response?['count'] as int?) ?? 0;
  }

  Future<String> renderPage({
    required String pdfPath,
    required int pageNum,
    required int dpi,
  }) async {
    final Map<Object?, Object?>? response = await _channel
        .invokeMapMethod<Object?, Object?>('renderPage', <String, Object?>{
          'pdfPath': pdfPath,
          'pageNum': pageNum,
          'dpi': dpi,
        });
    return (response?['imagePath'] as String?) ?? '';
  }

  Future<String> recognizeWithTesseract({
    required String imagePath,
    required String tessCode,
  }) async {
    final Map<Object?, Object?>? response = await _channel
        .invokeMapMethod<Object?, Object?>(
          'recognizeWithTesseract',
          <String, Object?>{'imagePath': imagePath, 'tessCode': tessCode},
        );
    return (response?['text'] as String?) ?? '';
  }

  Future<String> recognizeWithMlKit({
    required String imagePath,
    required String script,
  }) async {
    final Map<Object?, Object?>? response = await _channel
        .invokeMapMethod<Object?, Object?>(
          'recognizeWithMlKit',
          <String, Object?>{'imagePath': imagePath, 'script': script},
        );
    return (response?['text'] as String?) ?? '';
  }

  Future<String> ensureMlKitPackage(String script) async {
    final Map<Object?, Object?>? response = await _channel
        .invokeMapMethod<Object?, Object?>(
          'ensureMlKitPackage',
          <String, Object?>{'script': script},
        );
    return (response?['status'] as String?) ?? 'failed';
  }

  Future<bool> ensureTessData(String tessCode) async {
    final Map<Object?, Object?>? response = await _channel
        .invokeMapMethod<Object?, Object?>('ensureTessData', <String, Object?>{
          'tessCode': tessCode,
        });
    return (response?['alreadyPresent'] as bool?) ?? false;
  }
}
