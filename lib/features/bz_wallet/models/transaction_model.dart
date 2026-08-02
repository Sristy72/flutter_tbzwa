
class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final bool isCredit; // true for addition, false for deduction
  final String status;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.isCredit,
    this.status = 'Completed',
  });
}
