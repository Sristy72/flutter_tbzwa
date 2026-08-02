import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/note_model.dart';
import '../services/bz_pad_api_service.dart';

class BZPadVersionHistoryScreen extends StatefulWidget {
  final String noteId;

  const BZPadVersionHistoryScreen({super.key, required this.noteId});

  @override
  State<BZPadVersionHistoryScreen> createState() =>
      _BZPadVersionHistoryScreenState();
}

class _BZPadVersionHistoryScreenState extends State<BZPadVersionHistoryScreen> {
  final BZPadApiService _api = BZPadApiService();
  List<NoteVersionModel> versions = const [];
  int selectedIndex = -1;
  bool isLoading = true;
  bool isRestoring = false;

  @override
  void initState() {
    super.initState();
    _loadVersions();
  }

  Future<void> _loadVersions() async {
    try {
      final result = await _api.getVersions(widget.noteId);
      if (!mounted) return;
      setState(() {
        versions = result;
        selectedIndex = result.isEmpty ? -1 : 0;
      });
    } catch (error) {
      Get.snackbar(
        'Unable to load history',
        error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _restoreVersion() async {
    if (selectedIndex < 0 || isRestoring) return;
    setState(() => isRestoring = true);
    try {
      final note = await _api.restoreVersion(
        widget.noteId,
        versions[selectedIndex].versionIndex,
      );
      if (mounted) Get.back(result: note);
    } catch (error) {
      Get.snackbar(
        'Unable to restore version',
        error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => isRestoring = false);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    if (day == today) return 'Today ${DateFormat('hh:mm a').format(date)}';
    if (day == today.subtract(const Duration(days: 1))) {
      return 'Yesterday ${DateFormat('hh:mm a').format(date)}';
    }
    return DateFormat('MMM dd, hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLoading) const Center(child: CircularProgressIndicator()),
            ...List.generate(versions.length, (index) {
              final version = versions[index];
              final isSelected = selectedIndex == index;

              return Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: GestureDetector(
                  onTap: () => setState(() => selectedIndex = index),
                  child: Container(
                    width: double.infinity,
                    padding: isSelected
                        ? const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          )
                        : EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: isSelected
                          ? Border.all(
                              color: const Color(0xFF5151EF),
                              width: 1.2,
                            )
                          : null,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatDate(version.createdAt),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF263238),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            version.label,
                            style: TextStyle(
                              fontSize: 14,
                              color: isSelected
                                  ? const Color(0xFF5151EF)
                                  : const Color(0xFF94A3B8),
                              fontWeight: isSelected
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: selectedIndex == -1 || isRestoring
                    ? null
                    : _restoreVersion,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  isRestoring ? "Restoring..." : "Restore Version",
                  style: TextStyle(
                    color: selectedIndex != -1
                        ? const Color(0xFF5151EF)
                        : const Color(0xFF94A3B8),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
