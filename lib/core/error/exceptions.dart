class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'A server error occurred.']);

  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'A local storage error occurred.']);

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'No internet connection available.']);

  @override
  String toString() => 'NetworkException: $message';
}
