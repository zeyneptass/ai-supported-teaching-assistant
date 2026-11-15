import 'package:flutter/material.dart';

class LivePulseIndicator extends StatefulWidget {
  const LivePulseIndicator({
    super.key,
    this.color = const Color(0xFFDC2626),
    this.size = 9,
  });

  final Color color;
  final double size;

  @override
  State<LivePulseIndicator> createState() => _LivePulseIndicatorState();
}

class _LivePulseIndicatorState extends State<LivePulseIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Canlı maç',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) =>
            Opacity(opacity: 0.35 + (_controller.value * 0.65), child: child),
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
