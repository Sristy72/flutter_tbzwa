import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SocialGiftScreen extends StatefulWidget {
  final String recipientName;
  final double amount;

  const SocialGiftScreen({
    super.key,
    required this.recipientName,
    required this.amount,
  });

  @override
  State<SocialGiftScreen> createState() => _SocialGiftScreenState();
}

class _SocialGiftScreenState extends State<SocialGiftScreen> {
  String _selectedCurrency = 'FCFA';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Social Gift",
          style: TextStyle(color: Color(0xFF1F2937), fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Recipient User ID", style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
                    const SizedBox(height: 4),
                    const Text(
                      "BZ#445566",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                    ),
                    const SizedBox(height: 24),
                    const Text("Amount to Send", style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      "€${widget.amount.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Available: €1000.00",
                          style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: ["USD", "EUR", "FCFA"].map((curr) {
                              bool isSelected = _selectedCurrency == curr;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedCurrency = curr),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: isSelected
                                        ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]
                                        : [],
                                  ),
                                  child: Text(
                                    curr,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? const Color(0xFF1F2937) : const Color(0xFF9CA3AF),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.snackbar(
                    "Success",
                    "Gift successfully sent to BZ#445566",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF5151EF),
                    colorText: Colors.white,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5151EF),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text("Send Gift", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
