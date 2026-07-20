import 'package:flutter/material.dart';
import 'package:flutter_tbzwa/features/daily_mission/screens/today_progress_screen.dart';
import 'package:get/get.dart';

class DailyMissionSplashScreen extends StatefulWidget {
  const DailyMissionSplashScreen({super.key});

  @override
  State<DailyMissionSplashScreen> createState() =>
      _DailyMissionSplashScreenState();
}

class _DailyMissionSplashScreenState extends State<DailyMissionSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_controller)
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });

    _controller.forward().then((_) {
      if (mounted) {
        Get.off(() => const TodayProgressScreen());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF5151EF),
              Color(0xFF3B3BCC),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            Image.asset(
              'assets/images/bz_mission.png',
              width: 250,
            ),

            const Spacer(),

            const Text(
              "Updating Library Content...",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _animation.value,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF00E676),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}