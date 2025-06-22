import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fota_uploader/config/navigation/navigation.dart';
import 'package:fota_uploader/core/utils/app_colors.dart';
import 'package:fota_uploader/core/utils/app_images.dart';
import 'package:fota_uploader/core/utils/app_sizes.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fota_uploader/core/utils/app_strings.dart';
import 'package:fota_uploader/features/onboarding/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _particleController;
  late AnimationController _shimmerController;

  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _logoOpacity;
  late Animation<double> _textSlide;
  late Animation<double> _textOpacity;
  late Animation<double> _particleAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoRotation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textSlide = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutBack),
    );

    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));

    // Particle animation
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeInOut),
    );

    // Shimmer animation
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // Start animations sequentially
    _startAnimations();
    Future.delayed(const Duration(seconds: 5), () {
      Navigation.pushReplacement(OnboardingScreen());
    });
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    _particleController.repeat();

    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 1200));
    _shimmerController.repeat();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _particleController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryColor,
              AppColors.primaryColor.withOpacity(0.8),
              AppColors.primaryColor.withOpacity(0.6),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            AnimatedBuilder(
              animation: _particleAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(_particleAnimation.value),
                  size: Size.infinite,
                );
              },
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated logo with shimmer effect
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _logoController,
                      _shimmerController,
                    ]),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScale.value,
                        child: Transform.rotate(
                          angle: _logoRotation.value * 0.1,
                          child: Opacity(
                            opacity: _logoOpacity.value,
                            child: Container(
                              width: AppSizes.s120.w,
                              height: AppSizes.s120.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.r),
                                child: Stack(
                                  children: [
                                    Image.asset(
                                      AppImages.appLogo,
                                      width: AppSizes.s120.w,
                                      height: AppSizes.s120.h,
                                      fit: BoxFit.cover,
                                    ),
                                    // Shimmer overlay
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.transparent,
                                              Colors.white.withOpacity(0.3),
                                              Colors.transparent,
                                            ],
                                            stops: [
                                              (_shimmerAnimation.value - 0.5)
                                                  .clamp(0.0, 1.0),
                                              _shimmerAnimation.value.clamp(
                                                0.0,
                                                1.0,
                                              ),
                                              (_shimmerAnimation.value + 0.5)
                                                  .clamp(0.0, 1.0),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: AppSizes.s40.h),

                  // Animated app name/tagline
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _textSlide.value),
                        child: Opacity(
                          opacity: _textOpacity.value,
                          child: Column(
                            children: [
                              Text(
                                AppStrings.appName,
                                style: TextStyle(
                                  fontSize: AppSizes.s28.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 2.0,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.3),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: AppSizes.s8.h),
                              Text(
                                "Experience the Future",
                                style: TextStyle(
                                  fontSize: AppSizes.s14.sp,
                                  color: Colors.white.withOpacity(0.9),
                                  letterSpacing: 1.0,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: AppSizes.s60.h),

                  AnimatedBuilder(
                    animation: _textController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textOpacity.value,
                        child: Container(
                          width: 200.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                          child: Stack(
                            children: [
                              AnimatedBuilder(
                                animation: _shimmerController,
                                builder: (context, child) {
                                  return Container(
                                    width: 200.w,
                                    height: 4.h,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.white.withOpacity(0.8),
                                          Colors.transparent,
                                        ],
                                        stops: [
                                          (_shimmerAnimation.value - 0.3).clamp(
                                            0.0,
                                            1.0,
                                          ),
                                          _shimmerAnimation.value.clamp(
                                            0.0,
                                            1.0,
                                          ),
                                          (_shimmerAnimation.value + 0.3).clamp(
                                            0.0,
                                            1.0,
                                          ),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(2.r),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Floating elements
            Positioned(
              top: 100.h,
              right: 50.w,
              child: AnimatedBuilder(
                animation: _particleController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      20 * _particleAnimation.value,
                      10 * _particleAnimation.value,
                    ),
                    child: Opacity(
                      opacity: 0.6,
                      child: Container(
                        width: 6.w,
                        height: 6.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Positioned(
              bottom: 200.h,
              left: 30.w,
              child: AnimatedBuilder(
                animation: _particleController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      -15 * _particleAnimation.value,
                      -20 * _particleAnimation.value,
                    ),
                    child: Opacity(
                      opacity: 0.4,
                      child: Container(
                        width: 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw floating particles
    for (int i = 0; i < 20; i++) {
      final x = (size.width * (i / 20)) + (50 * animationValue);
      final y = (size.height * ((i * 0.7) % 1)) + (30 * animationValue);

      canvas.drawCircle(
        Offset(x % size.width, y % size.height),
        2 + (animationValue * 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
