import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:digital_lcd_number/digital_lcd_number.dart';

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

class TimerClock extends StatelessWidget {
  final int number;
  const TimerClock(this.number, {super.key})
      : assert(number >= 0 && number <= 99);

  @override
  Widget build(BuildContext context) {
    int num2 = (number / 10).floor();
    int num1 = number % 10;
    debugPrint('10의 자리 $num2');
    debugPrint('1의 자리 $num1');

    return Row(
      children: [
        DigitalLcdNumber(
          number: num2,
          color: Colors.black,
          disabledColor: Colors.grey.shade300,
        ),
        DigitalLcdNumber(
          number: num1,
          color: Colors.black,
          disabledColor: Colors.grey.shade300,
        ),
      ],
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
  int _minute = 1;
  int _second = 0;

  void _startTimer(int minute, int second) {
    if (_minute == 0 && _second == 0) {
      debugPrint("minute, second Zero!!!");
      _subscription.cancel();
      _audioStop();
      setState(() {
        _minute = minute;
        _second = second;
      });
    }

    var timerSecond = minute * 60 + second;
    var currentSecond = _minute * 60 + _second;

    if (timerSecond == currentSecond) {
      debugPrint("timer start!!!");
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
    debugPrint("timer stop!!!");
    _subscription.cancel();
    _audioStop();
    setState(() {
      _minute = 1;
      _second = 0;
    });
  }

  void _pauseTimer() {
    if (!_subscription.isPaused) {
      _subscription.pause();
      debugPrint("timer pause!!!");
    } else {
      debugPrint("ignore pause!!!");
    }
  }

  void _resumeTimer() {
    if (_subscription.isPaused) {
      _subscription.resume();
      debugPrint("timer resume!!!");
    } else {
      debugPrint("ignore resume!!!");
    }
  }

  void _resetTimer() {
    debugPrint("timer reset!!!");
    _subscription.cancel();
    _audioStop();
    setState(() {
      _minute = 1;
      _second = 0;
    });

    _startTimer(1, 0);
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
            SizedBox(
              height: 100,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TimerClock(_minute),
                  Text(
                    ':',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  TimerClock(_second),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'default timer is 1 minutes.',
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _startTimer(1, 0);
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
