import 'dart:math';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:justlevelup/pop_on_change.dart';
import 'package:justlevelup/sfx.dart';
import 'package:justlevelup/store_bottom_sheet.dart';
import 'package:justlevelup/text.dart';
import 'package:justlevelup/wobble_forever.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const ClickerApp());
}

class ClickerApp extends StatelessWidget {
  const ClickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Just Level Up',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: "ArialBlack"
      ),
      home: const ClickerHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ClickerHome extends StatefulWidget {
  const ClickerHome({super.key});

  @override
  State<ClickerHome> createState() => _ClickerHomeState();
}

class _ClickerHomeState extends State<ClickerHome> {
  static const int minLevel = 1;
  static const int maxLevel = 101; // 101 레벨 달성 시 게임 종료
  final Random _rng = Random();

  int _level = minLevel;
  int _best = minLevel;
  int _attempts = 0; // 클릭 시도 횟수
  bool _cleared = false;

  bool _failing = false;
  int _failEventId = 0;   // 실패 이벤트 nonce
  int _failStage = 100;   // 실패 당시 stage를 고정 렌더링용으로 저장

  double _destruction = 0; // 초기화 확률
  final double _destructionGap = 0.1; // 초기화 확률 증가 단위

  // 현재 레벨에서 다음 레벨로 갈 확률(%) = 101 - 현재레벨
  int get _successPercent {
    if (_level >= maxLevel) return 0;
    return 101 - _level; // L=1 -> 100%, L=100 -> 1%
  }

  void _resetGame() {
    setState(() {
      _level = minLevel;
      _attempts = 0;
      _cleared = false;
      _failing = false;
    });
  }

  int _stageForLevel(int l) {
    if (l >= 101) return 0;
    final idx = (l - 1) ~/ 4;
    return (100 - 4 * idx).clamp(0, 100);
  }

  void _onTapCharacter() {
    if (_cleared || _failing) return;
    if (_level >= maxLevel) return;

    setState(() {
      _attempts++;
      final roll = _rng.nextInt(100) + 1; // 1~100
      if (roll <= _successPercent) {
      // if (true) {
        // ✅ 성공 SFX
        Sfx.success();

        _level++;
        if (_level > _best) _best = _level;
        if (_level >= maxLevel) {
          _cleared = true;
          _showClearDialog();
        }
      } else {
        // _level = minLevel;

        // _failing = true;
        // _failStage = _stageForLevel(_level); // 실패 당시 stage 고정
        // _failEventId++;

        // 실패: 파괴 여부 결정
        final destructionRoll = _rng.nextDouble() * 100; // 0~100
        if (destructionRoll < _destruction) {
        // if (false) {
          // ✅ 실패 + 초기화 SFX
          Sfx.fail();
          Sfx.drop();
          // 파괴 발생 → 레벨 1 초기화, 확률도 리셋
          _failing = true;
          _failStage = _stageForLevel(_level); // 실패 당시 stage 고정
          _failEventId++;
          _destruction = 0;
        } else {
          // ✅ 실패지만 초기화는 아님 → 약한 히트 SFX
          Sfx.hit();
          // 파괴는 안 됨 → 확률 증가
          _destruction = (_destruction + _destructionGap).clamp(0, 100);
          // 레벨은 유지 (원한다면 -1레벨 감소 같은 패널티도 줄 수 있음)
        }
      }
    });
  }

  void _showClearDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('클리어!'),
        content: Text('총 시도: $_attempts회\n최고레벨: $_best\n축하합니다 👑'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGame();
            },
            child: const Text('다시하기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_level - minLevel) / (maxLevel - minLevel);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xffdcd6ff),
        actions: [
          IconButton(
            tooltip: 'Reset',
            onPressed: _resetGame,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      backgroundColor: Color(0xffdcd6ff),
      body: SafeArea(
        child: Column(
          children: [
            Spacer(),

            WobbleForever(
              angleDeg: 2,
              holdRatio: 0.08,
              child: PopOnChange(
                trigger: _successPercent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                   TextWithStroke(color: Color(0xffffbb00), text: _cleared ? "You master" : "Level up", fontSize: 25),
                   if (!_cleared) TextWithStroke(color: Colors.white, text: '$_successPercent%', fontSize: 35),
                   TextWithStroke(color: Colors.white, text: _cleared ? 'Thank you for playing\nthis game' : 'success', fontSize: 15),
                    // Text('현재 레벨: $_level / $maxLevel',
                    //     style: Theme.of(context).textTheme.titleLarge),
                    // const SizedBox(height: 4),
                    // Text('다음 레벨 성공 확률: $_successPercent%',
                    //     style: Theme.of(context).textTheme.bodyMedium),
                    // const SizedBox(height: 4),
                    // Text('최고 레벨: $_best',
                    //     style: Theme.of(context).textTheme.bodySmall),
                    // Text('총 시도: $_attempts회',
                    //     style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ),

            Center(
              child: Bounceable(
                onTap: _onTapCharacter,
                child: SizedBox(
                  width: 260,
                  height: 260,
                  child: CharacterSprite(
                    level: _failing ? 4 * ((100 - _failStage) ~/ 4) + 1 : _level,
                    // 위의 level 값은 시각적으로 동일 stage가 유지되게 하기 위한 안전장치
                    failEventId: _failEventId,
                    failingStage: _failStage,
                    isFailing: _failing,
                    onFailAnimationEnd: () {
                      // 애니메이션 끝나면 레벨 1로 리셋
                      setState(() {
                        _level = minLevel;
                        _failing = false;
                      });
                    },
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextWithStroke(color: Color(0xffffbb00), text: 'Level ', fontSize: 15),
                TextWithStroke(color: Colors.white, text: '$_level', fontSize: 15),
              ],
            ),
            SizedBox(height: 20),
            TextWithStroke(color: Colors.white, text: _cleared ? 'Please wait until the next update\nThe next character is waiting' : '\n\n\n', fontSize: 10),
            Spacer(),

            TextWithStroke(color: Color(0xffe03636), text: '${_destruction.toStringAsFixed(1)}%', fontSize: 20),
            TextWithStroke(color: Colors.white, text: 'Destruction', fontSize: 12),
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Bounceable(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        elevation: 0,
                        builder: (context) {
                          return StoreBottomSheet();
                        },
                      ).then((value) {
                        ;
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextWithStroke(color: Color(0xff6bf748), text: 'SHOP', fontSize: 12),
                        SizedBox(
                          width: 60,
                          height: 45,
                          child: Image.asset(
                            'assets/icons/store.png',
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

/// 캐릭터 레이어를 규칙에 따라 합성해 보여주는 위젯.
/// 에셋 경로 규칙: assets/characters/{prefix}_{part}.png
/// - prefix: 100, 96, 92, ..., 0
/// - part: b, f, h, lh, rh, amr (필요한 경우)
class CharacterSprite extends StatefulWidget {
  const CharacterSprite({
    super.key,
    required this.level,
    this.assetBasePath = 'assets/chr',

    // 실패 애니메이션 제어
    this.failEventId = 0,
    this.failingStage = 100,
    this.isFailing = false,
    this.onFailAnimationEnd,
  });

  final int level;
  final String assetBasePath;

  // 실패 애니메이션 파라미터
  final int failEventId;          // 값이 바뀌면 애니메이션 시작
  final int failingStage;         // 실패 당시 stage (100, 96, ... , 0)
  final bool isFailing;
  final VoidCallback? onFailAnimationEnd;

  @override
  State<CharacterSprite> createState() => _CharacterSpriteState();
}

class _CharacterSpriteState extends State<CharacterSprite> with TickerProviderStateMixin {
  late final AnimationController _bobbing; // 평상시 위아래 부유
  late final AnimationController _fail;    // 실패 낙하

  int _lastFailEventId = 0;

  @override
  void initState() {
    super.initState();
    _bobbing = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _fail = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void didUpdateWidget(covariant CharacterSprite oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 실패 이벤트 감지 -> 애니메이션 재생
    if (widget.failEventId != _lastFailEventId && widget.isFailing) {
      _lastFailEventId = widget.failEventId;
      _fail
        ..reset()
        ..forward().whenComplete(() async {
          // 애니메이션 끝난 직후 → 1초 대기
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            widget.onFailAnimationEnd?.call();
          }
        });
    }
  }

  @override
  void dispose() {
    _bobbing.dispose();
    _fail.dispose();
    super.dispose();
  }

  /// 레벨에 따른 프리픽스 계산:
  /// - L=1~4 => 100
  /// - L=5~8 => 96
  /// - ...
  /// - L=101 => 0
  int _stageForLevel(int l) {
    if (l >= 101) return 0;
    final idx = (l - 1) ~/ 4; // 0,1,2,...
    final s = 100 - 4 * idx;
    return s.clamp(0, 100);
  }

  /// 현재 스테이지에서 사용할 레이어 파일명 리스트를 만든다.
  /// 규칙:
  /// 1) 기본: {stage}_b, {stage}_f, {stage}_h
  /// 2) stage >= 52 구간: 52_lh, 52_rh 추가
  /// 3) stage <= 48 구간: {stage}_amr 추가
  /// 4) L=101(클리어): stage=0 사용 + 0_amr 포함
  List<String> _baseLayers(int l) {
    final stage = _stageForLevel(l);
    final layers = <String>[
      '${stage == 0 ? '0' : '100'}_b', // 몸통
      '${stage == 0 ? '0' : '100'}_f', // 발
    ];
    if (stage != 100 && (stage > 84 || stage < 68)) layers.add('${stage}_lh'); // 왼손
    layers.add('${stage == 0 ? '0' : '100'}_h'); // 머리
    if (stage < 52) layers.add('${stage}_amr'); // 머리 장신구
    if (stage != 100) layers.add('${stage}_rh'); // 오른손

    return layers;
  }

  // 레이어별 dy 계산: _b와 _h만 살짝 위아래로
  double _dyForLayer(String name, double t) {
    // t: 0~1 -> 라디안으로 변환
    final w = 2 * math.pi * t;

    const bodyAmp = 2.0; // px
    const headAmp = 2.0; // px (머리는 살짝 덜 움직이게)
    const bodyPhase = 0.0;
    const handAmp = 1.0;
    const headPhase = math.pi / 3; // 약간 위상 차

    if (name.endsWith('_b')) {
      return math.sin(w + bodyPhase) * bodyAmp;
    }
    if (name.endsWith('_h') || name.endsWith('_amr')) {
      return math.sin(w + headPhase) * headAmp;
    }
    if (name.endsWith('_lh') || name.endsWith('_rh')) {
      return math.sin(w + bodyPhase) * handAmp;
    }
    return 0.0; // 나머지는 고정
  }

  // 실패 낙하용 변환 (0→1)
  // _lh: 왼쪽으로 기울며 좌하단으로, _rh: 오른쪽으로, _amr/_arm: 약하게 우하단
  (double dx, double dy, double rot, double opacity) _failTransformFor(String name, double t) {
    // hop(살짝 위로) → 부드러운 낙하(C¹ 연속)
    const double tHop = 0.22;    // 튀는 구간 비율
    const double hopHeight = 20; // 위로 튀는 높이(px)

    // 좌우 방향: 오른손( _rh / _amr|_arm )은 +1, 왼손( _lh )은 -1
    int dirFor(String n) {
      if (n.endsWith('_lh')) return 1;
      if (n.endsWith('_rh')) return -1;
      if (n.endsWith('_amr')) return -1; // 무기/팔이 오른쪽이면 +1 (필요시 바꿔도 됨)
      return 0;
    }

    double bounceY(double t, double fallDy) {
      if (t <= tHop) {
        final s = t / tHop;
        return -hopHeight * math.sin((math.pi / 2) * s); // 위로 튀기 (끝에서 속도 0)
      } else {
        final u = (t - tHop) / (1 - tHop);        // 0..1
        final smooth = u * u * (3 - 2 * u);       // smoothstep (C¹)
        return -hopHeight + (hopHeight + fallDy) * smooth;
      }
    }

    // x/회전도 같은 방향으로 “한쪽만” 진행(부호 고정, 역전 없음)
    double smooth01(double t) {
      if (t <= tHop) return (t / tHop) * 0.25;   // 튀는 동안 x/rot은 살짝만(속도 연속감)
      final u = (t - tHop) / (1 - tHop);
      return 0.25 + 0.75 * (u * u * (3 - 2 * u)); // 0.25→1.0로 매끈하게
    }

    final int dir = dirFor(name); // -1 / 0 / +1
    final s = smooth01(t);        // 0..1 (단조 증가 → 방향 유지)

    double dx = 0, dy = 0, rot = 0, op = 1;

    if (name.endsWith('_lh') || name.endsWith('_rh')) {
      dx  = dir * 100 * s;                 // 좌/우로 한쪽만 이동 (부호 고정)
      dy  = bounceY(t, 40);               // 위로 튀고 → 낙하
      rot = dir * (66 * math.pi / 180) * s; // 같은 방향으로 회전
    } else if (name.endsWith('_amr')) {
      dx  = dir * 28 * s;
      dy  = bounceY(t, 60);
      rot = dir * (15 * math.pi / 180) * s;
    } else {
      dx = 0; dy = 0; rot = 0; op = 1;
    }

    return (dx, dy, rot, op);
  }



  @override
  Widget build(BuildContext context) {
    var normalLayers = _baseLayers(widget.level);

    if (widget.isFailing) {
      normalLayers = [...normalLayers.where((name) => name.endsWith('_h') || name.endsWith('_b') || name.endsWith('_f'))];
    }
    // 실패 중엔, 기본 캐릭터는 그대로 두고(팔/무기 제외),
    // 팔/무기는 "실패 당시 stage" 기준으로 별도 오버레이를 만들어 낙하시킴.
    final failingStageLayers = <String>[
      ..._baseLayers(widget.level)
    ].where((name) => !name.endsWith('_h') && !name.endsWith('_b') && !name.endsWith('_f'));

    return AnimatedBuilder(
      animation: Listenable.merge([_bobbing, _fail]),
      builder: (context, _) {
        final t = _bobbing.value;

        // 1) 기본 전체 레이어
        final baseStack = Stack(
          fit: StackFit.expand,
          children: [
            for (final name in normalLayers)
              Positioned.fill(
                child: Transform.translate(
                  offset: Offset(0, _dyForLayer(name, t)),
                  child: Image.asset(
                    '${widget.assetBasePath}/$name.png',
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
          ],
        );

        // 2) 실패 중이면, 팔/무기 레이어만 '분리 애니메이션' 오버레이
        if (widget.isFailing) {
          final ft = _fail.value;
          final overlay = Stack(
            fit: StackFit.expand,
            children: [
              for (final name in failingStageLayers)
                Positioned.fill(
                  child: Builder(builder: (_) {
                    final (dx, dy, rot, op) = _failTransformFor(name, ft);
                    return Opacity(
                      opacity: op,
                      child: Transform.translate(
                        offset: Offset(dx, dy),
                        child: Transform.rotate(
                          angle: rot,
                          child: Image.asset(
                            '${widget.assetBasePath}/$name.png',
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
            ],
          );
          return Stack(fit: StackFit.expand, children: [baseStack, overlay]);
        }

        return baseStack;
      },
    );
  }
}
