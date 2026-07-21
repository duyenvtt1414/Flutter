import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/expense_claim.dart';
import '../services/database_service.dart';
import '../widgets/claim_form.dart';

class StaffScreen extends StatefulWidget {
  const StaffScreen({
    super.key,
    required this.user,
    required this.databaseService,
  });

  final User user;
  final DatabaseService databaseService;

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  late Future<List<ExpenseClaim>> _claimsFuture;

  String get _userId => widget.user.uid;

  @override
  void initState() {
    super.initState();
    _reloadClaims();
  }

  void _reloadClaims() {
    _claimsFuture = widget.databaseService.claimsForStaff(_userId);
  }

  Future<void> _saveClaim(ExpenseClaim claim) async {
    if (claim.id == null) {
      await widget.databaseService.insertClaim(claim);
      _showMessage('Expense claim added.');
    } else {
      await widget.databaseService.updateClaim(claim);
      if (mounted) Navigator.of(context).pop();
      _showMessage('Expense claim updated.');
    }
    setState(_reloadClaims);
  }

  Future<void> _deleteClaim(ExpenseClaim claim) async {
    await widget.databaseService.deleteClaim(claim);
    _showMessage('Expense claim deleted.');
    setState(_reloadClaims);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openEditSheet(ExpenseClaim claim) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: ClaimForm(
            userId: _userId,
            initialClaim: claim,
            onSubmit: _saveClaim,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => setState(_reloadClaims),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClaimForm(userId: _userId, onSubmit: _saveClaim),
          const SizedBox(height: 24),
          Text(
            'Submitted claims',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<ExpenseClaim>>(
            future: _claimsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final claims = snapshot.data ?? [];
              if (claims.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text('No expense claims submitted yet.'),
                  ),
                );
              }

              return Column(
                children: claims
                    .map(
                      (claim) => _StaffClaimTile(
                        claim: claim,
                        onEdit: claim.isApproved
                            ? null
                            : () => _openEditSheet(claim),
                        onDelete: claim.isApproved
                            ? null
                            : () => _deleteClaim(claim),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StaffClaimTile extends StatelessWidget {
  const _StaffClaimTile({
    required this.claim,
    required this.onEdit,
    required this.onDelete,
  });

  final ExpenseClaim claim;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Icon(
                claim.isApproved ? Icons.verified : Icons.pending_actions,
                color: claim.isApproved ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    claim.claimTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${claim.category} - ${claim.amount.toStringAsFixed(0)} VND',
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      claim.isApproved ? 'Approved / Locked' : 'Pending',
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Edit claim',
              onPressed: onEdit,
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              tooltip: 'Delete claim',
              onPressed: onDelete,
              icon: const Icon(Icons.delete),
            ),
          ],
        ),
      ),
    );
  }
}
