import 'dart:convert';

import 'package:serverpod/serverpod.dart';

import 'request_echo_builder.dart';

/// Plain HTTP version of `EchoEndpoint.bounce`, returning JSON so it can be
/// tested with curl or a browser, e.g. `curl https://<host>/echo`.
class EchoRoute extends Route {
  @override
  Future<Result> handleCall(Session session, Request request) async {
    final echo = buildRequestEcho(request);
    return Response.ok(
      body: Body.fromString(
        const JsonEncoder.withIndent('  ').convert(echo.toJson()),
        mimeType: MimeType.json,
      ),
    );
  }
}
