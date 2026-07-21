import 'package:flutter/material.dart';

import '../models/expense_claim.dart';

class ClaimForm extends StatefulWidget {
  const ClaimForm({
    super.key,
    required this.userId,
    required this.onSubmit,
    this.initialClaim,
  });

  final String userId;
  final ExpenseClaim? initialClaim;
  final Future<void> Function(ExpenseClaim claim) onSubmit;

  @override
  State<ClaimForm> createState() => _ClaimFormState();
}

class _ClaimFormState extends State<ClaimForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _category = 'Travel';
  bool _isSaving = false;

  static const _categories = ['Travel', 'Entertainment', 'Equipment'];

  @override
  void initState() {
    super.initState();
    final claim = widget.initialClaim;
    if (claim != null) {
      _titleController.text = claim.claimTitle;
      _amountController.text = claim.amount.toStringAsFixed(0);
      _category = claim.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final amount = double.parse(_amountController.text);
    final existing = widget.initialClaim;
    final claim = ExpenseClaim(
      id: existing?.id,
      claimTitle: _titleController.text.trim(),
      category: _category,
      amount: amount,
      userId: widget.userId,
      approve: existing?.approve ?? 0,
    );

    try {
      await widget.onSubmit(claim);
      if (!mounted) return;
      if (existing == null) {
        _titleController.clear();
        _amountController.clear();
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Claim title',
              prefixIcon: Icon(Icons.receipt_long),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Enter a claim title';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(
              labelText: 'Expense category',
              prefixIcon: Icon(Icons.category),
            ),
            items: _categories
                .map(
                  (category) =>
                      DropdownMenuItem(value: category, child: Text(category)),
                )
                .toList(),
            onChanged: (value) => setState(() => _category = value!),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Amount (VND)',
              prefixIcon: Icon(Icons.payments),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              final amount = double.tryParse(value ?? '');
              if (amount == null) return 'Enter a valid amount';
              if (amount < 1000 || amount > 10000000) {
                return 'Amount must be from 1,000 to 10,000,000 VND';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _isSaving ? null : _submit,
            icon: Icon(widget.initialClaim == null ? Icons.add : Icons.save),
            label: Text(
              widget.initialClaim == null ? 'Add claim' : 'Save claim',
            ),
          ),
        ],
      ),
    );
  }
}
