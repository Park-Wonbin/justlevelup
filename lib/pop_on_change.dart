import 'package:flutter/material.dart';

/// [trigger] 값이 바뀔 때마다 텍스트가 살짝 커졌다 돌아오는 팝 애니메이션
class PopOnChange extends StatefulWidget {
  const PopOnChange({
    super.key,
    required this.trigger,       // 이 값이 바뀌면 pop!
    required this.child,         // 보통 Text
    this.maxScale = 1.18,        // 얼마나 팝할지
    this.duration = const Duration(milliseconds: 220),
    this.curveUp = Curves.easeOutBack,
    this.curveDown = Curves.easeIn,
  });

  final Object trigger;
  final Widget child;
  final double maxScale;
  final Duration duration;
  final Curve curveUp;
  final Curve curveDown;

  @override
  State<PopOnChange> createState() => _PopOnChangeState();
}

class _PopOnChangeState extends State<PopOnChange>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 1.0, end: widget.maxScale)
          .chain(CurveTween(curve: widget.curveUp)),
      weight: 40,
    ),
    TweenSequenceItem(
      tween: Tween(begin: widget.maxScale, end: 1.0)
          .chain(CurveTween(curve: widget.curveDown)),
      weight: 60,
    ),
  ]).animate(_ctrl);

  @override
  void didUpdateWidget(covariant PopOnChange oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger) {
      _ctrl.forward(from: 0); // 값이 바뀌면 팝!
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: widget.child,
    );
  }
}
