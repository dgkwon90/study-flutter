import 'dart:async';
import 'dart:math' as math;

import 'package:simple_timer/timer_clock_lcd.dart';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:flutter/services.dart';

void main() {
  runApp(const TimerApp());
}

class TimerApp extends StatelessWidget {
  const TimerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Timer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TimerPage(
        title: 'Simple Timer',
      ),
    );
  }
}

class Ticker {
  const Ticker();
  Stream<int> tick({required int ticks}) {
    return Stream.periodic(const Duration(seconds: 1), (x) => ticks - x)
        .take(ticks);
  }
}

class TimerPage extends StatefulWidget {
  const TimerPage({super.key, required this.title});
  final String title;
  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  late StreamSubscription<int> _subscription;
  late AudioPlayer _player;
  bool _isRunning = false;
  int _setMinute = 1;
  int _setSecond = 0;
  int _minute = 1;
  int _second = 0;

  void _startTimer(int minute, int second) {
    if (_minute == 0 && _second == 0) {
      debugPrint("minute, second Zero!!!");
      _subscription.cancel();
      _audioStop();
      setState(() {
        _minute = _setMinute;
        _second = _setSecond;
      });
    }

    var timerSecond = minute * 60 + second;
    var currentSecond = _minute * 60 + _second;

    if (timerSecond == currentSecond) {
      debugPrint("timer start!!!");
      _isRunning = true;
      _subscription = const Ticker().tick(ticks: timerSecond).listen((value) {
        setState(() {
          if (_second == 0) {
            _second = 59;
            _minute--;
          } else {
            _second--;
          }
        });
      });
    } else {
      debugPrint("ignore start!!!");
    }

    _subscription.onDone(() {
      debugPrint("timer done!!!");
      _audioPlay();
    });
  }

  void _stopTimer() {
    if (_isRunning) {
      debugPrint("timer stop!!!");
      _subscription.cancel();
      _audioStop();
      setState(() {
        _minute = _setMinute;
        _second = _setSecond;
      });
      _isRunning = false;
    } else {
      debugPrint("ignore stop!!!");
    }
  }

  void _pauseTimer() {
    if (_isRunning && !_subscription.isPaused) {
      _subscription.pause();
      debugPrint("timer pause!!!");
    } else {
      debugPrint("ignore pause!!!");
    }
  }

  void _resumeTimer() {
    if (_isRunning && _subscription.isPaused) {
      _subscription.resume();
      debugPrint("timer resume!!!");
    } else {
      debugPrint("ignore resume!!!");
    }
  }

  void _resetTimer() {
    if (_isRunning) {
      debugPrint("timer reset!!!");
      _subscription.cancel();
      _audioStop();
      setState(() {
        _minute = _setMinute;
        _second = _setSecond;
      });

      _startTimer(_setMinute, _setSecond);
    } else {
      debugPrint("ignore reset!!!");
    }
  }

  Future _audioPlay() async {
    debugPrint("audio play!!!");
    await _player.resume();
  }

  Future _audioStop() async {
    debugPrint("audio stop!!!");
    await _player.stop();
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      _player = AudioPlayer();
      await _player.setSourceAsset('audios/sound01.mp3');
      _player.setReleaseMode(ReleaseMode.loop);
    });
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // timer_clock_lcd
            // SizedBox(
            //   height: 100,
            //   child: Row(
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       TimerClock(_minute),
            //       Text(
            //         ':',
            //         style: Theme.of(context).textTheme.headlineMedium,
            //       ),
            //       TimerClock(_second),
            //     ],
            //   ),
            // ),
            Text(
              '${_minute.toString().padLeft(2, '0')} : ${_second.toString().padLeft(2, '0')}',
              style: const TextStyle(
                  fontFamily: "DS-DIGI",
                  fontWeight: FontWeight.w400,
                  fontSize: 100),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 200,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(
                    child: TextField(
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: "Minute"),
                      style: Theme.of(context).textTheme.bodySmall,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        DecimalTextInputFormatter(decimalRange: 2)
                      ],
                      onChanged: (text) {
                        _setMinute = int.parse(text);
                        if (!_isRunning) {
                          setState(() {
                            _minute = _setMinute;
                          });
                        }
                        debugPrint("set minute: $_setMinute");
                      },
                    ),
                  ),
                  Flexible(
                    child: TextField(
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), labelText: "Second"),
                      style: Theme.of(context).textTheme.bodySmall,
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      onChanged: (text) {
                        _setSecond = int.parse(text);
                        if (!_isRunning) {
                          setState(() {
                            _second = _setSecond;
                          });
                        }
                        debugPrint("set second: $_setSecond");
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              'default timer is 1 minutes.',
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _startTimer(_setMinute, _setSecond);
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _pauseTimer,
                  icon: const Icon(Icons.pause),
                  label: const Text('Pause'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _resumeTimer,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Resume'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.restore),
                  onPressed: _resetTimer,
                  label: const Text('Reset'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.stop),
                  onPressed: _stopTimer,
                  label: const Text('Stop'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({required this.decimalRange})
      : assert(decimalRange > 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    String value = newValue.text;

    if (value.contains(".") &&
        value.substring(value.indexOf(".") + 1).length > decimalRange) {
      truncated = oldValue.text;
      newSelection = oldValue.selection;
    } else if (value == ".") {
      truncated = "0.";

      newSelection = newValue.selection.copyWith(
        baseOffset: math.min(truncated.length, truncated.length + 1),
        extentOffset: math.min(truncated.length, truncated.length + 1),
      );
    }

    return TextEditingValue(
      text: truncated,
      selection: newSelection,
      composing: TextRange.empty,
    );
  }
}
