import 'package:dio/dio.dart';
import 'package:citytrace/common/values/server.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient.internal();
  factory ApiClient() => _instance;

  late Dio dio;

  ApiClient.internal() {
    BaseOptions options = BaseOptions(
      baseUrl: ServerConfig.BASE_URL,
      connectTimeout: const Duration(
        milliseconds: ServerConfig.CONNECT_TIMEOUT,
      ),
      receiveTimeout: const Duration(
        milliseconds: ServerConfig.RECEIVE_TIMEOUT,
      ),
      headers: {},
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    );

    dio = Dio(options);

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // TODO: 登录状态下需在此添加 JWT Token
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // TODO：按API文档的状态码处理
          final data = response.data;
          final int code = data["code"];
          final String msg = data["msg"];

          if (code == 0) {
            // 请求成功，返回响应
            return handler.next(response);
          } else {
            // TODO：处理错误
            // _handleError(code, msg);
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                error: msg,
                type: DioExceptionType.badResponse,
              ),
            );
          }
        },
        onError: (DioException e, handler) {
          // _handleError(code, msg);
          return handler.next(e);
        },
      ),
    );
  }
}
