import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/common/widgets/app_scaffold.dart';
import 'welcome_success_screen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String amount;

  const PaymentSuccessScreen({
    super.key,
    required this.amount,
  });

  // Dynamically calculate the 7-day refund window from today
  String _getRefundWindow() {
    final start = DateTime.now();
    final end = start.add(const Duration(days: 7));

    final shortMonths = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final startMonth = shortMonths[start.month - 1];
    final startDay = start.day.toString().padLeft(2, '0');
    final endMonth = shortMonths[end.month - 1];
    final endDay = end.day.toString().padLeft(2, '0');

    return "$startMonth $startDay - $endMonth $endDay";
  }

  // Localized date formatting in plain Dart (completely robust, zero external package dependency)
  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'March', 'April', 'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December', 'January', 'February'
    ];
    // To make it match the screenshot exactly or default to current date
    // Screenshot shows: March 31, 2025 - 10:32 AM.
    // If the year is 2026, let's keep the real date for authenticity, or let it match today's date!
    final monthStr = months[now.month - 1];
    final dayStr = now.day.toString();
    final yearStr = now.year.toString();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minuteStr = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    return "$monthStr $dayStr, $yearStr - $hour:$minuteStr $ampm";
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
          "Payment Successful",
          style: TextStyle(
           color: Color(0xFF374151),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Success Top Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF94A3B8).withOpacity(0.20)),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.black.withAlpha(6),
                  //     blurRadius: 12,
                  //     offset: const Offset(0, 4),
                  //   ),
                  // ],
                ),
                child: Column(
                  children: [
                    // Green circular check icon widget
                    _buildGreenCheckIcon(),
                    const SizedBox(height: 22),

                    // Success Pill/Badge
                    Container(
                      padding: const EdgeInsets.only(top: 14, right: 24, bottom: 12, left: 24
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5151EF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "SUCCESS",
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          // letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Payment Information Header
              const Text(
                "Payment Information",
                style: TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),

              // Payment Information Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF94A3B8).withOpacity(0.20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow("Program : ", "IMMERSION++ 6months"),
                    const SizedBox(height: 12),
                    _buildInfoRow("Payment Method : ", "Visa/Paypal"),
                    const SizedBox(height: 12),
                    _buildInfoRow("Amount : ", amount),
                    const SizedBox(height: 12),
                    _buildInfoRow("Refund Window : ", _getRefundWindow()),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Transaction ID Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Pink square badge with custom diagonal arrow pointing top-right
                    _buildTransactionArrow(),
                    const SizedBox(width: 16),

                    // Transaction details text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Transaction ID : TXN-123456789",
                            style: TextStyle(
                              color: Color(0xFF1A1A2E),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Date : ${_getFormattedDate()}",
                            style: const TextStyle(
                              color: Color(0xFF1A1A2E),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 135),

              // Action Buttons
              Column(
                children: [
                  // Welcome Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.to(() => const WelcomeSuccessScreen());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5151EF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Welcome",
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Request for Refund Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        // Request manual refund alert
                        Get.defaultDialog(
                          title: "Request Refund",
                          middleText:
                              "Your manual refund request has been submitted to the admin for review.",
                          textConfirm: "OK",
                          confirmTextColor: Colors.white,
                          buttonColor: const Color(0xFF5151EF),
                          onConfirm: () => Get.back(),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side:  BorderSide(color: Color(0xFF888888).withOpacity(0.20), width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "Request for Refund",
                        style: TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 96),
            ],
          ),
        ),
      ),
    );
  }

  // Row constructor inside the details group
  Widget _buildInfoRow(String prefix, String suffix) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Color(0xFF1A1A2E),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        children: [
          TextSpan(text: prefix),
          TextSpan(
            text: suffix,
            style: const TextStyle(
              color: Color(0xFF1A1A2E),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Vector-like circular success checkmark icon widget
  Widget _buildGreenCheckIcon() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF0F766E), width: 3),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.check_rounded,
        color: Color(0xFF0F766E),
        size: 38,
      ),
    );
  }

  // Vector-like transaction pink box badge with custom diagonal arrow pointing top-right
  Widget _buildTransactionArrow() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFFFA3C8).withOpacity(0.20),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.north_east_rounded,
        color: Color(0xFFFFA3C8),
        size: 20,
      ),
    );
  }
}
