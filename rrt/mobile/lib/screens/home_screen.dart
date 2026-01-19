import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/local_storage.dart';

enum HomeMode {
  locked,
  ready,
  active,
  confirmStop,
  addUpdate,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  HomeMode _mode = HomeMode.locked;

  String _areaName = "Indiranagar, Bangalore";
  String _district = "Bangalore";
  String _phone = "";
  String _name = "";
  String _address = "12th Main, Indiranagar";

  String _sosId = "";
  DateTime? _sosStartedAt;

  Timer? _tick;
  String _timerText = "00:00";

  static const Duration _holdDuration = Duration(seconds: 3);
  Timer? _holdTimer;
  DateTime? _holdStart;
  double _holdProgress = 0.0;

  int _sendState = 0;

  final TextEditingController _updateCtrl = TextEditingController();
  bool _sendingUpdate = false;

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

    _loadProfile();
  }

  Future<void> _loadProfile() async {
    _areaName = await LocalStorage.getAreaName();
    _district = await LocalStorage.getDistrict();
    _phone = await LocalStorage.getPhone();
    _name = await LocalStorage.getName();
    _address = await LocalStorage.getAddress();

    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _tick?.cancel();
    _holdTimer?.cancel();
    _pulseCtrl.dispose();
    _updateCtrl.dispose();
    super.dispose();
  }

  void _unlock() {
    setState(() => _mode = HomeMode.ready);
  }

  void _startHold() {
    if (_mode != HomeMode.ready) return;
    if (_sendState == 1) return;

    setState(() {
      _holdProgress = 0;
      _holdStart = DateTime.now();
    });

    _holdTimer?.cancel();
    _holdTimer = Timer.periodic(const Duration(milliseconds: 16), (t) {
      if (_holdStart == null) return;
      final elapsed = DateTime.now().difference(_holdStart!);
      final p = elapsed.inMilliseconds / _holdDuration.inMilliseconds;
      final clamped = p.clamp(0.0, 1.0);

      setState(() => _holdProgress = clamped);

      if (clamped >= 1.0) {
        t.cancel();
        _triggerSos();
      }
    });
  }

  void _cancelHold() {
    if (_mode != HomeMode.ready) return;
    if (_sendState == 1) return;

    _holdTimer?.cancel();
    setState(() {
      _holdProgress = 0;
      _holdStart = null;
    });
  }

  Future<void> _triggerSos() async {
    setState(() => _sendState = 1);

    try {
      final res = await ApiService.sosStart(
        phoneNumber: _phone,
        district: _district,
        name: _name,
        address: _address,
        lat: 0,
        lng: 0,
        comment: "",
      );

      final sosId = (res["sosId"] ?? "").toString();
      await LocalStorage.setLastSosId(sosId);

      _sosId = sosId;
      _sosStartedAt = DateTime.now();

      _startTimer();

      if (!mounted) return;
      setState(() {
        _sendState = 0;
        _holdProgress = 0;
        _mode = HomeMode.active;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sendState = 0;
        _holdProgress = 0;
      });
    }
  }

  void _startTimer() {
    _tick?.cancel();

    void compute() {
      if (_sosStartedAt == null) return;
      final diff = DateTime.now().difference(_sosStartedAt!);
      final mm = diff.inMinutes.toString().padLeft(2, "0");
      final ss = (diff.inSeconds % 60).toString().padLeft(2, "0");
      setState(() => _timerText = "$mm:$ss");
    }

    compute();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) => compute());
  }

  void _openAddUpdate() {
    setState(() {
      _updateCtrl.text = "";
      _mode = HomeMode.addUpdate;
    });
  }

  void _openStopConfirm() {
    setState(() => _mode = HomeMode.confirmStop);
  }

  Future<void> _stopSos() async {
    final sosId = _sosId.isEmpty ? await LocalStorage.getLastSosId() : _sosId;

    try {
      await ApiService.sosStop(sosId: sosId, district: _district);
    } catch (_) {}

    _tick?.cancel();
    setState(() {
      _timerText = "00:00";
      _sosId = "";
      _sosStartedAt = null;
      _mode = HomeMode.locked;
    });
  }

  Future<void> _sendUpdate() async {
    if (_sendingUpdate) return;

    final message = _updateCtrl.text.trim();
    if (message.isEmpty) return;

    setState(() => _sendingUpdate = true);

    final sosId = _sosId.isEmpty ? await LocalStorage.getLastSosId() : _sosId;

    try {
      await ApiService.sosUpdate(
        sosId: sosId,
        district: _district,
        message: message,
      );

      if (!mounted) return;
      setState(() {
        _sendingUpdate = false;
        _mode = HomeMode.active;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _sendingUpdate = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final w = MediaQuery.of(context).size.width;

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
                _mode == HomeMode.locked ? "RAPID" : "Rapid",
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.2,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Response Team",
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.0,
                  height: 1.0,
                  color: Color(0xFF9AA0A6),
                ),
              ),
              const SizedBox(height: 18),
              if (_mode == HomeMode.locked ||
                  _mode == HomeMode.ready ||
                  _mode == HomeMode.active)
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 20, color: Color(0xFF9AA0A6)),
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
              const SizedBox(height: 38),
              Expanded(
                child: _buildBody(w),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  "SECURE  ACCESS   •   PRIVACY  ENSURED",
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

  Widget _buildBody(double w) {
    switch (_mode) {
      case HomeMode.locked:
        return _LockedBody(
          w: w,
          pulse: _pulse,
          onUnlock: _unlock,
        );

      case HomeMode.ready:
        return _ReadyBody(
          w: w,
          pulse: _pulse,
          holdProgress: _holdProgress,
          sending: _sendState == 1,
          onHoldStart: _startHold,
          onHoldCancel: _cancelHold,
          onBackToLocked: () => setState(() => _mode = HomeMode.locked),
        );

      case HomeMode.active:
        return _ActiveBody(
          w: w,
          pulse: _pulse,
          timerText: _timerText,
          onAddUpdate: _openAddUpdate,
          onStop: _openStopConfirm,
        );

      case HomeMode.confirmStop:
        return _ConfirmStopBody(
          w: w,
          onStop: _stopSos,
          onKeepActive: () => setState(() => _mode = HomeMode.active),
        );

      case HomeMode.addUpdate:
        return _AddUpdateBody(
          w: w,
          controller: _updateCtrl,
          sending: _sendingUpdate,
          onSend: _sendUpdate,
          onBack: () => setState(() => _mode = HomeMode.active),
        );
    }
  }
}

class _LockedBody extends StatelessWidget {
  final double w;
  final Animation<double> pulse;
  final VoidCallback onUnlock;

  const _LockedBody({
    required this.w,
    required this.pulse,
    required this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: _SosCircle(
              pulse: pulse,
              label: "SOS",
              locked: true,
              holdProgress: 0,
              enableHold: false,
              onHoldStart: null,
              onHoldCancel: null,
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Locked for safety",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 22),
        _ActionBar(
          w: w,
          label: "SLIDE TO ACTIVATE",
          onTap: onUnlock,
        ),
      ],
    );
  }
}

class _ReadyBody extends StatelessWidget {
  final double w;
  final Animation<double> pulse;
  final double holdProgress;
  final bool sending;
  final VoidCallback onHoldStart;
  final VoidCallback onHoldCancel;
  final VoidCallback onBackToLocked;

  const _ReadyBody({
    required this.w,
    required this.pulse,
    required this.holdProgress,
    required this.sending,
    required this.onHoldStart,
    required this.onHoldCancel,
    required this.onBackToLocked,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: GestureDetector(
              onTapDown: (_) => onHoldStart(),
              onTapUp: (_) => onHoldCancel(),
              onTapCancel: () => onHoldCancel(),
              child: _SosCircle(
                pulse: pulse,
                label: sending ? "SENDING" : "READY",
                locked: false,
                holdProgress: holdProgress,
                enableHold: true,
                onHoldStart: onHoldStart,
                onHoldCancel: onHoldCancel,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Press and hold for 3s to send alert",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFFB6BCC6),
          ),
        ),
        const SizedBox(height: 22),
        _ActionBar(
          w: w,
          label: "BACK TO LOCK",
          onTap: onBackToLocked,
        ),
      ],
    );
  }
}

class _ActiveBody extends StatelessWidget {
  final double w;
  final Animation<double> pulse;
  final String timerText;
  final VoidCallback onAddUpdate;
  final VoidCallback onStop;

  const _ActiveBody({
    required this.w,
    required this.pulse,
    required this.timerText,
    required this.onAddUpdate,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: _SosCircle(
              pulse: pulse,
              label: timerText,
              locked: false,
              holdProgress: 0,
              enableHold: false,
              onHoldStart: null,
              onHoldCancel: null,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "People in your district have been notified.",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFFB6BCC6),
          ),
        ),
        const SizedBox(height: 18),
        _ActionBar(
          w: w,
          label: "ADD UPDATE",
          onTap: onAddUpdate,
        ),
        const SizedBox(height: 18),
        _ActionBar(
          w: w,
          label: "STOP SOS",
          onTap: onStop,
        ),
      ],
    );
  }
}

class _ConfirmStopBody extends StatelessWidget {
  final double w;
  final VoidCallback onStop;
  final VoidCallback onKeepActive;

  const _ConfirmStopBody({
    required this.w,
    required this.onStop,
    required this.onKeepActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        const Text(
          "Is the situation\nresolved?",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 40,
            height: 1.1,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          "Stopping this will end alerts to\nothers.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            height: 1.4,
            fontWeight: FontWeight.w700,
            color: Color(0xFFB6BCC6),
          ),
        ),
        const Spacer(),
        _ActionBar(
          w: w,
          label: "STOP SOS",
          onTap: onStop,
        ),
        const SizedBox(height: 18),
        _ActionBar(
          w: w,
          label: "KEEP ACTIVE",
          onTap: onKeepActive,
        ),
      ],
    );
  }
}

class _AddUpdateBody extends StatelessWidget {
  final double w;
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;
  final VoidCallback onBack;

  const _AddUpdateBody({
    required this.w,
    required this.controller,
    required this.sending,
    required this.onSend,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: onBack,
            child: const Text(
              "BACK",
              style: TextStyle(
                fontSize: 14,
                letterSpacing: 3.0,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 240,
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE2E6EA), width: 1.2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextField(
            controller: controller,
            maxLines: null,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: "What’s the situation?",
              hintStyle: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFFB6BCC6),
              ),
            ),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          "SHORT DETAILS HELP OTHERS RESPOND BETTER.",
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 2.0,
            fontWeight: FontWeight.w800,
            color: Color(0xFFB6BCC6),
          ),
        ),
        const Spacer(),
        _ActionBar(
          w: w,
          label: sending ? "SENDING..." : "SEND UPDATE",
          onTap: sending ? null : onSend,
        ),
      ],
    );
  }
}

class _ActionBar extends StatelessWidget {
  final double w;
  final String label;
  final VoidCallback? onTap;

  const _ActionBar({
    required this.w,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: w,
      height: 68,
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w800,
                    color: onTap == null
                        ? Colors.white.withOpacity(0.6)
                        : Colors.white,
                  ),
                ),
              ),
            ),
            const VerticalDivider(width: 1, thickness: 1, color: Colors.white24),
            const SizedBox(
              width: 70,
              child: Center(
                child: Icon(Icons.arrow_forward_rounded,
                    size: 28, color: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _SosCircle extends StatelessWidget {
  final Animation<double> pulse;
  final String label;
  final bool locked;
  final double holdProgress;
  final bool enableHold;

  final VoidCallback? onHoldStart;
  final VoidCallback? onHoldCancel;

  const _SosCircle({
    required this.pulse,
    required this.label,
    required this.locked,
    required this.holdProgress,
    required this.enableHold,
    required this.onHoldStart,
    required this.onHoldCancel,
  });

  @override
  Widget build(BuildContext context) {
    final redMain = const Color(0xFFE11B22);
    final redDark = const Color(0xFFB90D12);
    final redInner = const Color(0xFFF14046);

    return AnimatedBuilder(
      animation: pulse,
      builder: (context, _) {
        final glow = 0.10 + (pulse.value * 0.12);

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
                    progress: enableHold ? holdProgress : 0,
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
                      fontSize: locked ? 56 : 44,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              if (locked)
                Positioned(
                  right: 50,
                  bottom: 50,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                      border: Border.all(color: Colors.white, width: 6),
                    ),
                    child: const Icon(Icons.lock,
                        color: Colors.white, size: 26),
                  ),
                ),
            ],
          ),
        );
      },
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
