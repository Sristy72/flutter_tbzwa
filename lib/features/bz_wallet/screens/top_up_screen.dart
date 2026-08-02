import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../payment/screens/proof_submitted_screen.dart';

enum TopUpStep { selection, onlineInfo, manualInfo, transferDetails, success }

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  TopUpStep _currentStep = TopUpStep.selection;
  int _selectedTabIndex = 0; // 0 = Online, 1 = Manual
  String _selectedProvider = 'Orange Money';
  final TextEditingController _amountController = TextEditingController(text: "35.00");
  String _selectedCurrency = 'USD';

  void _nextStep(TopUpStep step) {
    setState(() => _currentStep = step);
  }

  void _back() {
    if (_currentStep == TopUpStep.selection) {
      Get.back();
    } else if (_currentStep == TopUpStep.onlineInfo || _currentStep == TopUpStep.manualInfo) {
      setState(() => _currentStep = TopUpStep.selection);
    } else if (_currentStep == TopUpStep.transferDetails) {
      setState(() => _currentStep = TopUpStep.manualInfo);
    } else if (_currentStep == TopUpStep.success) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildBody(),
              ),
            ),
            if (_currentStep != TopUpStep.success) _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    String title = "Transaction";
    if (_currentStep == TopUpStep.onlineInfo) title = "Online Payment";
    if (_currentStep == TopUpStep.manualInfo || _currentStep == TopUpStep.transferDetails) title = "Manual Payment";
    if (_currentStep == TopUpStep.success) title = "Successfully Added";

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
        onPressed: _back,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF1F2937),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentStep) {
      case TopUpStep.selection:
        return _buildSelectionStep();
      case TopUpStep.onlineInfo:
        return _buildOnlineInfoStep();
      case TopUpStep.manualInfo:
        return _buildManualInfoStep();
      case TopUpStep.transferDetails:
        return _buildTransferDetailsStep();
      case TopUpStep.success:
        return _buildSuccessStep();
    }
  }

  // ─── Selection Step ────────────────────────────────────────────────────────

  Widget _buildSelectionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          "Select Payment Method",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
        ),
        const SizedBox(height: 16),
        _buildTabs(),
        const SizedBox(height: 24),
        if (_selectedTabIndex == 0) ...[
          _buildPaymentOption(
            icon: "assets/images/visa.png", // Use placeholder or actual asset if known
            title: "Visa",
            subtitle: "Pay securely with your credit or debit card",
            onTap: () => _nextStep(TopUpStep.onlineInfo),
          ),
          _buildPaymentOption(
            icon: "assets/images/mastercard.png",
            title: "Mastercard",
            subtitle: "Pay securely with your credit or debit card",
            onTap: () => _nextStep(TopUpStep.onlineInfo),
          ),
          _buildPaymentOption(
            icon: "assets/images/paypal.png",
            title: "Paypal",
            subtitle: "Pay with your PayPal account",
            onTap: () => _nextStep(TopUpStep.onlineInfo),
          ),
        ] else ...[
          _buildPaymentOption(
            icon: "assets/images/cash.png",
            title: "Cash Payment",
            subtitle: "Pay in cash at our partner locations",
            onTap: () => _nextStep(TopUpStep.manualInfo),
          ),
          _buildPaymentOption(
            icon: "assets/images/mobile.png",
            title: "Mobile Transfer",
            subtitle: "Pay via mobile money and upload proof",
            onTap: () => _nextStep(TopUpStep.manualInfo),
          ),
        ],
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem("Online Payment", 0),
          ),
          Expanded(
            child: _buildTabItem("Manual Payment", 1),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index) {
    bool isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? const Color(0xFF1F2937) : const Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.network(
                "https://cdn-icons-png.flaticon.com/512/174/174861.png", // Placeholder
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.payment, color: Color(0xFF5151EF)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Online Info Step ────────────────────────────────────────────────────────

  Widget _buildOnlineInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text("Enter Amount", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        _buildAmountInput(),
        const SizedBox(height: 32),
        const Text("Card Information", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        _buildTextField("Card Number", "4242 4242 4242 4242", Icons.credit_card),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildTextField("Expiry Date", "12/28", Icons.calendar_today)),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField("CVV", "123", Icons.lock_outline)),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField("Cardholder Name", "Kathy Onana", Icons.person_outline),
      ],
    );
  }

  Widget _buildAmountInput() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          TextField(
            controller: _amountController,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
            decoration: const InputDecoration(
              border: InputBorder.none,
              prefixText: "\$",
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ["USD", "EUR", "FCFA"].map((curr) {
              bool isSelected = _selectedCurrency == curr;
              return GestureDetector(
                onTap: () => setState(() => _selectedCurrency = curr),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFDCDCFC) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSelected ? const Color(0xFF5151EF) : const Color(0xFFEAEDF1)),
                  ),
                  child: Text(
                    curr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFF5151EF) : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String placeholder, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        //const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF3F4F6)),
          ),
          child: TextField(
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: Color(0xFF374151), fontSize: 16),
              hintText: placeholder,
              hintStyle: const TextStyle(color: Color(0xFFF3F4F6)),
              border: InputBorder.none,
              prefixIcon: Icon(icon, color: const Color(0xFF374151), size: 22),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Manual Info Step ────────────────────────────────────────────────────────

  Widget _buildManualInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text("Enter Amount", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        _buildAmountInput(),
        const SizedBox(height: 32),
        const Text("1. Select Payment Provider", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        _buildProviderOption("Orange Money", "Mobile Transfer", "assets/images/orange.png"),
        const SizedBox(height: 12),
        _buildProviderOption("MTN Mobile Money", "Mobile Transfer", "assets/images/mtn.png"),
      ],
    );
  }

  Widget _buildProviderOption(String name, String type, String icon) {
    bool isSelected = _selectedProvider == name;
    return GestureDetector(
      onTap: () => setState(() => _selectedProvider = name),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? const Color(0xFFF97316) : const Color(0xFFF3F4F6)),
          boxShadow: isSelected ? [BoxShadow(color: const Color(0xFFF97316).withOpacity(0.1), blurRadius: 4)] : [],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.phone_android, color: Colors.orange), // Placeholder
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                  Text(type, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Color(0xFFF97316), size: 20),
          ],
        ),
      ),
    );
  }

  // ─── Transfer Details Step ───────────────────────────────────────────────────

  Widget _buildTransferDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text("2. Transfer Details", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFEAEDF1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Please make your transfer of \$35.00 to the following $_selectedProvider account. Keep your transaction reference and a screenshot of the receipt.",
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280), height: 1.5),
              ),
              const SizedBox(height: 20),
              _buildDetailRow("Amount to pay:", "\$35.00"),
              const SizedBox(height: 12),
              _buildDetailRow("Withdrawal fees:", "\$1.50"),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              _buildDetailRow("Total:", "\$36.50", isBold: true),
              const SizedBox(height: 24),
              const Text("Beneficiary Name", style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
              const Text("TSEBAZE", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text("Phone Number", style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
              Text(
                _selectedProvider == 'Orange Money' ? "+237 6 95 63 20 69" : "+237 6 50 15 63 11",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: isBold ? const Color(0xFF1F2937) : const Color(0xFF6B7280), fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1F2937))),
      ],
    );
  }

  // ─── Success Step ───────────────────────────────────────────────────────────

  Widget _buildSuccessStep() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFDCDCFC),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF5151EF), width: 2),
          ),
          child: const Icon(Icons.check, color: Color(0xFF5151EF), size: 40),
        ),
        const SizedBox(height: 24),
        const Text(
          "Successfully Added",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
        ),
        const SizedBox(height: 40),
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
              const Text("Payment Information", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildDetailRow("Payment Method :", _selectedTabIndex == 0 ? "Visa Card" : _selectedProvider),
              const SizedBox(height: 12),
              _buildDetailRow("Amount :", "\$35.00"),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.arrow_outward, color: Color(0xFFEF4444), size: 20),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Transaction ID : TXN-123456789", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      Text("Date : March 21, 2025 • 10:32 AM", style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(16)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.campaign_outlined, color: Color(0xFFD97706), size: 24),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  "1. Keep your transaction reference and a screenshot/photo of the receipt.\n2. You will need to upload proof of payment for verification.",
                  style: TextStyle(fontSize: 12, color: Color(0xFF92400E), height: 1.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () => Get.back(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5151EF),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text("Submit Proof", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ],
    );
  }

  // ─── Bottom Button ─────────────────────────────────────────────────────────

  Widget _buildBottomButton() {
    String label = "Pay \$35.00";
    VoidCallback? onPressed;

    if (_currentStep == TopUpStep.selection) return const SizedBox.shrink();

    if (_currentStep == TopUpStep.onlineInfo) {
      label = "Pay \$35.00";
      onPressed = () => _nextStep(TopUpStep.success);
    } else if (_currentStep == TopUpStep.manualInfo) {
      label = "Proceed to Transfer";
      onPressed = () => _nextStep(TopUpStep.transferDetails);
    } else if (_currentStep == TopUpStep.transferDetails) {
      label = "I Have Made The Transfer";
      onPressed = () => _nextStep(TopUpStep.success);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5151EF),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}
