import 'dart:async';
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutx_core/core/debug_print.dart';

import '../common/models/base_response.dart';
import '../common/models/network_failure.dart';
import '../common/models/network_success.dart';
import '../constants/api_constants.dart';
import '../services/api_cache_service.dart';
import '../services/auth_storage_service.dart';
import '../services/connectivity_service.dart';

class GraphQLClientService {
  late final GraphQLClient _client;
  late final ConnectivityService _connectivityService;
  late final ApiCacheService _cacheService;
  final AuthStorageService _authStorageService = AuthStorageService();

  bool _isRefreshing = false;
  final List<Completer<void>> _pendingRequests = [];
  final Completer<void> _initCompleter = Completer<void>();

  // Singleton instance
  static final GraphQLClientService _instance =
      GraphQLClientService._internal();
  factory GraphQLClientService() => _instance;

  bool _isInitialized = false;

  GraphQLClientService._internal() {
    _init();
  }

  Future<void> _init() async {
    if (!_isInitialized) {
      await _initialize();
      _isInitialized = true;
    }
    if (!_initCompleter.isCompleted) {
      _initCompleter.complete();
    }
  }

  Future<void> _initialize() async {
    try {
      _connectivityService = ConnectivityService.instance;
      await _connectivityService.initialize();
    } catch (e) {
      if (kDebugMode) DPrint.log("Using fallback connectivity: $e");
    }

    _cacheService = ApiCacheService();
    await _cacheService.initialize();

    final HttpLink httpLink = HttpLink(ApiConstants.graphqlEndpoint);

    final AuthLink authLink = AuthLink(
      getToken: () async {
        final token = await _authStorageService.getAccessToken();
        return token != null ? 'Bearer $token' : null;
      },
    );

    final Link link = authLink.concat(httpLink);

    _client = GraphQLClient(
      link: link,
      cache:
          GraphQLCache(), // Basic memory cache, using ApiCacheService for persistence
      defaultPolicies: DefaultPolicies(
        query: Policies(fetch: FetchPolicy.networkOnly),
        mutate: Policies(fetch: FetchPolicy.networkOnly),
      ),
    );
  }

  Future<Either<NetworkFailure, void>> _checkConnectivity() async {
    if (!_connectivityService.isConnected) {
      try {
        await _connectivityService.waitForConnection(
          timeout: const Duration(seconds: 2),
        );
      } catch (e) {
        return const Left(NoInternetFailure());
      }
    }
    return const Right(null);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _authStorageService.getRefreshToken();
      DPrint.info("GraphQL Refreshing ...");

      if (refreshToken == null) return false;

      // Use Dio for token refresh since Auth endpoint might still be REST
      // Or if it is GraphQL, we could use graphQL mutation here.
      // Assuming refresh logic is exactly same as ApiClient.
      final dio = Dio();
      final response = await dio.post(
        ApiConstants.auth.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      final baseResponse = BaseResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json,
      );

      DPrint.log("🔄 GraphQL Refresh Token -> ${response.statusCode}");

      if (baseResponse.success && baseResponse.data != null) {
        final newAccessToken = baseResponse.data!['accessToken'] as String;
        final newRefreshToken = baseResponse.data!['refreshToken'] as String;

        await _authStorageService.storeAccessToken(accessToken: newAccessToken);
        await _authStorageService.storeRefreshToken(
          refreshToken: newRefreshToken,
        );

        return true;
      }

      await _logout();
      return false;
    } on DioException catch (e) {
      DPrint.log(
        "GraphQL Refresh token error: status=${e.response?.statusCode ?? 'none'} type=${e.type}",
      );
      await _logout();
      return false;
    } catch (e) {
      DPrint.log("GraphQL Refresh token error: ${e.runtimeType}");
      await _logout();
      return false;
    }
  }

  Future<void> _logout() async {
    try {
      await _authStorageService.clearAuthData();
      await _cacheService.clearAllCache();
      await Future.delayed(Duration.zero);
      // Get.offAll(() => LoginScreen(), transition: Transition.leftToRight);
    } catch (e) {
      DPrint.error("Logout error: $e");
    }
  }

  NetworkFailure _handleGraphQLError(QueryResult result) {
    if (result.hasException) {
      final exception = result.exception!;

      // Check HTTP errors (like 401)
      if (exception.linkException != null) {
        if (exception.linkException is ServerException) {
          final serverException = exception.linkException as ServerException;
          final originalResponse = serverException.parsedResponse?.response;
          if (originalResponse != null && originalResponse['status'] == 401) {
            return const UnauthorizedFailure(
              message: "Unauthorized",
              statusCode: 401,
            );
          }
        }
      }

      // Check GraphQL errors
      if (exception.graphqlErrors.isNotEmpty) {
        final error = exception.graphqlErrors.first;
        final extensions = error.extensions ?? {};
        final code = extensions['code']?.toString() ?? '';

        if (code == 'UNAUTHENTICATED' ||
            error.message.toLowerCase().contains("unauthorized")) {
          return const UnauthorizedFailure(
            message: "Unauthenticated",
            statusCode: 401,
          );
        }

        return ServerFailure(message: error.message, statusCode: 400);
      }

      return ServerFailure(message: exception.toString(), statusCode: 500);
    }
    return const UnknownFailure(
      message: "Unknown error occurred",
      statusCode: 0,
    );
  }

  /// Base Request wrapper to handle Execution and Refresh Logic
  Future<Either<NetworkFailure, QueryResult>> _executeOperation(
    Future<QueryResult> Function() operation,
  ) async {
    await _initCompleter.future;

    if (_isRefreshing) {
      final completer = Completer<void>();
      _pendingRequests.add(completer);
      await completer.future;
    }

    QueryResult result = await operation();

    // Check for 401 Unauthenticated
    final failure = _handleGraphQLError(result);
    if (failure is UnauthorizedFailure) {
      if (!_isRefreshing) {
        _isRefreshing = true;
        try {
          if (await _refreshToken()) {
            // Retry operation
            result = await operation();
          }
        } finally {
          _isRefreshing = false;
          for (var completer in _pendingRequests) {
            completer.complete();
          }
          _pendingRequests.clear();
        }
      }
    }

    if (result.hasException) {
      return Left(_handleGraphQLError(result));
    }

    return Right(result);
  }

  /// QUERY method (equivalent to GET)
  Future<Either<NetworkFailure, NetworkSuccess<T>>> query<T>({
    required String document,
    String? operationName,
    Map<String, dynamic> variables = const {},
    required T Function(dynamic) fromJsonT,
    Duration? cacheDuration,
    String? cacheKey,
  }) async {
    final connectivityCheck = await _checkConnectivity();
    final effectiveCacheKey =
        cacheKey ??
        document.hashCode.toString() + variables.toString().hashCode.toString();
    final bool cache = cacheDuration != null;

    if (connectivityCheck.isLeft()) {
      if (cache) {
        final cachedData = await _cacheService.getCachedData(effectiveCacheKey);
        if (cachedData != null) {
          DPrint.info(
            'Serving cached graphql data for $effectiveCacheKey (offline)',
          );
          return Right(
            NetworkSuccess<T>(
              data: fromJsonT(cachedData),
              message: 'Served from cache (offline)',
              statusCode: 200,
              isFromCache: true,
            ),
          );
        }
      }
      return const Left(NoInternetFailure());
    }

    final QueryOptions options = QueryOptions(
      document: gql(document),
      variables: variables,
      operationName: operationName,
      fetchPolicy: FetchPolicy.networkOnly,
    );

    DPrint.log(
      "🟩 GraphQL Query -> operation=${operationName ?? 'anonymous'} variableKeys=${variables.keys.toList()}",
    );

    final resultEither = await _executeOperation(() => _client.query(options));

    return resultEither.fold((failure) => Left(failure), (result) async {
      DPrint.log(
        "☁️  GraphQL Query Success -> operation=${operationName ?? 'anonymous'} ${_graphqlPayloadSummary(result.data)}",
      );

      // Parse custom base response if your backend still wraps data in success/message wrapper
      // If your GraphQL backend just returns data, we can directly parse the root query object.
      // Assuming we parse direct data:

      final successResult = NetworkSuccess<T>(
        data: fromJsonT(result.data),
        message: 'Success',
        statusCode: 200,
      );

      if (cache) {
        await _cacheService.cacheData(
          effectiveCacheKey,
          data: result.data,
          cacheDuration: cacheDuration,
        );
      }

      return Right(successResult);
    });
  }

  /// MUTATION method (equivalent to POST/PUT/DELETE)
  Future<Either<NetworkFailure, NetworkSuccess<T>>> mutate<T>({
    required String document,
    String? operationName,
    Map<String, dynamic> variables = const {},
    required T Function(dynamic) fromJsonT,
    List<String>? invalidatePaths,
  }) async {
    final connectivityCheck = await _checkConnectivity();
    if (connectivityCheck.isLeft()) {
      return const Left(NoInternetFailure());
    }

    final MutationOptions options = MutationOptions(
      document: gql(document),
      variables: variables,
      operationName: operationName,
      fetchPolicy: FetchPolicy.networkOnly,
    );

    DPrint.log(
      "🟦 GraphQL Mutation -> operation=${operationName ?? 'anonymous'} variableKeys=${variables.keys.toList()}",
    );

    final resultEither = await _executeOperation(() => _client.mutate(options));

    return resultEither.fold((failure) => Left(failure), (result) async {
      DPrint.log(
        "☁️  GraphQL Mutation Success -> operation=${operationName ?? 'anonymous'} ${_graphqlPayloadSummary(result.data)}",
      );

      if (invalidatePaths != null) {
        for (final path in invalidatePaths) {
          await _cacheService.clearCache(path);
        }
      }

      return Right(
        NetworkSuccess<T>(
          data: fromJsonT(result.data),
          message: 'Success',
          statusCode: 200,
        ),
      );
    });
  }

  /// WATCH QUERY Stream method (equivalent to getStream)
  Stream<Either<NetworkFailure, NetworkSuccess<T>>> watchQuery<T>({
    required String document,
    String? operationName,
    Map<String, dynamic> variables = const {},
    required T Function(dynamic) fromJsonT,
    Duration? cacheDuration,
    bool forceEmitRemote = false,
    String? cacheKey,
  }) async* {
    final bool cache = cacheDuration != null;
    final effectiveCacheKey =
        cacheKey ??
        document.hashCode.toString() + variables.toString().hashCode.toString();
    dynamic cachedRawData;

    // 1. Emit cached data if available
    if (cache) {
      cachedRawData = await _cacheService.getCachedData(effectiveCacheKey);

      if (cachedRawData != null) {
        DPrint.info(
          'Serving cached GraphQL data stream for $effectiveCacheKey',
        );
        yield Right(
          NetworkSuccess<T>(
            data: fromJsonT(cachedRawData),
            message: 'Served from cache',
            statusCode: 200,
            isFromCache: true,
          ),
        );
      }
    }

    // 2. Perform network request
    final result = await query<T>(
      document: document,
      operationName: operationName,
      variables: variables,
      fromJsonT: fromJsonT,
      cacheDuration: cacheDuration,
      cacheKey: effectiveCacheKey,
    );

    if (result.isRight()) {
      final success = result.getOrElse(
        () => throw Exception("Should not happen"),
      );
      final remoteRawData = await _cacheService.getCachedData(
        effectiveCacheKey,
      );

      bool isUpdated = true;
      if (cachedRawData != null && remoteRawData != null) {
        isUpdated = _isDataUpdated(cachedRawData, remoteRawData);
      }

      if (isUpdated || cachedRawData == null || forceEmitRemote) {
        DPrint.info(
          'Serving remote GraphQL data stream for $effectiveCacheKey',
        );
        yield Right(success);
      } else {
        DPrint.info(
          'Remote GraphQL data same as cache for $effectiveCacheKey, skipping emission',
        );
      }
    } else {
      yield result;
    }
  }

  bool _isDataUpdated(dynamic oldData, dynamic newData) {
    try {
      if (oldData is Map && newData is Map) {
        final oldUpdate = oldData['updatedAt'];
        final newUpdate = newData['updatedAt'];
        if (oldUpdate != null && newUpdate != null) {
          return oldUpdate.toString() != newUpdate.toString();
        }
      }
      return jsonEncode(oldData) != jsonEncode(newData);
    } catch (e) {
      return true;
    }
  }
}

String _graphqlPayloadSummary(dynamic data) {
  if (data == null) return 'data=null';
  if (data is Map) {
    return 'dataKeys=${data.keys.map((key) => key.toString()).toList()}';
  }
  if (data is Iterable) return 'dataLength=${data.length}';
  return 'dataType=${data.runtimeType}';
}
