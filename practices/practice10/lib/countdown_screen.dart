import 'dart:async';

import 'package:flutter/material.dart';

import 'api/countdown.dart';

class CountdownScreen extends StatefulWidget {
  const CountdownScreen({super.key});

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  bool _useListen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Countdown')),
      body: Column(
        children: [
          const SizedBox(height: 16),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('StreamBuilder')),
              ButtonSegment(value: true, label: Text('listen()')),
            ],
            selected: {_useListen},
            onSelectionChanged: (selection) {
              setState(() => _useListen = selection.single);
            },
          ),
          Expanded(
            child: Center(
              child: _useListen
                  ? const _ListenCountdown()
                  : const _StreamBuilderCountdown(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreamBuilderCountdown extends StatefulWidget {
  const _StreamBuilderCountdown();

  @override
  State<_StreamBuilderCountdown> createState() =>
      _StreamBuilderCountdownState();
}

class _StreamBuilderCountdownState extends State<_StreamBuilderCountdown> {
  late final Stream<int> _stream = countdown(10);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _stream,
      builder: (context, snapshot) {
        return Text(
          '${snapshot.data ?? 10}',
          style: Theme.of(context).textTheme.displayLarge,
        );
      },
    );
  }
}

class _ListenCountdown extends StatefulWidget {
  const _ListenCountdown();

  @override
  State<_ListenCountdown> createState() => _ListenCountdownState();
}

class _ListenCountdownState extends State<_ListenCountdown> {
  int _left = 10;
  late final StreamSubscription<int> _subscription;

  @override
  void initState() {
    super.initState();

    _subscription = countdown(10).listen((seconds) {
      setState(() => _left = seconds);
    });
  }

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text('$_left', style: Theme.of(context).textTheme.displayLarge);
  }
}
