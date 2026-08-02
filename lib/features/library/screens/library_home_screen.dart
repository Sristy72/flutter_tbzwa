import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/library_models.dart';
import '../services/library_api_service.dart';
import 'vocabulary_list_screen.dart';

class LibraryHomeScreen extends StatefulWidget {
  const LibraryHomeScreen({super.key});

  @override
  State<LibraryHomeScreen> createState() => _LibraryHomeScreenState();
}

class _LibraryHomeScreenState extends State<LibraryHomeScreen> {
  final LibraryApiService _libraryApiService = LibraryApiService();
  int _selectedFolderIndex = 0;
  List<LibraryFolder> _folders = const [];
  String _searchQuery = '';
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLibrary();
  }

  Future<void> _loadLibrary() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final folders = await _libraryApiService.getLibraryHome();
      if (!mounted) return;
      setState(() {
        _folders = folders;
        if (_selectedFolderIndex >= folders.length) {
          _selectedFolderIndex = 0;
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _errorMessage = error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  LibraryFolder? get _selectedFolder =>
      _folders.isEmpty ? null : _folders[_selectedFolderIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 30),
              const Text(
                "My Folders",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              _buildFoldersList(),
              const SizedBox(height: 30),

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_errorMessage != null)
                _buildErrorSection()
              else if (_selectedFolder != null) ...[
                _buildVocabularyHeader(
                  "Vocabulary (${_selectedFolder!.totalItems})",
                ),
                const SizedBox(height: 16),
                _buildVocabularyGrid(_selectedFolder!),
              ],

              const SizedBox(height: 30),
            ],
          ),
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
        cursorColor: const Color(0xFF000000),
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

  Widget _buildFoldersList() {
    const folderColors = [
      Color(0xFFE0DEFF),
      Color(0xFFDCFCE7),
      Color(0xFFFCE7F3),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_folders.length, (index) {
          final folder = _folders[index];
          bool isSelected = _selectedFolderIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFolderIndex = index;
              });
            },
            child: Container(
              width: 112,
              height: 100,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: folderColors[index % folderColors.length],
                borderRadius: BorderRadius.circular(16),
                border: isSelected
                    ? Border.all(color: const Color(0xFF4A82E7), width: 2)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.description_outlined, color: Colors.black),
                  const SizedBox(height: 8),
                  Text(
                    folder.label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildVocabularyHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildVocabularyGrid(LibraryFolder folder) {
    final query = _searchQuery.toLowerCase();
    final categories = folder.categories
        .where((category) => category.name.toLowerCase().contains(query))
        .toList();

    if (categories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Text(
            'No vocabulary found.',
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        return GestureDetector(
          onTap: () => Get.to(
            () => VocabularyListScreen(
              category: category.name,
              folder: folder.folder,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFDFF2EE),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF4A82E7), width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Image.asset(
                      _categoryImage(category.name),
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
                //Icon(cat['icon'] as IconData, color: const Color(0xFF1F2937), size: 24),
                const SizedBox(height: 8),
                Text(
                  category.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _categoryImage(String category) {
    const images = {
      'Bathroom Equipment': 'assets/images/bathroom_equipment.png',
      'Bathroom Verbs': 'assets/images/mdi_bathroom.png',
      'Bathroom Actions': 'assets/images/bathroom_actions.png',
      'Professions': 'assets/images/professions.png',
      'Body Actions': 'assets/images/body_actions.png',
      'Furniture': 'assets/images/furniture.png',
      'Small Menu': 'assets/images/menu-small.png',
      'Kitchen': 'assets/images/kitchen.png',
      'Cooking Teams': 'assets/images/cooking_teams.png',
      'Knowledge Disabilities': 'assets/images/disability.png',
      'Common Mistakes': 'assets/images/mistakes.png',
      'Kitchen Verbs': 'assets/images/kitchen-knives.png',
    };
    return images[category] ?? 'assets/images/library.png';
  }

  Widget _buildErrorSection() {
    return Center(
      child: Column(
        children: [
          Text(
            _errorMessage ?? 'Unable to load the library.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
          ),
          TextButton(onPressed: _loadLibrary, child: const Text('Try again')),
        ],
      ),
    );
  }
}
