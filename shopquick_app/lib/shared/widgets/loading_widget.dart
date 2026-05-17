import 'package:flutter/material.dart';
import 'package:shopquick_app/shared/theme/app_colors.dart';

/// Widget to display loading state with spinner and optional message.
class LoadingWidget extends StatelessWidget {
  final String? message;
  final double size;
  final Color color;
  final bool fullScreen;

  const LoadingWidget({
    super.key,
    this.message,
    this.size = 50,
    this.color = AppColors.primary,
    this.fullScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    final widget = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );

    if (fullScreen) {
      return Scaffold(body: widget);
    }

    return widget;
  }
}

/// Linear progress indicator variant
class LoadingBar extends StatelessWidget {
  final double height;
  final Color color;

  const LoadingBar({
    super.key,
    this.height = 4,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LinearProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

/// Skeleton loader for shimmer effect
class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.greyLight,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: const Shimmer.fromColors(
        baseColor: AppColors.greyLight,
        highlightColor: AppColors.white,
        child: SizedBox.expand(),
      ),
    );
  }
}

/// Custom shimmer effect
class Shimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color baseColor;
  final Color highlightColor;

  const Shimmer.fromColors({
    super.key,
    required this.child,
    required this.baseColor,
    required this.highlightColor,
    this.duration = const Duration(seconds: 1),
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [0.0, _controller.value, 1.0],
              transform: GradientRotation(_controller.value * 6.28),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}
