/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _is;
import 'package:x_forwarded_test_server/src/generated/protocol.dart'
    as _ifl8t4hl;

/// What the server saw of an incoming request, as bounced back to the caller.
abstract class RequestEcho
    implements _is.SerializableModel, _is.ProtocolSerialization {
  RequestEcho._({
    this.xForwardedFor,
    this.forwarded,
    this.xRealIp,
    required this.remoteAddress,
    required this.headers,
    required this.timestamp,
  });

  factory RequestEcho({
    String? xForwardedFor,
    String? forwarded,
    String? xRealIp,
    required String remoteAddress,
    required Map<String, String> headers,
    required DateTime timestamp,
  }) = _RequestEchoImpl;

  factory RequestEcho.fromJson(Map<String, dynamic> jsonSerialization) {
    return RequestEcho(
      xForwardedFor: jsonSerialization['xForwardedFor'] as String?,
      forwarded: jsonSerialization['forwarded'] as String?,
      xRealIp: jsonSerialization['xRealIp'] as String?,
      remoteAddress: jsonSerialization['remoteAddress'] as String,
      headers: _ifl8t4hl.Protocol().deserialize<Map<String, String>>(
        jsonSerialization['headers'],
      ),
      timestamp: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['timestamp'],
      ),
    );
  }

  /// Raw value of the `X-Forwarded-For` header, or null if it was absent.
  String? xForwardedFor;

  /// Raw value of the `Forwarded` header (RFC 7239), or null if it was absent.
  String? forwarded;

  /// Raw value of the `X-Real-IP` header, or null if it was absent.
  String? xRealIp;

  /// The peer address of the TCP connection, as seen by the server.
  String remoteAddress;

  /// All request headers, with multiple values joined by ", ".
  Map<String, String> headers;

  /// When the server handled the request.
  DateTime timestamp;

  /// Returns a shallow copy of this [RequestEcho]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RequestEcho copyWith({
    String? xForwardedFor,
    String? forwarded,
    String? xRealIp,
    String? remoteAddress,
    Map<String, String>? headers,
    DateTime? timestamp,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RequestEcho',
      if (xForwardedFor != null) 'xForwardedFor': xForwardedFor,
      if (forwarded != null) 'forwarded': forwarded,
      if (xRealIp != null) 'xRealIp': xRealIp,
      'remoteAddress': remoteAddress,
      'headers': headers.toJson(),
      'timestamp': timestamp.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RequestEcho',
      if (xForwardedFor != null) 'xForwardedFor': xForwardedFor,
      if (forwarded != null) 'forwarded': forwarded,
      if (xRealIp != null) 'xRealIp': xRealIp,
      'remoteAddress': remoteAddress,
      'headers': headers.toJson(),
      'timestamp': timestamp.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RequestEchoImpl extends RequestEcho {
  _RequestEchoImpl({
    String? xForwardedFor,
    String? forwarded,
    String? xRealIp,
    required String remoteAddress,
    required Map<String, String> headers,
    required DateTime timestamp,
  }) : super._(
         xForwardedFor: xForwardedFor,
         forwarded: forwarded,
         xRealIp: xRealIp,
         remoteAddress: remoteAddress,
         headers: headers,
         timestamp: timestamp,
       );

  /// Returns a shallow copy of this [RequestEcho]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RequestEcho copyWith({
    Object? xForwardedFor = _Undefined,
    Object? forwarded = _Undefined,
    Object? xRealIp = _Undefined,
    String? remoteAddress,
    Map<String, String>? headers,
    DateTime? timestamp,
  }) {
    return RequestEcho(
      xForwardedFor: xForwardedFor is String?
          ? xForwardedFor
          : this.xForwardedFor,
      forwarded: forwarded is String? ? forwarded : this.forwarded,
      xRealIp: xRealIp is String? ? xRealIp : this.xRealIp,
      remoteAddress: remoteAddress ?? this.remoteAddress,
      headers:
          headers ??
          this.headers.map(
            (
              key0,
              value0,
            ) => MapEntry(
              key0,
              value0,
            ),
          ),
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
