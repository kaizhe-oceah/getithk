// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import '../../imports.dart';

class HttpLoggerCustom extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final buffer = StringBuffer();

    if (options.data is FormData) {
      final formData = options.data as FormData;
      buffer.writeln("║ Body Fields:");
      for (var field in formData.fields) {
        buffer.writeln(" • ${field.key}: ${field.value}");
      }
      buffer.writeln("║ Body Files:");
      for (var file in formData.files) {
        buffer.writeln(" • ${file.key}: ${file.value.filename}");
      }
    } else {
      buffer.writeln("║ Body: ${options.data}");
    }

    printLog(
        "╔╣ Request ║ ${options.method}\n║ ${options.uri}\n║ Token: ${options.headers['Authorization']}\n${buffer.toString()}╚═══════════════════════════════════════════════════════════╝");
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    printLog(
        "╔╣ Response ║ Status: ${response.statusCode} ${response.statusMessage}\n║ ${response.requestOptions.uri}\n║ \nData: ${jsonEncode(response.data)}\n╚═════════════════════════════ END ═════════════════════════════╝");
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    printLog(
        "╔╣ Error\n║ Message: ${err.message}\n╚═══════════════════════════════════════════════════════════╝");
    super.onError(err, handler);
  }
}

// ╚
// ║
// ╟
// ╔╣
// ╝
// ═
