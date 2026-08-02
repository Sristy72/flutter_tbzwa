import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/library_models.dart';
import '../services/library_api_service.dart';

class VocabularyListScreen extends StatefulWidget {
  final String category;
  final String folder;

  const VocabularyListScreen({
    super.key,
    required this.category,
    required this.folder,
  });

  @override
  State<VocabularyListScreen> createState() => _VocabularyListScreenState();
}

class _VocabularyListScreenState extends State<VocabularyListScreen> {
  final LibraryApiService _libraryApiService = LibraryApiService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<LibraryItem> _words = const [];
  String _searchQuery = '';
  String? _errorMessage;
  String? _playingItemId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playingItemId = null);
    });
    _loadWords();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadWords() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final words = await _libraryApiService.getItems(
        folder: widget.folder,
        category: widget.category,
      );
      if (!mounted) return;
      setState(() => _words = words);
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _errorMessage = error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<LibraryItem> get _filteredWords {
    final query = _searchQuery.toLowerCase();
    if (query.isEmpty) return _words;
    return _words.where((item) {
      return item.word.toLowerCase().contains(query) ||
          item.translation.toLowerCase().contains(query) ||
          item.definition.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _playPronunciation(LibraryItem item) async {
    if (item.audioUrl.isEmpty) {
      Get.snackbar(
        'Audio unavailable',
        'No pronunciation audio has been added for ${item.word}.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      await _audioPlayer.stop();
      if (mounted) setState(() => _playingItemId = item.id);
      await _audioPlayer.play(UrlSource(item.audioUrl));
    } catch (_) {
      if (mounted) setState(() => _playingItemId = null);
      Get.snackbar(
        'Unable to play audio',
        'Please check your connection and try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF263451),
                    size: 20,
                  ),
                  onPressed: () => Get.back(),
                ),
                Expanded(child: _buildSearchBar()),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildSectionHeader(widget.category),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_errorMessage != null)
                    _buildErrorSection()
                  else if (_filteredWords.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          'No vocabulary found.',
                          style: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                  else
                    ..._filteredWords.map(_buildWordCard),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value.trim()),
        cursorColor: const Color(0xFF989494),
        style: const TextStyle(color: Color(0xFF000000)),
        decoration: const InputDecoration(
          hintText: "Search vocabulary...",
          hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
          icon: Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFF1F2937),
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildWordCard(LibraryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                item.word,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _playPronunciation(item),
                child: Icon(
                  _playingItemId == item.id
                      ? Icons.volume_up
                      : Icons.volume_up_outlined,
                  color: const Color(0xFF5151EF),
                  size: 20,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFD1D5DB).withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  item.tag,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            item.phonetic,
            style: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 8),
          Text(
            item.translation,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF5151EF),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              item.example.isEmpty ? item.definition : '“${item.example}”',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4B5563),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFF3F4F6)),
        ],
      ),
    );
  }

  Widget _buildErrorSection() {
    return Center(
      child: Column(
        children: [
          Text(
            _errorMessage ?? 'Unable to load vocabulary.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
          ),
          TextButton(onPressed: _loadWords, child: const Text('Try again')),
        ],
      ),
    );
  }
}
