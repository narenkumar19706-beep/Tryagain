import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/local_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _unlocked = false;

  String _areaName = 'Indiranagar, Bangalore';
  String _district = 'Bangalore';
  String _phone = '';

  static const Duration _holdDuration = Duration(seconds: 3);
  Timer? _holdTimer;
  DateTime? _holdStart;

  double _holdProgress = 0.0;
  int _sosState = 0;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);

    _load();
  }

  Future<void> _load() async {
    _areaName = await LocalStorage.getAreaName();
    _district = await LocalStorage.getDistrict();
    _phone = await LocalStorage.getPhone();
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _unlock() {
    setState(() => _unlocked = true);
  }

  void _startHold() {
    if (!_unlocked) {
      return;
    }
    if (_sosState != 0) {
      return;
    }

    setState(() {
      _holdProgress = 0;
      _holdStart = DateTime.now();
    });

    _holdTimer?.cancel();
    _holdTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_holdStart == null) {
        return;
      }
      final elapsed = DateTime.now().difference(_holdStart!);
      final progress = elapsed.inMilliseconds / _holdDuration.inMilliseconds;
      final clamped = progress.clamp(0.0, 1.0);

      setState(() => _holdProgress = clamped);

      if (clamped >= 1.0) {
        timer.cancel();
        _triggerSos();
      }
    });
  }

  void _cancelHold() {
    if (!_unlocked) {
      return;
    }
    if (_sosState != 0) {
      return;
    }

    _holdTimer?.cancel();
    setState(() {
      _holdProgress = 0;
      _holdStart = null;
    });
  }

  Future<void> _triggerSos() async {
    setState(() => _sosState = 1);

    try {
      await ApiService.sosStart(
        phoneNumber: _phone,
        district: _district,
        lat: 0,
        lng: 0,
        comment: '',
      );

      if (!mounted) {
        return;
      }
      setState(() => _sosState = 2);

      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) {
        return;
      }
      setState(() {
        _sosState = 0;
        _holdProgress = 0;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _sosState = 0;
        _holdProgress = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final width = MediaQuery.of(context).size.width;

    final label = !_unlocked
        ? 'SOS'
        : _sosState == 0
            ? 'READY'
            : _sosState == 1
                ? 'SENDING'
                : 'SENT';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: safeTop + 10),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12, width: 1),
                  color: Colors.white,
                ),
                child: const Center(
                  child: Icon(Icons.pets, size: 22, color: Colors.black),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                !_unlocked ? 'RAPID' : 'Rapid',
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.2,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Response Team',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                  height: 1.0,
                  color: Color(0xFF9AA0A6),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 20,
                    color: Color(0xFF9AA0A6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _areaName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9AA0A6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTapDown: (_) => _startHold(),
                    onTapUp: (_) => _cancelHold(),
                    onTapCancel: _cancelHold,
                    child: AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, _) {
                        final redMain = const Color(0xFFE11B22);
                        final redDark = const Color(0xFFB90D12);
                        final redInner = const Color(0xFFF14046);

                        final glow = 0.10 + (_pulse.value * 0.12);

                        return SizedBox(
                          width: 320,
                          height: 320,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 300,
                                height: 300,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: redMain.withOpacity(glow),
                                      blurRadius: 60,
                                      spreadRadius: 18,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 290,
                                height: 290,
                                child: CustomPaint(
                                  painter: _RingPainter(
                                    progress: _unlocked ? _holdProgress : 0,
                                    color: redMain.withOpacity(0.9),
                                    trackColor: const Color(0xFFF1F3F6),
                                  ),
                                ),
                              ),
                              Container(
                                width: 260,
                                height: 260,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    center: const Alignment(-0.2, -0.35),
                                    radius: 1.0,
                                    colors: [
                                      redInner.withOpacity(0.95),
                                      redMain,
                                      redDark,
                                    ],
                                    stops: const [0.12, 0.65, 1.0],
                                  ),
                                  border: Border.all(
                                    color: redDark.withOpacity(0.55),
                                    width: 10,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: !_unlocked ? 56 : 40,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              if (!_unlocked)
                                Positioned(
                                  right: 50,
                                  bottom: 50,
                                  child: Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.black,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 6,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.lock,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  !_unlocked
                      ? 'Locked for safety'
                      : 'Press and hold for 3s to send alert',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: !_unlocked ? Colors.black : const Color(0xFFB6BCC6),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Container(
                width: width,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Colors.black, width: 1),
                ),
                child: InkWell(
                  onTap: _unlocked ? null : _unlock,
                  child: Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            _unlocked ? 'ACTIVATED' : 'SLIDE TO ACTIVATE',
                            style: TextStyle(
                              fontSize: 16,
                              letterSpacing: 4,
                              fontWeight: FontWeight.w800,
                              color: _unlocked
                                  ? Colors.white.withOpacity(0.7)
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: Colors.white24,
                      ),
                      const SizedBox(
                        width: 70,
                        child: Center(
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: Text(
                  'SECURE  ACCESS   |   PRIVACY  ENSURED',
                  style: TextStyle(
                    fontSize: 12,
                    letterSpacing: 2.2,
                    fontWeight: FontWeight.w700,
                    color: Colors.black.withOpacity(0.22),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 10.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - stroke;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = trackColor
      ..strokeCap = StrokeCap.round;

    final prog = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = color
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, track);

    final startAngle = -math.pi / 2;
    final sweep = (2 * math.pi) * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweep,
      false,
      prog,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
