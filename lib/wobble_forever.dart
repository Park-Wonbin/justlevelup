import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 텍스트(혹은 어떤 위젯이든)를 좌우로 살짝 '딸깍' 흔들어주는 영구 애니메이션
class WobbleForever extends StatefulWidget {
  const WobbleForever({
    super.key,
    required this.child,
    this.angleDeg = 4,                    // 최대 기울기(도 단위)
    this.period = const Duration(milliseconds: 900), // 한 사이클(좌→우→좌)
    this.holdRatio = 0.12,                // 끝에 잠깐 '딸깍' 고정 느낌 비율(0~0.3 추천)
    this.enabled = true,                  // off일 때는 멈춤
    this.alignment = Alignment.center,    // 회전 기준점
    this.curve = Curves.easeInOutCubic,   // 이동 커브(딸깍 느낌은 cubic류 추천)
  });

  final Widget child;
  final double angleDeg;
  final Duration period;
  final double holdRatio;
  final bool enabled;
  final Alignment alignment;
  final Curve curve;

  @override
  State<WobbleForever> createState() => _WobbleForeverState();
}

class _WobbleForeverState extends State<WobbleForever>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
  AnimationController(vsync: this, duration: widget.period);

  late Animation<double> _angle;

  @override
  void initState() {
    super.initState();
    _buildAnimation();
    if (widget.enabled) _ctrl.repeat();
  }

  @override
  void didUpdateWidget(covariant WobbleForever oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.period != widget.period ||
        oldWidget.angleDeg != widget.angleDeg ||
        oldWidget.holdRatio != widget.holdRatio ||
        oldWidget.curve != widget.curve) {
      _ctrl.duration = widget.period;
      _buildAnimation();
      if (widget.enabled && !_ctrl.isAnimating) _ctrl.repeat();
    }
    if (oldWidget.enabled != widget.enabled) {
      widget.enabled ? _ctrl.repeat() : _ctrl.stop();
    }
  }

  void _buildAnimation() {
    final a = widget.angleDeg * math.pi / 180;        // 라디안 변환
    final hold = (widget.holdRatio.clamp(0.0, 0.3));  // 과하면 어지러움
    final travel = (1 - 2 * hold) / 2;                // -a→+a, +a→-a 각 이동 구간 비율

    // [-a] → (hold) → [+a] → (hold) → [-a]
    _angle = TweenSequence<double>([
      // -a에서 잠깐 고정(‘딸’)
      TweenSequenceItem(tween: ConstantTween(-a), weight: hold),
      // -a → +a로 부드럽게
      TweenSequenceItem(
        tween: Tween(begin: -a, end: a).chain(CurveTween(curve: widget.curve)),
        weight: travel,
      ),
      // +a에서 잠깐 고정(‘깍’)
      TweenSequenceItem(tween: ConstantTween(a), weight: hold),
      // +a → -a로 부드럽게
      TweenSequenceItem(
        tween: Tween(begin: a, end: -a).chain(CurveTween(curve: widget.curve)),
        weight: travel,
      ),
    ]).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 화면에서 사라지면 내부적으로 애니메이션 뮤트
    return TickerMode(
      enabled: widget.enabled,
      child: AnimatedBuilder(
        animation: _angle,
        builder: (_, child) => Transform.rotate(
          angle: _angle.value,
          alignment: widget.alignment,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
