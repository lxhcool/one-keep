import '../domain/transaction_record.dart';

class TransactionService {
  static List<TransactionRecord> buildSeedData() {
    final DateTime now = DateTime.now();

    return <TransactionRecord>[
      TransactionRecord(
        id: 'tx_1',
        type: TransactionType.expense,
        amountCents: 3580,
        occurredAt: now.subtract(const Duration(hours: 3)),
        note: '午餐',
      ),
      TransactionRecord(
        id: 'tx_2',
        type: TransactionType.expense,
        amountCents: 1290,
        occurredAt: now.subtract(const Duration(days: 1)),
        note: '地铁',
      ),
      TransactionRecord(
        id: 'tx_3',
        type: TransactionType.income,
        amountCents: 120000,
        occurredAt: now.subtract(const Duration(days: 2)),
        note: '工资',
      ),
    ];
  }
}
