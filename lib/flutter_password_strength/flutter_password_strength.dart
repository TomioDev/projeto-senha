library flutter_password_strength;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'src/estimate_bruteforce_strength.dart';

class FlutterPasswordStrength extends StatefulWidget {
  final String? password;


  final double? width;


  final double height;


  final Animatable<Color>? strengthColors;


  final Color backgroundColor;


  final double radius;


  final Duration? duration;


  final void Function(double strength)? strengthCallback;

  const FlutterPasswordStrength(
      { Key? key,
        required this.password,
        this.width,
        this.height = 5,
        this.strengthColors,
        this.backgroundColor = Colors.grey,
        this.radius = 0,
        this.duration,
        this.strengthCallback})
      : super(key: key);

  Animatable<Color?> get _strengthColors => (strengthColors != null
      ? strengthColors
      : TweenSequence<Color?>(
          [
            TweenSequenceItem(
              weight: 1.0,
              tween: ColorTween(
                begin: Colors.red,
                end: Colors.yellow,
              ),
            ),
            TweenSequenceItem(
              weight: 1.0,
              tween: ColorTween(
                begin: Colors.yellow,
                end: Colors.blue,
              ),
            ),
            TweenSequenceItem(
              weight: 1.0,
              tween: ColorTween(
                begin: Colors.blue,
                end: Colors.green,
              ),
            ),
          ],
        )) as Animatable<Color?>;

  Duration? get _duration =>
      duration != null ? duration : Duration(milliseconds: 300);

  @override
  _FlutterPasswordStrengthState createState() =>
      _FlutterPasswordStrengthState();
}

class _FlutterPasswordStrengthState extends State<FlutterPasswordStrength>
    with SingleTickerProviderStateMixin {

  late AnimationController _animationController;

  late Animation<double> _strengthBarAnimation;

  late Animatable<Color?> _strengthBarColors;

  late Color _strengthBarColor;

  late Color _backgroundColor;

  double? _width;

  late double _height;

  double _radius = 0;

  void Function(double strength)? _strengthCallback;

  double _begin = 0;

  double _end = 0;

  double _passwordStrength = 0;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(duration: widget._duration, vsync: this);
    _strengthBarAnimation =
        Tween<double>(begin: _begin, end: _end).animate(_animationController);
    _strengthBarColors = widget._strengthColors;
    _strengthBarColor =
        _strengthBarColors.evaluate(AlwaysStoppedAnimation(_passwordStrength)) ?? Colors.transparent;

    _backgroundColor = widget.backgroundColor;

    _width = widget.width;
    _height = widget.height;
    _radius = widget.radius;
    _strengthCallback = widget.strengthCallback;

    _animationController.forward();
  }

  void animate() {
    _passwordStrength = estimateBruteforceStrength(widget.password ?? "");

    _begin = _end;
    _end = _passwordStrength * 100;

    _strengthBarAnimation =
        Tween<double>(begin: _begin, end: _end).animate(_animationController);
    _strengthBarColor =
        _strengthBarColors.evaluate(AlwaysStoppedAnimation(_passwordStrength)) ?? Colors.transparent;

    _animationController.forward(from: 0.0);

    if(_strengthCallback != null){
      _strengthCallback!(_passwordStrength);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  @override
  void didUpdateWidget(FlutterPasswordStrength oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.password != widget.password) {
      animate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StrengthBarContainer(
        barColor: _strengthBarColor,
        backgroundColor: _backgroundColor,
        width: _width,
        height: _height,
        radius: _radius,
        animation: _strengthBarAnimation);
  }
}

class StrengthBarContainer extends AnimatedWidget {
  final Color barColor;
  final Color backgroundColor;
  final double? width;
  final double height;
  final double radius;

  const StrengthBarContainer(
      {Key? key,
      required this.barColor,
      required this.backgroundColor,
      this.width,
      required this.height,
      required this.radius,
      required Animation animation})
      : super(key: key, listenable: animation);

  Animation<double> get _percent {
    return listenable as Animation<double>;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Container(
          child: CustomPaint(
              size: Size(width ?? constraints.maxWidth, height),
              painter: StrengthBarBackground(
                  backgroundColor: backgroundColor, backgroundRadius: radius),
              foregroundPainter: StrengthBar(
                  barColor: barColor,
                  barRadius: radius,
                  percent: _percent.value)));
    });
  }
}

class StrengthBar extends CustomPainter {
  Color barColor;
  double barRadius;
  double percent;

  StrengthBar({required this.barColor, required this.barRadius, required this.percent});

  @override
  void paint(Canvas canvas, Size size) {
    drawBar(canvas, size);
  }

  void drawBar(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    double left = 0;
    double top = 0;
    double right = size.width / 100 * percent;
    double bottom = size.height;

    if (barRadius != 0 && right > 0 && barRadius * 2 > right) {
      right = barRadius * 2;
    }

    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(left, top, right, bottom),
          Radius.circular(barRadius),
        ),
        paint);
  }

  @override
  bool shouldRepaint(StrengthBar old) {
    return old.percent != percent;
  }
}

class StrengthBarBackground extends CustomPainter {
  Color backgroundColor;
  double? backgroundRadius;

  StrengthBarBackground({required this.backgroundColor, this.backgroundRadius});

  @override
  void paint(Canvas canvas, Size size) {
    drawBarBackground(canvas, size);
  }

  void drawBarBackground(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    double left = 0;
    double top = 0;
    double right = size.width;
    double bottom = size.height;

    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(left, top, right, bottom),
          Radius.circular(backgroundRadius ?? 0),
        ),
        paint);
  }

  @override
  bool shouldRepaint(StrengthBarBackground old) {
    return true;
  }
}