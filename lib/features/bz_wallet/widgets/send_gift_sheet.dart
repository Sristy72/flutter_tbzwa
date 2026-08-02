import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screens/social_gift_screen.dart';

class SendGiftSheet extends StatefulWidget {
  const SendGiftSheet({super.key});

  @override
  State<SendGiftSheet> createState() => _SendGiftSheetState();
}

class _SendGiftSheetState extends State<SendGiftSheet> {
  int _selectedReceiverIndex = 0;
  int _selectedGiftIndex = -1;

  final List<Map<String, String>> _receivers = [
    {'name': 'Brandie', 'avatar': 'https://i.pravatar.cc/150?u=b1', 'flag': '🇺🇸'},
    {'name': 'Kristin', 'avatar': 'https://i.pravatar.cc/150?u=k1', 'flag': '🇬🇭'},
    {'name': 'Esther', 'avatar': 'https://i.pravatar.cc/150?u=e1', 'flag': '🇳🇬'},
    {'name': 'Gladys', 'avatar': 'https://i.pravatar.cc/150?u=g1', 'flag': '🇱🇷'},
  ];

  final List<Map<String, dynamic>> _gifts = [
    {'name': 'Star', 'price': 1, 'emoji': '⭐'},
    {'name': 'Coffee', 'price': 2, 'emoji': '☕'},
    {'name': 'Donut', 'price': 3, 'emoji': '🍩'},
    {'name': 'Flower', 'price': 4, 'emoji': '🌸'},
    {'name': 'Rose', 'price': 5, 'emoji': '🌹'},
    {'name': 'Cake', 'price': 6, 'emoji': '🍰'},
    {'name': 'Pizza', 'price': 7, 'emoji': '🍕'},
    {'name': 'Ice Cream', 'price': 8, 'emoji': '🍦'},
    {'name': 'Chocolate', 'price': 9, 'emoji': '🍫'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildReceiverSection(),
                const SizedBox(height: 32),
                _buildAmountSection(),
                const SizedBox(height: 16),
                Expanded(child: _buildGiftGrid()),
                const SizedBox(height: 100), // Space for bottom button
              ],
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFF3F4F6), shape: BoxShape.circle),
                child: const Icon(Icons.close, size: 20, color: Color(0xFF1F2937)),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 30,
            child: ElevatedButton(
              onPressed: _selectedGiftIndex != -1
                  ? () {
                      Navigator.pop(context);
                      Get.to(() => SocialGiftScreen(
                            recipientName: _receivers[_selectedReceiverIndex]['name']!,
                            amount: _gifts[_selectedGiftIndex]['price'].toDouble(),
                          ));
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5151EF),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text("Send Gift", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      "Select Gift Receiver",
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1F2937),
      ),
    );
  }

  Widget _buildReceiverSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...List.generate(_receivers.length, (index) {
            bool isSelected = _selectedReceiverIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedReceiverIndex = index),
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: isSelected ? const Color(0xFF5151EF) : Colors.transparent, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(_receivers[index]['avatar']!),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          bottom: 0,
                          child: Text(_receivers[index]['flag']!, style: const TextStyle(fontSize: 14)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _receivers[index]['name']!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(color: Color(0xFF5151EF), shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: const Text("7+", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                const Text("More", style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Select an amount",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: const Color(0xFF5151EF), borderRadius: BorderRadius.circular(20)),
          child: const Row(
            children: [
              Text("Search", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              SizedBox(width: 4),
              Icon(Icons.search, color: Colors.white, size: 14),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGiftGrid() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: _gifts.length,
      itemBuilder: (context, index) {
        bool isSelected = _selectedGiftIndex == index;
        return GestureDetector(
          onTap: () => setState(() => _selectedGiftIndex = index),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEBEBFF).withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isSelected ? const Color(0xFF5151EF) : Colors.transparent, width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_gifts[index]['emoji'], style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 8),
                Text(
                  "\$${_gifts[index]['price']}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1F2937)),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFF5151EF), borderRadius: BorderRadius.circular(8)),
                  child: const Text("Send", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
