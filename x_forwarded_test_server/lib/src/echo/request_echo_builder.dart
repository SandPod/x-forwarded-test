import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

/// Builds a [RequestEcho] describing what the server saw of [request].
RequestEcho buildRequestEcho(Request request) {
  String? header(String name) => request.headers[name]?.join(', ');

  return RequestEcho(
    xForwardedFor: header('x-forwarded-for'),
    forwarded: header('forwarded'),
    xRealIp: header('x-real-ip'),
    remoteAddress: request.connectionInfo.remote.display,
    headers: {
      for (final entry in request.headers.entries)
        entry.key: entry.value.join(', '),
    },
    timestamp: DateTime.now(),
  );
}
