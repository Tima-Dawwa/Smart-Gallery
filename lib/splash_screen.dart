import 'package:flutter/material.dart';
import 'package:smartgallery/core/utils/themes.dart';

class SplashScreen extends StatefulWidget {
  final String logoAssetPath;
  final VoidCallback onAnimationComplete;
  final Duration splashDuration;

  const SplashScreen({
    super.key,
    required this.logoAssetPath,
    required this.onAnimationComplete,
    this.splashDuration = const Duration(seconds: 3),
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );
  }

  void _startSplashSequence() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _animationController.forward();

    await Future.delayed(widget.splashDuration);
    widget.onAnimationComplete();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.customBlack,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              Themes.primary.withOpacity(0.1),
              Themes.customBlack,
              Themes.dark,
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Themes.primary.withOpacity(0.1),
                          Colors.transparent,
                        ],
                        center: Alignment.center,
                        radius: 1.0,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      widget.logoAssetPath,
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            gradient: Themes.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.photo_library,
                            color: Themes.customWhite,
                            size: 80,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
