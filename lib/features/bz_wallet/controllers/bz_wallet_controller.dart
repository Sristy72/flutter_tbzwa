import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';


class BZWalletController extends GetxController {
  var balance = 55.0.obs; // Base balance in USD
  var selectedCurrency = "USD".obs;
  var transactions = <TransactionModel>[].obs;
  
  // Conversion rates (mock values based on user screenshots)
  final Map<String, double> rates = {
    'USD': 1.0,
    'EUR': 0.909, // 50 / 55
    'FCFA': 605.0, // 33275 / 55
  };

  var upcomingPayment = {
    'title': 'Immersion++ 3 Months',
    'amount': 100.0,
    'applied': 65.0,
    'final': 35.0,
  }.obs;
  var isLoading = false.obs;

  final String userId = "BZ-234567";

  @override
  void onInit() {
    super.onInit();
    loadMockData();
  }

  String get formattedBalance {
    double converted = balance.value * (rates[selectedCurrency.value] ?? 1.0);
    
    if (selectedCurrency.value == "FCFA") {
      // Format with thousands separator: FCFA 33,275.00
      final formatter = NumberFormat("#,###.00");
      return "FCFA ${formatter.format(converted)}";
    } else if (selectedCurrency.value == "EUR") {
      return "€${converted.toStringAsFixed(2)}";
    } else {
      return "\$${converted.toStringAsFixed(2)}";
    }
  }


  void loadMockData() {
    transactions.value = [
      TransactionModel(
        id: '1',
        title: "Top Up",
        amount: 200.00,
        date: DateTime.now(),
        isCredit: true,
      ),
      TransactionModel(
        id: '2',
        title: "Buy Plan",
        amount: 20.00,
        date: DateTime.now(),
        isCredit: false,
      ),
      TransactionModel(
        id: '3',
        title: "Send Gift",
        amount: 20.00,
        date: DateTime.now(),
        isCredit: false,
      ),
      TransactionModel(
        id: '4',
        title: "Referral",
        amount: 10.00,
        date: DateTime.now(),
        isCredit: true,
      ),
    ];
  }


  void changeCurrency(String currency) {
    selectedCurrency.value = currency;
  }
}
