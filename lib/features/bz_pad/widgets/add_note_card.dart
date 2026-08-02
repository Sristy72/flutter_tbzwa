import 'package:flutter/material.dart';

class AddNoteCard extends StatelessWidget {
  final VoidCallback onTap;

  const AddNoteCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEAEDF1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: Color(0xFF90A4AE), size: 40),

            const SizedBox(height: 8),
            const Text(
              "Add New Note",
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF90A4AE),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
