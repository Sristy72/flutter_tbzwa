import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bz_pad_controller.dart';
import '../widgets/note_card.dart';
import '../widgets/add_note_card.dart';
import 'bz_pad_editor_screen.dart';

class BZPadHomeScreen extends StatelessWidget {
  const BZPadHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BZPadController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              IconButton(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                  size: 20,
                ),
                onPressed: () => Get.back(),
              ),
              const SizedBox(height: 10),

              // Search Bar
              Container(
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  onChanged: (value) => controller.searchText.value = value,
                  style: const TextStyle(color: Color(0xFF263238)),
                  decoration: const InputDecoration(
                    hintText: "Search notes...",
                    hintStyle: TextStyle(
                      color: Color(0xFF90A4AE),
                      fontSize: 16,
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(left: 15, right: 10),
                      child: Icon(
                        Icons.search,
                        color: Color(0xFF90A4AE),
                        size: 28,
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "My Notes",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF263238),
                ),
              ),
              const SizedBox(height: 16),
              AddNoteCard(onTap: () => Get.to(() => const BZPadEditorScreen())),
              const SizedBox(height: 30),
              const Text(
                "Recent Notes",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF263238),
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (controller.isLoading.value &&
                    controller.displayedNotes.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.displayedNotes.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.displayedNotes.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final note = controller.displayedNotes[index];
                    return NoteCard(
                      note: note,
                      onTap: () async {
                        final fullNote = await controller.getNote(note.id);
                        if (fullNote != null) {
                          Get.to(() => BZPadEditorScreen(note: fullNote));
                        }
                      },
                      onDelete: () => controller.deleteNote(note.id),
                    );
                  },
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAEDF1)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFFF5252), size: 36),

          const SizedBox(height: 16),
          const Text(
            "No Recent Notes",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF263238),
            ),
          ),
        ],
      ),
    );
  }
}
