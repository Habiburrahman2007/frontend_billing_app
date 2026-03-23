import 'package:flutter/material.dart';
import '../../../../services/transaction_service.dart';
import '../../data/models/transaction_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/currency_formatter.dart';
import 'package:intl/intl.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  final TransactionService _transactionService = TransactionService();
  late Future<List<TransactionModel>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _transactionsFuture = _transactionService.getTransactions();
  }

  void _refresh() {
    setState(() {
      _transactionsFuture = _transactionService.getTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi', 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<TransactionModel>>(
        future: _transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Gagal memuat transaksi: ${snapshot.error}', 
                        textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _refresh,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final transactions = snapshot.data ?? [];
          if (transactions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                   SizedBox(height: 16),
                   Text('Belum ada transaksi', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final tx = transactions[index];
              final dateStr = tx.createdAt != null 
                  ? DateFormat('dd MMM yyyy, HH:mm').format(tx.createdAt!)
                  : 'Tanggal tidak diketahui';

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.receipt_long, color: AppTheme.primaryColor, size: 20),
                    ),
                    title: Text(
                      'ID: ${tx.id ?? 'N/A'}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Text(
                      dateStr,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    trailing: Text(
                      CurrencyFormatter.format(tx.totalAmount),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: AppTheme.primaryColor,
                        fontSize: 14
                      ),
                    ),
                    children: [
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 8),
                            ...tx.items.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item.productName} x${item.quantity}',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(item.subtotal),
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            )),
                            if (tx.note.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              const Divider(),
                              const SizedBox(height: 4),
                              Text('Catatan: ${tx.note}', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey[600])),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
