import 'package:flutter/material.dart';

import '../../home/application/home_snapshot_service.dart';

class NewTransactionPage extends StatefulWidget {
  const NewTransactionPage({super.key, required this.month});

  final DateTime month;

  @override
  State<NewTransactionPage> createState() => _NewTransactionPageState();
}

class _NewTransactionPageState extends State<NewTransactionPage> {
  final HomeSnapshotService _snapshotService = const HomeSnapshotService();
  final TextEditingController _nameController = TextEditingController(
    text: '午饭',
  );
  final TextEditingController _amountController = TextEditingController(
    text: '12.5',
  );

  bool _isIncome = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final String name = _nameController.text.trim();
    final double? amount = double.tryParse(_amountController.text.trim());

    if (name.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请填写有效的名称和金额')));
      return;
    }

    setState(() {
      _saving = true;
    });

    await _snapshotService.createTransaction(
      month: widget.month,
      name: name,
      amount: amount,
      isIncome: _isIncome,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _saving = false;
    });

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('新增流水')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<bool>(
              key: ValueKey<bool>(_isIncome),
              initialValue: _isIncome,
              items: const [
                DropdownMenuItem(value: false, child: Text('支出')),
                DropdownMenuItem(value: true, child: Text('收入')),
              ],
              onChanged: _saving
                  ? null
                  : (bool? value) {
                      setState(() {
                        _isIncome = value ?? false;
                      });
                    },
              decoration: const InputDecoration(labelText: '类型'),
            ),
            TextField(
              controller: _nameController,
              enabled: !_saving,
              decoration: const InputDecoration(labelText: '名称'),
            ),
            TextField(
              controller: _amountController,
              enabled: !_saving,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: '金额'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? '保存中...' : '保存'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
