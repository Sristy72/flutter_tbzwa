import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/learner_api_service.dart';

class ImmersionEntryScreen extends StatefulWidget {
  final String? learnerName;

  const ImmersionEntryScreen({super.key, this.learnerName});

  @override
  State<ImmersionEntryScreen> createState() => _ImmersionEntryScreenState();
}

class _ImmersionEntryScreenState extends State<ImmersionEntryScreen> {
  final LearnerApiService _learnerApiService = LearnerApiService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _saveImmersion() async {
    final title = _titleController.text.trim();
    final summary = _summaryController.text.trim();
    if (title.isEmpty || summary.isEmpty) {
      Get.snackbar(
        "English Immersion",
        "Title and writing are required.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _learnerApiService.saveImmersionLog(title: title, summary: summary);
      if (!mounted) return;
      _showSuccessDialog();
    } catch (error) {
      if (!mounted) return;
      Get.snackbar(
        "English Immersion",
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _clearInputs() {
    _titleController.clear();
    _summaryController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF374151),
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "English Immersion",
          style: TextStyle(
            color: Color(0xFF374151),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [_buildWritingCard()]),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEBECEE))),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSaving ? null : _clearInputs,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Clear",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveImmersion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF26A69A),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _isSaving ? "Saving..." : "Save",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWritingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel("TITLE"),
          _buildInputField(
            "",
            hint: "Enter title...",
            controller: _titleController,
          ),

          const SizedBox(height: 24),
          _buildFieldLabel("WRITE"),
          _buildInputField(
            "",
            hint:
                "Write a short summery you have seen today's podcast, movie, youtube...",
            maxLines: 12,
            controller: _summaryController,
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Color(0xFF94A3B8),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildInputField(
    String initialValue, {
    String hint = "",
    int maxLines = 1,
    TextEditingController? controller,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: controller != null
          ? TextField(
              controller: controller,
              maxLines: maxLines,
              cursorColor: const Color(0xFF374151),
              style: const TextStyle(color: Color(0xFF334155), fontSize: 16),
              decoration: InputDecoration.collapsed(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            )
          : initialValue.isNotEmpty
          ? Text(
              initialValue,
              style: const TextStyle(color: Color(0xFF334155), fontSize: 16),
            )
          : Text(
              hint,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
                height: 1.5,
              ),
            ),
    );
  }

  void _showSuccessDialog() {
    final rawName = widget.learnerName?.trim();
    final name = rawName == null || rawName.isEmpty ? "Learner" : rawName;

    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFFF0FDFA),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF26A69A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Great job, $name!",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "You've completed today's english immersion.\nKeep up the consistency!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Get.back(result: true);
                  Get.back(result: true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF26A69A),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
