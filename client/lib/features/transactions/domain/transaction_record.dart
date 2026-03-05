enum TransactionType { income, expense, transfer }

class TransactionRecord {
  const TransactionRecord({
    required this.id,
    required this.type,
    required this.amountCents,
    required this.occurredAt,
    this.note,
  });

  final String id;
  final TransactionType type;
  final int amountCents;
  final DateTime occurredAt;
  final String? note;
}
