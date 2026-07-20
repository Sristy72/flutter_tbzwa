import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/common/widgets/app_scaffold.dart';
import 'card_payment_screen.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  // 0 = Online Payment, 1 = Manual Payment
  int _selectedTab = 0;

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
          "Payment Method",
          style: TextStyle(
            color: Color(0xFF374151),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Payment Method",
              style: TextStyle(
                color: Color(0xFF1A1A2E),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),

            /// Custom Segmented Tab Selector
            Container(
              height: 48,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8E8E8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTab = 0;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _selectedTab == 0
                              ? Colors.white
                              : Color(0xFFE8E8E8),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _selectedTab == 0
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
                          "Online Payment",
                          style: TextStyle(
                            color: const Color(0xFF1A1A2E),
                            fontSize: 16,
                            fontWeight: _selectedTab == 0
                                ? FontWeight.w500
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTab = 1;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _selectedTab == 1
                              ? Colors.white
                              : Color(0xFFE8E8E8),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _selectedTab == 1
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
                          "Manual Payment",
                          style: TextStyle(
                            color: const Color(0xFF1A1A2E),
                            fontSize: 16,
                            fontWeight: _selectedTab == 1
                                ? FontWeight.w500
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            /// Payment Methods List or Manual Payment Content
            Expanded(
              child: _selectedTab == 0
                  ? ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildPaymentMethodCard(
                          logo: Image.asset(
                            'assets/images/visa.png',
                            width: 50,
                            height: 30,
                            fit: BoxFit.contain,
                          ),
                          title: "Visa",
                          subtitle:
                              "Pay securely with your credit or debit card",
                          onTap: () {
                            Get.to(() => const CardPaymentScreen());
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildPaymentMethodCard(
                          logo: Image.asset(
                            'assets/images/card.png',
                            width: 50,
                            height: 30,
                            fit: BoxFit.contain,
                          ),
                          title: "Mastercard",
                          subtitle:
                              "Pay securely with your credit or debit card",
                          onTap: () {
                            Get.to(() => const CardPaymentScreen());
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildPaymentMethodCard(
                          logo: Image.asset(
                            'assets/images/paypal.png',
                            width: 50,
                            height: 30,
                            fit: BoxFit.contain,
                          ),
                          title: "Paypal",
                          subtitle: "Pay with your PayPal account",
                          onTap: () {
                            // Proceed with Paypal payment
                          },
                        ),
                      ],
                    )
                  : _buildManualPaymentContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard({
    required Widget logo,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            // Styled Logo container
            Container(width: 50, alignment: Alignment.center, child: logo),
            const SizedBox(width: 20),
            // Title and Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManualPaymentContent() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _buildPaymentMethodCard(
          logo: _buildCashPaymentIcon(),
          title: "Cash Payment",
          subtitle: "Pay in cash at our partner locations",
          onTap: () {
            // Proceed with Cash payment
          },
        ),
        const SizedBox(height: 16),
        _buildPaymentMethodCard(
          logo: _buildMobileTransferIcon(),
          title: "Mobile Transfer",
          subtitle: "Pay via mobile money and upload proof",
          onTap: () {
            // Proceed with Mobile Transfer
          },
        ),
      ],
    );
  }

  Widget _buildCashPaymentIcon() {
    return Container(
      // width: 44,
      // height: 44,
      // decoration: BoxDecoration(
      //   color: const Color(0xFFF1F5F9),
      //   borderRadius: BorderRadius.circular(10),
      // ),
      child: Image.asset(
        'assets/images/cash.png',
        width: 40,
        height: 40,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildMobileTransferIcon() {
    return Container(
      width: 44,
      height: 44,
      // decoration: BoxDecoration(
      //   color: const Color(0xFFF1F5F9),
      //   borderRadius: BorderRadius.circular(10),
      // ),
      child: Image.asset(
        'assets/images/mobile.png',
        width: 40,
        height: 40,
        fit: BoxFit.contain,
      ),
    );
  }
}
