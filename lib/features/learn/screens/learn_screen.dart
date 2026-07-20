import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'learn_details_screen.dart';
import '../../subcribers_flow/subscriber_menu_drawer.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      drawer: const SubscriberMenuDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          //padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Builder(
                        builder: (context) => GestureDetector(
                          onTap: () => Scaffold.of(context).openDrawer(),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 18.0),
                            child: const Icon(
                              Icons.menu,
                              color: Color(0xFF1E293B),
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                    _buildHeader(),
                  ],
                ),
              ),
              Divider(color: Color(0xFFD1D1D1),),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: _buildCurrentLevelCard(),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: const Text(
                  "Your Level",
                  style: TextStyle(
                    color: Color(0xFF374151),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  //childAspectRatio: 1.1,
                  children: [
                    _buildLevelCard(
                      title: "START ZONE",
                      subtitle: "Beginner",
                      description: "Start your English\njourney with confidence",
                      colors: [const Color(0xFF0186B3), const Color(0xFF00B1ED)],
                    ),
                    _buildLevelCard(
                      title: "START ZONE+",
                      subtitle: "Advanced Beginner",
                      description: "Build solid basics and\ngain momentum",
                      colors: [const Color(0xFFFF5C20), const Color(0xFFFD936C)],
                    ),
                    _buildLevelCard(
                      title: "FLUENCY+ P1",
                      subtitle: "Foundation",
                      description: "Lay the groundwork for\nreal communication",
                      colors: [const Color(0xFFC80E46), const Color(0xFFF85B4D)],
                    ),
                    _buildLevelCard(
                      title: "FLUENCY+ P2",
                      subtitle: "Breakthrough",
                      description: "Start expressing your\nideas with clarity",
                      colors: [const Color(0xFF016EFA), const Color(0xFF04E0F6)],
                    ),
                    _buildLevelCard(
                      title: "FLUENCY+ P3",
                      subtitle: "Elevation",
                      description: "Reach a more natural\nand confident fluency",
                      colors: [const Color(0xFF047956), const Color(0xFF06C07B)],
                    ),
                    _buildLevelCard(
                      title: "ELITE",
                      subtitle: "Mastery",
                      description: "Speak with precision,\npower, and confidence",
                      colors: [const Color(0xFF4C4CFF), const Color(0xFF8888FF)],
                    ),
                  ],
                ),
              ),
              //const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentLevelCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAEDF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Your Current Level",
            style: TextStyle(
              color: Color(0xFF374151),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildTitleWithPlus(
                "START ZONE",
                const TextStyle(
                  color: Color(0xFF374151),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Text("🏆", style: TextStyle(fontSize: 24)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Builder(
          //   builder: (context) => GestureDetector(
          //     onTap: () => Scaffold.of(context).openDrawer(),
          //     child: const Icon(Icons.menu, color: Color(0xFF1E293B), size: 24),
          //   ),
          // ),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
                letterSpacing: 0.5,
              ),
              children: [
                TextSpan(text: "TALK/"),
                TextSpan(text: "'BZ/"),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // balance spacer
        ],
      ),
    );
  }

  Widget _buildLevelCard({
    required String title,
    required String subtitle,
    required String description,
    required List<Color> colors,
  }) {
    return GestureDetector(
      onTap: () => Get.to(() => LearnDetailsScreen(title: title)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEAEDF1)),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleWithPlus(
                    title,
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                alignment: Alignment.centerLeft,
                child: Text(
                  description,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleWithPlus(String title, TextStyle style) {
    if (!title.contains('+')) {
      return Text(title, style: style);
    }

    final List<InlineSpan> children = [];
    final parts = title.split('+');

    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        children.add(TextSpan(text: parts[i]));
      }
      if (i < parts.length - 1) {
        children.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Transform.translate(
              offset: const Offset(0, -6),
              child: Text(
                '+',
                style: style.copyWith(
                  fontSize: style.fontSize! * 0.65,
                  height: 1.0,
                ),
              ),
            ),
          ),
        );
      }
    }

    return Text.rich(
      TextSpan(children: children, style: style),
    );
  }
}
