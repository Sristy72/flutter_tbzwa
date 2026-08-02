import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LibraryPhrasesScreen extends StatelessWidget {
  final String title;
  const LibraryPhrasesScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> phrases = [
      {
        'phrase': 'Settle down',
        'signification': 'to agree on sth, come to a decision',
        'example': 'We need to settle down on a price before signing the contract.',
        'exampleFr': '[Nous devons nous mettre d\'accord un prix avant de signer le contrat.]',
      },
      {
        'phrase': 'Back to down',
        'signification': 'To stop defending your opinion or position.',
        'example': 'She finally backed down and apologized.',
        'exampleFr': '[Elle a finalement cédé et s\'est excusée]',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF1F2937), size: 20),
            onPressed: () => Get.back(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: _buildSearchBar(),
            ),
            _buildStickyHeader(title),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: phrases.length,
                itemBuilder: (context, index) => _buildPhraseCard(phrases[index]),
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
      child: const TextField(
        decoration: InputDecoration(
          hintText: "Search verbs or prepositions...",
          hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
          icon: Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildStickyHeader(String title) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF22C55E).withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          "$title you should know",
          style: const TextStyle(color: Color(0xFF166534), fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildPhraseCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(data['phrase'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
              const Icon(Icons.volume_off_outlined, color: Color(0xFF9CA3AF), size: 22),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoBox("Signification:", data['signification'], const Color(0xFFF3F4F6), const Color(0xFF6B7280)),
          const SizedBox(height: 16),
          _buildInfoBox("Example:", data['example'], const Color(0xFFFFFBEB), const Color(0xFFB45309), subText: data['exampleFr']),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String label, String content, Color bgColor, Color textColor, {String? subText}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12, fontStyle: FontStyle.italic)),
          const SizedBox(height: 8),
          Text(content, style: TextStyle(color: textColor.withOpacity(0.8), fontSize: 13, height: 1.4)),
          if (subText != null) ...[
            const SizedBox(height: 8),
            Text(subText, style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 12, height: 1.4)),
          ],
        ],
      ),
    );
  }
}
