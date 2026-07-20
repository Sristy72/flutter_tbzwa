// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'today_progress_screen.dart';
//
// class DailyMissionHomeScreen extends StatelessWidget {
//   const DailyMissionHomeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text("Daily Missions", style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.bold, fontSize: 18)),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1F2937), size: 20),
//           onPressed: () => Get.back(),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//         child: Column(
//           children: [
//             _buildMissionsGrid(),
//             const SizedBox(height: 16),
//             _buildLargeCard(
//               title: "Switch Everything In English",
//               subtitle: "Daily Reminder",
//               icon: Icons.star_border_rounded,
//               color: const Color(0xFF22C55E),
//             ),
//             const SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: () => Get.to(() => const TodayProgressScreen()),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFDFF2EE),
//                 foregroundColor: const Color(0xFF006B5B),
//                 elevation: 0,
//                 minimumSize: const Size(double.infinity, 56),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//               ),
//               child: const Text("View Today's Progress", style: TextStyle(fontWeight: FontWeight.bold)),
//             ),
//             const SizedBox(height: 30),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMissionsGrid() {
//     final missions = [
//       {'title': 'Daily Voice', 'status': '3/3 complete', 'icon': Icons.mic_none_rounded, 'color': Color(0xFF10B981)},
//       {'title': 'Daily Video', 'status': '1/3 in progress', 'icon': Icons.video_camera_back_outlined, 'color': Color(0xFFF59E0B)},
//       {'title': 'Daily Vocabulary', 'status': '3/3 complete', 'icon': Icons.text_fields_rounded, 'color': Color(0xFF3B82F6)},
//       {'title': 'Daily Summary', 'status': '1/3 in progress', 'icon': Icons.assignment_outlined, 'color': Color(0xFFEC4899)},
//       {'title': 'Daily English Imrs.', 'status': '3/3 complete', 'icon': Icons.headphones_outlined, 'color': Color(0xFF6366F1)},
//       {'title': 'Daily BZPad', 'status': 'Daily Reminder', 'icon': Icons.edit_note_rounded, 'color': Color(0xFF06B6D4)},
//     ];
//
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: missions.length,
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 16,
//         mainAxisSpacing: 16,
//         childAspectRatio: 0.82,
//       ),
//       itemBuilder: (context, index) {
//         final mission = missions[index];
//         bool isComplete = (mission['status'] as String).contains('complete');
//         return Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(24),
//             border: Border.all(color: const Color(0xFFF3F4F6), width: 2),
//             boxShadow: [
//               BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(10),
//                 decoration: BoxDecoration(
//                   color: (mission['color'] as Color).withOpacity(0.1),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(mission['icon'] as IconData, color: mission['color'] as Color, size: 24),
//               ),
//               const Spacer(),
//               Text(
//                 mission['title'] as String,
//                 style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1F2937)),
//               ),
//               const SizedBox(height: 6),
//               Row(
//                 children: [
//                   Icon(
//                     isComplete ? Icons.check_circle_rounded : (mission['status'] as String).contains('progress') ? Icons.circle_outlined : Icons.star_rounded,
//                     size: 14,
//                     color: isComplete ? const Color(0xFF10B981) : Colors.amber,
//                   ),
//                   const SizedBox(width: 4),
//                   Text(
//                     mission['status'] as String,
//                     style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildLargeCard({required String title, required String subtitle, required IconData icon, required Color color}) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: const Color(0xFFF3F4F6), width: 2),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(icon, color: color, size: 30),
//           ),
//           const SizedBox(height: 24),
//           Text(
//             title,
//             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1F2937)),
//           ),
//           const SizedBox(height: 6),
//           Row(
//             children: [
//               Icon(Icons.star_rounded, size: 14, color: color),
//               const SizedBox(width: 4),
//               Text(
//                 subtitle,
//                 style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
