import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AnimatedMusicIcon extends StatefulWidget {
  final bool isPlaying;
  final double size;
  final Color? color;

  const AnimatedMusicIcon({
    super.key,
    required this.isPlaying,
    this.size = 24,
    this.color,
  });

  @override
  State<AnimatedMusicIcon> createState() => _AnimatedMusicIconState();
}

class _AnimatedMusicIconState extends State<AnimatedMusicIcon>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.isPlaying) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedMusicIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isPlaying) {
      return Icon(
        LucideIcons.music,
        size: widget.size,
        color: widget.color,
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (index) {
              final delay = index * 0.1;
              final animationValue = (_animation.value - delay).clamp(0.0, 1.0);
              final height = widget.size * 0.3 + 
                  (widget.size * 0.4 * animationValue);
              
              return Container(
                width: 2,
                height: height,
                decoration: BoxDecoration(
                  color: widget.color ?? Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(1),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}