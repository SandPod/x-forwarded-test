import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'request_echo_builder.dart';

/// Bounces the incoming request back to the caller, so the client can see
/// which forwarding headers (e.g. `X-Forwarded-For`) reached the server.
class EchoEndpoint extends Endpoint {
  /// Returns the forwarding headers and peer address of this call.
  Future<RequestEcho> bounce(Session session) async {
    final request = session.request;
    if (request == null) {
      throw StateError('No HTTP request is associated with this session.');
    }
    return buildRequestEcho(request);
  }
}
