import 'package:go_router/go_router.dart';

import '../features/home/presentation/home_page.dart';
import '../features/transactions/presentation/new_transaction_page.dart';
import '../features/transactions/presentation/transaction_detail_page.dart';

GoRouter createAppRouter() {
  return GoRouter(
    routes: <RouteBase>[
      GoRoute(path: '/', builder: (context, state) => const HomePage()),
      GoRoute(
        path: '/transaction/new',
        builder: (context, state) {
          final String monthParam =
              state.uri.queryParameters['month'] ?? '2025-07';
          final List<String> parts = monthParam.split('-');
          final int year = int.tryParse(parts.first) ?? 2025;
          final int month = parts.length > 1 ? int.tryParse(parts[1]) ?? 7 : 7;
          return NewTransactionPage(month: DateTime(year, month));
        },
      ),
      GoRoute(
        path: '/transaction/:id',
        builder: (context, state) => TransactionDetailPage(
          transactionId: state.pathParameters['id'] ?? '',
        ),
      ),
    ],
  );
}
