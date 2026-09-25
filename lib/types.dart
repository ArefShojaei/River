import 'dart:async';
import 'dart:io';

import 'package:river/http/request.dart';
import 'package:river/http/response.dart';

/// HTTP route handler
typedef HttpHandler = FutureOr<void> Function(Request req, Response res);

/// CLI command handler
typedef CliHandler = FutureOr<void> Function(
  List<String> args,
  Map<String, String> flags,
);

/// Socket tcp handlers
typedef SocketEventHandler = void Function(dynamic data);

typedef SocketConnectionHandler = void Function(Socket client);

typedef SocketErrorHandler = void Function(Object error);
