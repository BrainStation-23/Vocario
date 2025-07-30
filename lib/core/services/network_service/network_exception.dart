/// Custom exception for API-related errors
class NetworkException implements Exception {
  final String message;
  final String? originalMessage;
  final int? statusCode;
  
  const NetworkException(this.message, {this.statusCode, this.originalMessage});
  
  @override
  String toString() => 'NetworkException: $message';
}