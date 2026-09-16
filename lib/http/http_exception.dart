/// Base exception for controlled HTTP errors.
class HttpException implements Exception {
  final int statusCode;
  final String message;
  final dynamic data;

  const HttpException({
    required this.statusCode,
    required this.message,
    this.data,
  });

  @override
  String toString() => 'HttpException($statusCode): $message';
}

// ─────────────────────────────────────────────
// Common ready-to-use exceptions
// ─────────────────────────────────────────────

class BadRequestException extends HttpException {
  const BadRequestException([String message = 'Bad Request', dynamic data])
      : super(statusCode: 400, message: message, data: data);
}

class UnauthorizedException extends HttpException {
  const UnauthorizedException([String message = 'Unauthorized', dynamic data])
      : super(statusCode: 401, message: message, data: data);
}

class ForbiddenException extends HttpException {
  const ForbiddenException([String message = 'Forbidden', dynamic data])
      : super(statusCode: 403, message: message, data: data);
}

class NotFoundException extends HttpException {
  const NotFoundException([String message = 'Not Found', dynamic data])
      : super(statusCode: 404, message: message, data: data);
}

class ConflictException extends HttpException {
  const ConflictException([String message = 'Conflict', dynamic data])
      : super(statusCode: 409, message: message, data: data);
}

class UnprocessableEntityException extends HttpException {
  const UnprocessableEntityException(
      [String message = 'Unprocessable Entity', dynamic data])
      : super(statusCode: 422, message: message, data: data);
}

class TooManyRequestsException extends HttpException {
  const TooManyRequestsException(
      [String message = 'Too Many Requests', dynamic data])
      : super(statusCode: 429, message: message, data: data);
}

class InternalServerException extends HttpException {
  const InternalServerException(
      [String message = 'Internal Server Error', dynamic data])
      : super(statusCode: 500, message: message, data: data);
}
