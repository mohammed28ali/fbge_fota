import 'package:flutter/material.dart';
import 'package:fota_uploader/config/navigation/navigation.dart';
import 'package:fota_uploader/core/utils/app_colors.dart';
import 'package:fota_uploader/features/home/screen/home_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:math' as math;
import 'dart:ui';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView(
            controller: controller,
            onPageChanged: (index) {
              setState(() => onLastPage = index == 2);
            },
            children: const [
              OnboardPage(
                icon: Icons.flutter_dash,
                title: "Welcome to FBGA FOTA",
                subtitle:
                    "Firmware updates for your FPGA made simple and wireless.",
              ),
              OnboardPage(
                icon: Icons.cloud_upload_outlined,
                title: "Upload Seamlessly",
                subtitle:
                    "Upload firmware files with just a tap. No cables, no fuss.",
              ),
              OnboardPage(
                icon: Icons.memory_rounded,
                title: "Flash Remotely",
                subtitle:
                    "Deliver updates to your FPGA hardware anytime, anywhere.",
              ),
            ],
          ),
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: controller,
                count: 3,
                effect: ExpandingDotsEffect(
                  activeDotColor: AppColors.primaryColor,
                  dotColor: Colors.grey.shade300,
                  dotHeight: 10,
                  dotWidth: 10,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: TextButton(
              onPressed: () {
                if (onLastPage) {
                  Navigation.pushReplacement(FPGAFOTAUploaderScreen());
                } else {
                  controller.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: Text(
                onLastPage ? "Get Started" : "Next",
                style: const TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardPage extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const OnboardPage({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  State<OnboardPage> createState() => _OnboardPageState();
}

class _OnboardPageState extends State<OnboardPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late AnimationController _particleController;
  late Animation<double> _fade;
  late Animation<Offset> _slide;
  late Animation<double> _scale;
  late Animation<double> _pulse;
  late Animation<double> _rotate;

  @override
  void initState() {
    super.initState();

    // Main animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Pulse animation for icon
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Particle/glow animation
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
          ),
        );

    _scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
      ),
    );

    _pulse = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotate = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );

    // Start animations
    _controller.forward();
    _pulseController.repeat(reverse: true);
    _particleController.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F0F23)],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Icon with Glow Effect
              ScaleTransition(
                scale: _scale,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Rotating particle ring
                    AnimatedBuilder(
                      animation: _rotate,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotate.value * 2 * 3.14159,
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Color(0xFF00D4FF).withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Stack(
                              children: List.generate(8, (index) {
                                double angle = (index * 45) * 3.14159 / 180;
                                return Positioned(
                                  left: 90 + 70 * math.cos(angle) - 3,
                                  top: 90 + 70 * math.sin(angle) - 3,
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF00D4FF),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0xFF00D4FF),
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        );
                      },
                    ),

                    // Pulsing glow background
                    AnimatedBuilder(
                      animation: _pulse,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Color(0xFF00D4FF).withOpacity(0.2),
                              Color(0xFF00D4FF).withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulse.value,
                          child: child,
                        );
                      },
                    ),

                    // Main icon container
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF00D4FF).withOpacity(0.1),
                        border: Border.all(color: Color(0xFF00D4FF), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF00D4FF).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.icon,
                        size: 60,
                        color: Color(0xFF00D4FF),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              // Animated Title
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, (1 - _fade.value) * 20),
                    child: Opacity(
                      opacity: _fade.value,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF00D4FF).withOpacity(0.1),
                              Color(0xFF00FF88).withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Color(0xFF00D4FF).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()
                              ..shader =
                                  LinearGradient(
                                    colors: [
                                      Color(0xFF00D4FF),
                                      Color(0xFF00FF88),
                                    ],
                                  ).createShader(
                                    Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                                  ),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),

              // Animated Subtitle
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, (1 - _fade.value) * 30),
                    child: Opacity(
                      opacity: _fade.value * 0.9,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          widget.subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Animated dots indicator (optional decorative element)
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fade.value * 0.6,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return AnimatedContainer(
                          duration: Duration(milliseconds: 300 + (index * 100)),
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF00D4FF).withOpacity(0.6),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF00D4FF).withOpacity(0.3),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
