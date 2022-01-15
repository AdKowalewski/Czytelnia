// do testowania z emulatorem
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';

String baseURL = "http://10.0.2.2:8000";

// do replit
//String baseURL = "https://Czytelniabackend.wojciechmetelsk.repl.co";

DioCacheManager dioCacheManager = DioCacheManager(CacheConfig(baseUrl: baseURL));
Options cacheOptions = buildCacheOptions(
  const Duration(days: 7), 
  forceRefresh: true,
  //options: Options(headers: {})
);
final Dio dio = Dio(
  BaseOptions(
    baseUrl: baseURL,
    connectTimeout: 5000,
    receiveTimeout: 3000,
  ),
)..interceptors.add(dioCacheManager.interceptor);
