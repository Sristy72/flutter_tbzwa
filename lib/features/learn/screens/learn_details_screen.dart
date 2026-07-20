import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'learn_chat_screen.dart';

class LearnDetailsScreen extends StatelessWidget {
  final String title;
  const LearnDetailsScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF374151), size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF374151),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: _buildSearchBar(),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                GestureDetector(
                  onTap: () => Get.to(() => LearnChatScreen(
                    batchName: "$title - Early Morning Batch",
                    lastMessage: "Kathy Onana : Good morning everyone! Today...",
                    imageUrl: "https://i.pravatar.cc/150?u=1",
                  )),
                  child: _buildBatchCard(
                    "Early Morning Batch",
                    "Kathy Onana : Good morning everyone! Today...",
                    "09:00 AM",
                    3,
                    hasBorder: true,
                    imageUrl: "https://i.pravatar.cc/150?u=1",
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.to(() => LearnChatScreen(
                    batchName: "$title - Morning Batch",
                    lastMessage: "Kathy Onana : Good morning everyone! Today...",
                    imageUrl: "https://i.pravatar.cc/150?u=2",
                  )),
                  child: _buildBatchCard(
                    "Morning Batch",
                    "Kathy Onana : Good morning everyone! Today...",
                    "09:00 AM",
                    3,
                    imageUrl: "https://i.pravatar.cc/150?u=2",
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.to(() => LearnChatScreen(
                    batchName: "$title - Noon Batch",
                    lastMessage: "Kathy Onana : Hello there, I hope you're doing...",
                    imageUrl: "https://i.pravatar.cc/150?u=3",
                  )),
                  child: _buildBatchCard(
                    "Noon Batch",
                    "Kathy Onana : Hello there, I hope you're doing...",
                    "09:00 AM",
                    3,
                    imageUrl: "https://i.pravatar.cc/150?u=3",
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.to(() => LearnChatScreen(
                    batchName: "$title - Afternoon Batch",
                    lastMessage: "Kathy Onana : Hello there, I hope you're doing...",
                    imageUrl: "https://i.pravatar.cc/150?u=4",
                  )),
                  child: _buildBatchCard(
                    "Afternoon Batch",
                    "Kathy Onana : Hello there, I hope you're doing...",
                    "09:00 AM",
                    3,
                    imageUrl: "https://i.pravatar.cc/150?u=4",
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.to(() => LearnChatScreen(
                    batchName: "$title - Evening Batch",
                    lastMessage: "Kathy Onana : Hello there, I hope you're doing...",
                    imageUrl: "https://i.pravatar.cc/150?u=5",
                  )),
                  child: _buildBatchCard(
                    "Evening Batch",
                    "Kathy Onana : Hello there, I hope you're doing...",
                    "09:00 AM",
                    3,
                    imageUrl: "https://i.pravatar.cc/150?u=5",
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.to(() => LearnChatScreen(
                    batchName: "$title - Night Batch",
                    lastMessage: "Kathy Onana : Hello there, I hope you're doing...",
                    imageUrl: "https://i.pravatar.cc/150?u=6",
                  )),
                  child: _buildBatchCard(
                    "Night Batch",
                    "Kathy Onana : Hello there, I hope you're doing...",
                    "09:00 AM",
                    3,
                    imageUrl: "https://i.pravatar.cc/150?u=6",
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
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
        style: TextStyle(color: Color(0xFF436E7A)),
        decoration: InputDecoration(
          hintText: "Search notes...",
          hintStyle: TextStyle(color: Color(0xFF90A4AE), fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Color(0xFF90A4AE)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15)
        ),
      ),
    );
  }

  Widget _buildBatchCard(String batchName, String message, String time, int badgeCount, {bool hasBorder = false, String? imageUrl}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasBorder ? const Color(0xFF26A69A) : const Color(0xFFEAEDF1),
          width: hasBorder ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundImage: NetworkImage(imageUrl ?? "https://i.pravatar.cc/150"),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "$title - $batchName",
                        style: const TextStyle(
                          color: Color(0xFF374151),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        color: Color(0xFF374151),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Color(0xFF90A4AE),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF26A69A),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        badgeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
