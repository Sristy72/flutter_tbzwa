import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AudioCallScreen extends StatelessWidget {
  final String name;
  final String imageUrl;

  const AudioCallScreen({
    super.key,
    required this.name,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E60), // Dark blue background
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF2E2E80), Color(0xFF141440)],
            center: Alignment.center,
            radius: 1.5,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  const Spacer(flex: 2),
                  // Profile Section
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: _CallAvatar(imageUrl: imageUrl),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Audio Call",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 48),
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: const Text(
                      "IMMERSION++ Unlimited Access",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // End Call
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          height: 72,
                          width: 72,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                      // Accept Call
                      GestureDetector(
                        onTap: () {
                          // Logic for accepting call
                        },
                        child: Container(
                          height: 72,
                          width: 72,
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.phone,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(flex: 1),
                  // Bottom Logo/Toggle
                  const SizedBox(height: 48),
                ],
              ),
              Positioned(
                top: 0,
                left: 8,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () => Get.back(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CallAvatar extends StatelessWidget {
  final String imageUrl;

  const _CallAvatar({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl.isNotEmpty;
    return CircleAvatar(
      radius: 66,
      backgroundColor: Colors.white.withValues(alpha: 0.12),
      backgroundImage: hasImage ? NetworkImage(imageUrl) : null,
      child: hasImage
          ? null
          : const Icon(Icons.person_rounded, color: Colors.white, size: 64),
    );
  }
}
