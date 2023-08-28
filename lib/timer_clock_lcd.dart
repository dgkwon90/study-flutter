import 'package:digital_lcd_number/digital_lcd_number.dart';
import 'package:flutter/material.dart';

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
