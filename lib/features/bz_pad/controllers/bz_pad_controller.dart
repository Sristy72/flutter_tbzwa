import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/note_model.dart';
import '../services/bz_pad_api_service.dart';

class BZPadController extends GetxController {
  final BZPadApiService _api = BZPadApiService();

  final notes = <NoteModel>[].obs;
  final recentNotes = <NoteModel>[].obs;
  final searchResults = <NoteModel>[].obs;
  final searchText = ''.obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  Timer? _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    loadNotes();
    ever<String>(searchText, _scheduleSearch);
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    super.onClose();
  }

  List<NoteModel> get displayedNotes =>
      searchText.value.trim().isEmpty ? recentNotes : searchResults;

  Future<void> loadNotes() async {
    isLoading.value = true;
    try {
      final result = await _api.getNotes();
      notes.assignAll(result.myNotes);
      recentNotes.assignAll(result.recentNotes);
    } catch (error) {
      _showError('Unable to load notes', error);
    } finally {
      isLoading.value = false;
    }
  }

  void _scheduleSearch(String value) {
    _searchDebounce?.cancel();
    final query = value.trim();
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }
    _searchDebounce = Timer(
      const Duration(milliseconds: 350),
      () => search(query),
    );
  }

  Future<void> search(String query) async {
    try {
      final result = await _api.searchNotes(query);
      if (searchText.value.trim() == query) searchResults.assignAll(result);
    } catch (error) {
      _showError('Unable to search notes', error);
    }
  }

  Future<NoteModel?> getNote(String id) async {
    try {
      return await _api.getNote(id);
    } catch (error) {
      _showError('Unable to open note', error);
      return null;
    }
  }

  Future<bool> saveNote({
    String? id,
    required String title,
    required String content,
  }) async {
    isSaving.value = true;
    try {
      if (id == null) {
        await _api.createNote(title, content);
      } else {
        await _api.updateNote(id, title, content);
      }
      await loadNotes();
      return true;
    } catch (error) {
      _showError('Unable to save note', error);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _api.deleteNote(id);
      notes.removeWhere((note) => note.id == id);
      recentNotes.removeWhere((note) => note.id == id);
      searchResults.removeWhere((note) => note.id == id);
    } catch (error) {
      _showError('Unable to delete note', error);
    }
  }

  void _showError(String title, Object error) {
    Get.snackbar(
      title,
      error.toString().replaceFirst('Exception: ', ''),
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
