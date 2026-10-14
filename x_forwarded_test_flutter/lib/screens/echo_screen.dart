import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:x_forwarded_test_client/x_forwarded_test_client.dart';

import '../app_theme.dart';
import '../client.dart';

/// Other headers proxies use to describe the original request.
const _relatedHeaders = [
  ('Forwarded', 'forwarded'),
  ('X-Real-IP', 'x-real-ip'),
  ('X-Forwarded-Proto', 'x-forwarded-proto'),
  ('X-Forwarded-Host', 'x-forwarded-host'),
];

/// Calls `echo.bounce` on the server and answers one question: did the
/// `X-Forwarded-For` header reach it?
class EchoScreen extends StatefulWidget {
  const EchoScreen({super.key});

  @override
  State<EchoScreen> createState() => _EchoScreenState();
}

class _EchoScreenState extends State<EchoScreen> {
  RequestEcho? _echo;
  String? _errorMessage;
  bool _loading = false;
  int? _roundTripMs;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    if (_loading) return;
    setState(() => _loading = true);
    final stopwatch = Stopwatch()..start();
    try {
      final echo = await client.echo.bounce();
      if (!mounted) return;
      setState(() {
        _echo = echo;
        _errorMessage = null;
        _roundTripMs = stopwatch.elapsedMilliseconds;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _copy(String text, String what) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Copied $what', textAlign: TextAlign.center),
          duration: const Duration(milliseconds: 1200),
        ),
      );
  }

  String get _serverHost {
    final uri = Uri.tryParse(client.host);
    return (uri?.host.isNotEmpty ?? false) ? uri!.host : client.host;
  }

  @override
  Widget build(BuildContext context) {
    final echo = _echo;
    final Widget content;
    if (echo != null) {
      content = _Result(
        key: ValueKey(echo.timestamp),
        echo: echo,
        serverHost: _serverHost,
        roundTripMs: _roundTripMs,
        onCopy: _copy,
      );
    } else if (_errorMessage == null) {
      content = const _Checking();
    } else {
      content = const SizedBox.shrink();
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 56),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TopBar(
                    host: _serverHost,
                    loading: _loading,
                    onCheck: _check,
                  ),
                  const SizedBox(height: 56),
                  if (_errorMessage != null) ...[
                    _ErrorNote(message: _errorMessage!),
                    const SizedBox(height: 32),
                  ],
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    switchInCurve: Curves.easeOutCubic,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0, 0.02),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    layoutBuilder: (current, previous) => Stack(
                      alignment: Alignment.topLeft,
                      children: [...previous, ?current],
                    ),
                    child: content,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Splits an `X-Forwarded-For` value into its addresses, client first.
List<String> _parseHops(String? xForwardedFor) => (xForwardedFor ?? '')
    .split(',')
    .map((hop) => hop.trim())
    .where((hop) => hop.isNotEmpty)
    .toList();

class _TopBar extends StatelessWidget {
  final String host;
  final bool loading;
  final VoidCallback onCheck;

  const _TopBar({
    required this.host,
    required this.loading,
    required this.onCheck,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'X-Forwarded-For check',
                style: Fonts.display(18),
              ),
              Text(
                host,
                overflow: TextOverflow.ellipsis,
                style: Fonts.body(13, color: Palette.muted),
              ),
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: loading ? null : onCheck,
          style:
              FilledButton.styleFrom(
                backgroundColor: Palette.pink,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Palette.pink.withValues(alpha: 0.7),
                disabledForegroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ).copyWith(
                overlayColor: const WidgetStatePropertyAll(Palette.pinkHover),
              ),
          icon: loading
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.refresh_rounded, size: 18),
          label: Text(
            loading ? 'Checking' : 'Check again',
            style: Fonts.body(15, color: Colors.white, weight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _Result extends StatefulWidget {
  final RequestEcho echo;
  final String serverHost;
  final int? roundTripMs;
  final void Function(String text, String what) onCopy;

  const _Result({
    super.key,
    required this.echo,
    required this.serverHost,
    required this.roundTripMs,
    required this.onCopy,
  });

  @override
  State<_Result> createState() => _ResultState();
}

class _ResultState extends State<_Result> {
  bool _showAllHeaders = false;

  @override
  Widget build(BuildContext context) {
    final echo = widget.echo;
    final hops = _parseHops(echo.xForwardedFor);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AnswerPanel(
          echo: echo,
          hops: hops,
          onCopy: () => widget.onCopy(echo.xForwardedFor!, 'X-Forwarded-For'),
        ),
        const SizedBox(height: 48),

        // The path.
        _Section(
          title: 'How the request got here',
          child: _Path(
            hops: hops,
            peer: echo.remoteAddress,
            server: widget.serverHost,
          ),
        ),
        const SizedBox(height: 20),

        // Related headers.
        _Section(
          title: 'Related headers',
          child: Column(
            children: [
              for (final (label, key) in _relatedHeaders)
                _HeaderLine(
                  name: label,
                  value: echo.headers[key],
                  onCopy: widget.onCopy,
                  last: key == _relatedHeaders.last.$2,
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Everything else, on request.
        TextButton.icon(
          onPressed: () => setState(() => _showAllHeaders = !_showAllHeaders),
          style: TextButton.styleFrom(
            foregroundColor: Palette.pink,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: AnimatedRotation(
            turns: _showAllHeaders ? 0.5 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.expand_more_rounded, size: 20),
          ),
          label: Text(
            _showAllHeaders
                ? 'Hide all headers'
                : 'Show all ${echo.headers.length} headers',
            style: Fonts.body(15, weight: FontWeight.w600),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _showAllHeaders
              ? Column(
                  children: [
                    for (final entry
                        in echo.headers.entries.toList()
                          ..sort((a, b) => a.key.compareTo(b.key)))
                      _HeaderLine(
                        name: entry.key,
                        value: entry.value,
                        onCopy: widget.onCopy,
                      ),
                  ],
                )
              : const SizedBox(width: double.infinity),
        ),
        const SizedBox(height: 40),
        Text(
          [
            'Checked at ${_time(echo.timestamp.toLocal())}',
            if (widget.roundTripMs != null)
              '${widget.roundTripMs} ms round trip',
          ].join('  ·  '),
          style: Fonts.body(13, color: Palette.faint),
        ),
      ],
    );
  }

  static String _time(DateTime t) =>
      [t.hour, t.minute, t.second].map((n) => '$n'.padLeft(2, '0')).join(':');
}

/// The answer, on a navy panel like the feature blocks on serverpod.dev.
class _AnswerPanel extends StatelessWidget {
  final RequestEcho echo;
  final List<String> hops;
  final VoidCallback onCopy;

  const _AnswerPanel({
    required this.echo,
    required this.hops,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final received = hops.isNotEmpty;
    final narrow = MediaQuery.sizeOf(context).width < 520;
    final headlineSize = narrow ? 36.0 : 48.0;
    final headline = Fonts.display(headlineSize, color: Colors.white);
    final dim = Colors.white.withValues(alpha: 0.7);

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Palette.navy,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // Soft colour glows in the corners.
          Positioned(
            right: -120,
            top: -140,
            child: _Glow(color: const Color(0xFFEC4899), size: 320),
          ),
          Positioned(
            left: -140,
            bottom: -180,
            child: _Glow(color: const Color(0xFF38BDF8), size: 340),
          ),
          Padding(
            padding: EdgeInsets.all(narrow ? 24 : 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusPill(received: received),
                const SizedBox(height: 20),
                Text.rich(
                  TextSpan(
                    style: headline,
                    children: received
                        ? [
                            const TextSpan(text: 'Your IP is '),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: ShaderMask(
                                blendMode: BlendMode.srcIn,
                                shaderCallback: Palette.highlight.createShader,
                                child: Text('forwarded', style: headline),
                              ),
                            ),
                            const TextSpan(text: '.'),
                          ]
                        : [
                            const TextSpan(text: 'Your IP is '),
                            TextSpan(
                              text: 'not',
                              style: TextStyle(color: Palette.noBright),
                            ),
                            const TextSpan(text: ' forwarded.'),
                          ],
                  ),
                ),
                const SizedBox(height: 14),
                Text.rich(
                  TextSpan(
                    style: Fonts.body(17, color: dim),
                    children: received
                        ? [
                            const TextSpan(
                              text:
                                  'The server received an X-Forwarded-For '
                                  'header, so it knows the request came from ',
                            ),
                            TextSpan(
                              text: hops.first,
                              style: Fonts.code(15.5, color: Colors.white),
                            ),
                            const TextSpan(text: '.'),
                          ]
                        : [
                            const TextSpan(
                              text:
                                  'The server received no X-Forwarded-For '
                                  'header. It only sees the machine that '
                                  'connected to it: ',
                            ),
                            TextSpan(
                              text: echo.remoteAddress,
                              style: Fonts.code(15.5, color: Colors.white),
                            ),
                            const TextSpan(text: '.'),
                          ],
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 14, 8, 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'X-Forwarded-For',
                              style: Fonts.body(
                                13,
                                color: Colors.white.withValues(alpha: 0.6),
                                weight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            received
                                ? SelectableText(
                                    echo.xForwardedFor!,
                                    style: Fonts.code(
                                      19,
                                      color: Colors.white,
                                      weight: FontWeight.w500,
                                    ),
                                  )
                                : Text(
                                    'Not received',
                                    style: Fonts.body(
                                      17,
                                      color: Palette.noBright,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      if (received)
                        IconButton(
                          tooltip: 'Copy',
                          onPressed: onCopy,
                          icon: const Icon(Icons.copy_rounded, size: 18),
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;
  final double size;

  const _Glow({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.35), color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool received;

  const _StatusPill({required this.received});

  @override
  Widget build(BuildContext context) {
    final color = received ? Palette.yesBright : Palette.noBright;
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 14, 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            received ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            received ? 'Header received' : 'Header missing',
            style: Fonts.body(14, color: color, weight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// A titled, soft gray rounded card.
class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      decoration: BoxDecoration(
        color: Palette.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Fonts.display(22)),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _Step {
  final String title;
  final String value;
  final String note;
  final bool missing;

  const _Step(this.title, this.value, this.note, {this.missing = false});
}

/// The request's journey as a simple list of steps, client first.
class _Path extends StatelessWidget {
  final List<String> hops;
  final String peer;
  final String server;

  const _Path({required this.hops, required this.peer, required this.server});

  @override
  Widget build(BuildContext context) {
    final steps = [
      if (hops.isEmpty)
        const _Step(
          'You',
          'Unknown',
          'No proxy reported your address',
          missing: true,
        )
      else ...[
        _Step('You', hops.first, 'First address in X-Forwarded-For'),
        for (final proxy in hops.skip(1))
          _Step('Proxy', proxy, 'Added to X-Forwarded-For'),
      ],
      _Step('Last hop', peer, 'Opened the connection to the server'),
      _Step('Server', server, 'Read the headers you see here'),
    ];

    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 12,
                  child: Column(
                    children: [
                      const SizedBox(height: 7),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: steps[i].missing
                              ? Palette.no
                              : (i == 0 ? Palette.pink : Colors.white),
                          border: Border.all(
                            color: steps[i].missing
                                ? Palette.no
                                : (i == 0 ? Palette.pink : Palette.faint),
                            width: 1.5,
                          ),
                        ),
                      ),
                      if (i < steps.length - 1)
                        Expanded(
                          child: Container(
                            width: 1.5,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: steps[i].missing
                                ? Palette.no.withValues(alpha: 0.3)
                                : Palette.border,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: i < steps.length - 1 ? 22 : 0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 10,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              steps[i].title,
                              style: Fonts.body(15, weight: FontWeight.w600),
                            ),
                            Text(
                              steps[i].value,
                              style: Fonts.code(
                                14,
                                color: steps[i].missing
                                    ? Palette.no
                                    : Palette.ink,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          steps[i].note,
                          style: Fonts.body(13, color: Palette.muted),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// One header as "name   value", tap to copy.
class _HeaderLine extends StatelessWidget {
  final String name;
  final String? value;
  final void Function(String text, String what) onCopy;
  final bool last;

  const _HeaderLine({
    required this.name,
    required this.value,
    required this.onCopy,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    final value = this.value;
    return InkWell(
      onTap: value == null ? null : () => onCopy('$name: $value', name),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        decoration: BoxDecoration(
          border: last
              ? null
              : const Border(bottom: BorderSide(color: Palette.border)),
        ),
        child: Wrap(
          spacing: 16,
          runSpacing: 2,
          children: [
            SizedBox(
              width: 180,
              child: Text(name, style: Fonts.body(14, color: Palette.muted)),
            ),
            Text(
              value ?? 'Not received',
              style: value == null
                  ? Fonts.body(14, color: Palette.faint)
                  : Fonts.code(13.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _Checking extends StatelessWidget {
  const _Checking();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Palette.muted,
            ),
          ),
          const SizedBox(width: 14),
          Text('Checking the server…', style: Fonts.display(32)),
        ],
      ),
    );
  }
}

class _ErrorNote extends StatelessWidget {
  final String message;

  const _ErrorNote({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Palette.noSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Couldn’t reach the server',
            style: Fonts.body(16, color: Palette.no, weight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          SelectableText(message, style: Fonts.code(12.5, color: Palette.ink)),
        ],
      ),
    );
  }
}
