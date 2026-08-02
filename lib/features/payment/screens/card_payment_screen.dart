import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/common/widgets/app_scaffold.dart';
import 'payment_success_screen.dart';

class CardPaymentScreen extends StatefulWidget {
  const CardPaymentScreen({super.key});

  @override
  State<CardPaymentScreen> createState() => _CardPaymentScreenState();
}

class _CardPaymentScreenState extends State<CardPaymentScreen> {
  // Input Controllers initialized with values from the design image
  final TextEditingController _cardNumberController = TextEditingController(
    text: "4242  4242  4242  4242",
  );
  final TextEditingController _expiryDateController = TextEditingController(
    text: "12/28",
  );
  final TextEditingController _cvvController = TextEditingController(
    text: "123",
  );
  final TextEditingController _cardholderController = TextEditingController(
    text: "Kathy Onana",
  );

  // Currency Selection State
  String _selectedCurrency = 'USD';
  final List<String> _currencies = ['USD', 'EUR', 'FCFA'];

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _cardholderController.dispose();
    super.dispose();
  }

  // Get formatted amount based on selected currency
  String _getFormattedAmount() {
    if (_selectedCurrency == 'USD') {
      return '\$35.00';
    } else if (_selectedCurrency == 'EUR') {
      return '€35.00';
    } else {
      return '35.00 FCFA';
    }
  }

  // Get dynamic button text
  String _getButtonText() {
    if (_selectedCurrency == 'USD') {
      return 'Pay \$35.00';
    } else if (_selectedCurrency == 'EUR') {
      return 'Pay €35.00';
    } else {
      return 'Pay 35.00 FCFA';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF263451),
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          "Card Payment",
          style: TextStyle(
            color: Color(0xFF374151),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount Section Title
                  const Text(
                    "Enter Amount",
                    style: TextStyle(
                      color: Color(0xFF1A1A2E),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Amount Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF94A3B8).withOpacity(0.20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(6),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Currency Amount
                        Text(
                          _getFormattedAmount(),
                          style: const TextStyle(
                            color: Color(0xFF1A1A2E),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Currency Selector Pill
                        Container(
                          padding: const EdgeInsets.only(
                            left: 24,
                            right: 24,
                            top: 12,
                            bottom: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF000055).withOpacity(0.20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: _currencies.map((currency) {
                              final isSelected = _selectedCurrency == currency;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCurrency = currency;
                                  });
                                },
                                child: Container(
                                  // duration: const Duration(milliseconds: 100),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Color(0xFFFFFFFF)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withAlpha(12),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Text(
                                    currency,
                                    style: TextStyle(
                                      color: isSelected
                                          ? const Color(0xFF1A1A2E)
                                          : Color(0xFFFFFFFF),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Card Information Group Container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FB),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF94A3B8).withOpacity(0.20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Card Information",
                          style: TextStyle(
                            color: Color(0xFF1A1A2E),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Card Number Field
                        _buildCardField(
                          icon: _buildCardIcon(),
                          label: "Card Number",
                          controller: _cardNumberController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            CardNumberFormatter(),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Expiry Date and CVV Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildCardField(
                                icon: _buildCalendarIcon(),
                                label: "Expiry Date",
                                controller: _expiryDateController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  ExpiryDateFormatter(),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildCardField(
                                icon: _buildCVVIcon(),
                                label: "CVV",
                                controller: _cvvController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(3),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Cardholder Name Field
                        _buildCardField(
                          icon: _buildCardholderIcon(),
                          label: "Cardholder Name",
                          controller: _cardholderController,
                          keyboardType: TextInputType.name,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Pay Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(
                          () => PaymentSuccessScreen(
                            amount: _getFormattedAmount(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5151EF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _getButtonText(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper widget to construct the text field cards exactly as in the mock
  Widget _buildCardField({
    required Widget icon,
    required String label,
    required TextEditingController controller,
    required TextInputType keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF94A3B8).withOpacity(0.20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Icon Container
          Container(width: 36, alignment: Alignment.centerLeft, child: icon),
          const SizedBox(width: 8),

          // Label and Interactive TextFormField
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF1A1A2E),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
                  style: const TextStyle(
                    color: Color(0xFF1A1A2E),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.0,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetIcon(
    String assetPath, {
    double width = 28,
    double height = 18,
  }) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF0F172A), width: 1.5),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      },
    );
  }

  Widget _buildCardIcon() {
    return _buildAssetIcon('assets/images/cardIcon.png', width: 40, height: 40);
  }

  Widget _buildCalendarIcon() {
    return _buildAssetIcon('assets/images/expiry.png', width: 40, height: 40);
  }

  Widget _buildCVVIcon() {
    return _buildAssetIcon('assets/images/cvv.png', width: 40, height: 40);
  }

  Widget _buildCardholderIcon() {
    return _buildAssetIcon('assets/images/cardholder.png', width: 40, height: 40);
  }
}

// Helper formatting inputters for credit cards and dates
class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll(' ', '');
    if (text.length > 16) {
      text = text.substring(0, 16);
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && (i + 1) != text.length) {
        buffer.write('  '); // Double space like image
      }
    }

    var string = buffer.toString();
    return TextEditingValue(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll('/', '');
    if (text.length > 4) {
      text = text.substring(0, 4);
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 1 && text.length > 2) {
        buffer.write('/');
      }
    }

    var string = buffer.toString();
    return TextEditingValue(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
