import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'subscriber_choose_program_screen.dart';

class SubscriberVoiceRoomScreen extends StatefulWidget {
  const SubscriberVoiceRoomScreen({super.key});

  @override
  State<SubscriberVoiceRoomScreen> createState() =>
      _SubscriberVoiceRoomScreenState();
}

class _SubscriberVoiceRoomScreenState extends State<SubscriberVoiceRoomScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _teacherNames = [
    "Thomas",
    "Philip",
    "Mitchell",
    "Dwight",
    "Lee",
    "Eduardo",
    "Calvin",
    "Sarah",
  ];

  late List<Map<String, dynamic>> _allRooms;
  List<Map<String, dynamic>> _filteredRooms = [];

  @override
  void initState() {
    super.initState();
    _allRooms = List.generate(8, (index) {
      return {
        "index": index + 1,
        "teacher": _teacherNames[index % _teacherNames.length],
        "title":
            "Advanced English - Class ${(index + 1).toString().padLeft(2, '0')}",
      };
    });
    _filteredRooms = _allRooms;
  }

  void _filterRooms(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRooms = _allRooms;
      } else {
        _filteredRooms = _allRooms
            .where(
              (room) =>
                  room['title'].toLowerCase().contains(query.toLowerCase()) ||
                  room['teacher'].toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: Stack(
          children: [
            // ─── Main Content (Blurred) ──────────────────────────────────────────
            Column(
              children: [
                const SizedBox(height: 16),
                // ─── Header row with menu icon ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Builder(
                        builder: (context) => GestureDetector(
                          onTap: () => Scaffold.of(context).openDrawer(),
                          child: const Icon(
                            Icons.menu,
                            color: Color(0xFF1E293B),
                            size: 26,
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildSearchBar(),
                ),

                const SizedBox(height: 20),
                Expanded(
                  child: _filteredRooms.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _filteredRooms.length,
                          itemBuilder: (context, index) {
                            final room = _filteredRooms[index];
                            return _buildVoiceRoomCard(
                              index: room['index'],
                              teacherName: room['teacher'],
                            );
                          },
                        ),
                ),
              ],
            ),

            // ─── Blur Overlay ──────────────────────────────────────────────────
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: GestureDetector(
                  onTap: () =>
                      Get.to(() => const SubscriberChooseProgramScreen()),
                  child: Container(color: Colors.black.withOpacity(0.01)),
                ),
              ),
            ),

            // ─── Unblurred Search Bar ──────────────────────────────────────────
            Positioned(top: 20, left: 20, right: 20, child: _buildSearchBar()),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No rooms found",
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAEDF1)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterRooms,
        style: const TextStyle(color: Color(0xFF536F7A)),
        decoration: const InputDecoration(
          hintText: "Search notes...",
          hintStyle: TextStyle(color: Color(0xFF90A4AE), fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Color(0xFF90A4AE)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildVoiceRoomCard({
    required int index,
    required String teacherName,
    bool hasBorder = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasBorder ? const Color(0xFF26A69A) : const Color(0xFFEAEDF1),
          width: hasBorder ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Advanced English - Class ${index.toString().padLeft(2, '0')}",
            style: const TextStyle(
              color: Color(0xFF374151),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(
                      "https://i.pravatar.cc/150?u=$teacherName",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    teacherName,
                    style: const TextStyle(
                      color: Color(0xFF374151),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              _buildParticipantAvatars(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantAvatars() {
    return SizedBox(
      height: 32,
      width: 100, // Adjusted based on overlap
      child: Stack(
        children: List.generate(4, (index) {
          return Positioned(
            right: index * 20.0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: CircleAvatar(
                radius: 14,
                backgroundImage: NetworkImage(
                  "https://i.pravatar.cc/150?u=p$index${DateTime.now().millisecond}",
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
