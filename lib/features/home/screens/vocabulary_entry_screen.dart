import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/learner_api_models.dart';
import '../services/learner_api_service.dart';

class VocabularyEntryScreen extends StatefulWidget {
  final List<VocabularyWord> existingWords;
  final VocabularyWord? selectedWord;
  final String? learnerName;

  const VocabularyEntryScreen({
    super.key,
    this.existingWords = const [],
    this.selectedWord,
    this.learnerName,
  });

  @override
  State<VocabularyEntryScreen> createState() => _VocabularyEntryScreenState();
}

class _VocabularyEntryScreenState extends State<VocabularyEntryScreen> {
  final LearnerApiService _learnerApiService = LearnerApiService();
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _definitionController = TextEditingController();
  final TextEditingController _exampleOneController = TextEditingController();
  final TextEditingController _exampleTwoController = TextEditingController();
  bool _isSaving = false;

  bool get _isViewingCompleted => widget.selectedWord != null;

  @override
  void dispose() {
    _wordController.dispose();
    _definitionController.dispose();
    _exampleOneController.dispose();
    _exampleTwoController.dispose();
    super.dispose();
  }

  Future<void> _saveVocabulary() async {
    final word = _wordController.text.trim();
    final definition = _definitionController.text.trim();
    if (word.isEmpty || definition.isEmpty) {
      Get.snackbar(
        "Vocabulary",
        "Word and definition are required.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _learnerApiService.saveVocabularyWord(
        word: word,
        definition: definition,
        exampleSentences: [
          _exampleOneController.text,
          _exampleTwoController.text,
        ],
      );
      if (!mounted) return;
      _showSuccessDialog();
    } catch (error) {
      if (!mounted) return;
      Get.snackbar(
        "Vocabulary",
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _clearInputs() {
    _wordController.clear();
    _definitionController.clear();
    _exampleOneController.clear();
    _exampleTwoController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final cards = _isViewingCompleted
        ? [widget.selectedWord!]
        : widget.existingWords;

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
          "Vocabulary",
          style: TextStyle(
            color: Color(0xFF374151),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ...cards.asMap().entries.map((entry) {
              final examples = entry.value.exampleSentences;
              final cardIndex = _isViewingCompleted
                  ? _completedWordIndex(entry.value)
                  : entry.key + 1;
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _buildWordCard(
                  index: cardIndex,
                  word: entry.value.word,
                  definition: entry.value.definition,
                  examples: [
                    examples.isNotEmpty ? examples[0] : "",
                    examples.length > 1 ? examples[1] : "",
                  ],
                  isCompleted: true,
                ),
              );
            }),
            if (!_isViewingCompleted)
              _buildWordCard(
                index: widget.existingWords.length + 1,
                word: "",
                definition: "",
                examples: const ["", ""],
                isCompleted: false,
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _isViewingCompleted
          ? null
          : Container(
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
                        side: const BorderSide(color: Color(0xFF94A3B8)),
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
                      onPressed: _isSaving ? null : _saveVocabulary,
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

  int _completedWordIndex(VocabularyWord word) {
    final index = widget.existingWords.indexWhere((item) => item.id == word.id);
    return index < 0 ? 1 : index + 1;
  }

  Widget _buildWordCard({
    required int index,
    required String word,
    required String definition,
    required List<String> examples,
    bool isCompleted = false,
  }) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Word $index",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Completed",
                    style: TextStyle(
                      color: Color(0xFF26A69A),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          _buildFieldLabel("WORD"),
          _buildInputField(
            word,
            hint: "Enter Word...",
            controller: isCompleted ? null : _wordController,
          ),

          const SizedBox(height: 16),
          _buildFieldLabel("DEFINITION"),
          _buildInputField(
            definition,
            hint: "What does it mean?",
            maxLines: 3,
            controller: isCompleted ? null : _definitionController,
          ),

          const SizedBox(height: 16),
          _buildFieldLabel("EXAMPLE SENTENCES"),
          _buildInputField(
            examples[0],
            hint: "1. First sentence",
            controller: isCompleted ? null : _exampleOneController,
          ),
          const SizedBox(height: 8),
          _buildInputField(
            examples[1],
            hint: "2. Second sentence",
            controller: isCompleted ? null : _exampleTwoController,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              style: const TextStyle(color: Color(0xFF334155), fontSize: 15),
              decoration: InputDecoration.collapsed(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 14,
                ),
              ),
            )
          : initialValue.isNotEmpty
          ? Text(
              initialValue,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF334155), fontSize: 15),
            )
          : Text(
              hint,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
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
                "You've completed today's vocabulary task.\nKeep up the consistency!",
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
