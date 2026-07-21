import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/expense_claim.dart';
import '../services/database_service.dart';
import '../services/json_report_service.dart';
import '../services/notification_service.dart';

class ManagerScreen extends StatefulWidget {
  const ManagerScreen({
    super.key,
    required this.user,
    required this.databaseService,
    required this.reportService,
  });

  final User user;
  final DatabaseService databaseService;
  final JsonReportService reportService;

  @override
  State<ManagerScreen> createState() => _ManagerScreenState();
}

class _ManagerScreenState extends State<ManagerScreen> {
  late Future<List<ExpenseClaim>> _claimsFuture;

  @override
  void initState() {
    super.initState();
    _reloadClaims();
  }

  void _reloadClaims() {
    _claimsFuture = widget.databaseService.allClaims();
  }

  Future<void> _approveClaim(ExpenseClaim claim) async {
    await widget.databaseService.approveClaim(claim.id!);
    await NotificationService.instance.showApprovalNotification(
      claim.claimTitle,
    );
    _showMessage('${claim.claimTitle} approved.');
    setState(_reloadClaims);
  }

  Future<void> _exportReport() async {
    final claims = await widget.databaseService.allClaims();
    if (claims.isEmpty) {
      _showMessage('No claims to export.');
      return;
    }
    final file = await widget.reportService.exportApprovedClaims(
      userId: widget.user.uid,
      claims: claims,
    );
    _showMessage('JSON report exported to ${file.path}');
  }

  Future<void> _showReport() async {
    final report = await widget.reportService.readReport(widget.user.uid);
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('JSON expense report'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(child: SelectableText(report)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => setState(_reloadClaims),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _exportReport,
                  icon: const Icon(Icons.file_upload),
                  label: const Text('Export JSON'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showReport,
                  icon: const Icon(Icons.visibility),
                  label: const Text('View JSON'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
                  child: Center(child: Text('No expense claims available.')),
                );
              }

              return Column(
                children: claims
                    .map(
                      (claim) => _ManagerClaimTile(
                        claim,
                        onApprove: claim.id == null || claim.isApproved
                            ? null
                            : () => _approveClaim(claim),
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

class _ManagerClaimTile extends StatelessWidget {
  const _ManagerClaimTile(this.claim, {required this.onApprove});

  final ExpenseClaim claim;
  final VoidCallback? onApprove;

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
                claim.isApproved ? Icons.verified : Icons.approval,
                color: claim.isApproved ? Colors.green : Colors.blue,
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
                  const SizedBox(height: 4),
                  Text(
                    'Staff: ${claim.userId}',
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  claim.isApproved
                      ? const Chip(label: Text('Approved'))
                      : FilledButton.icon(
                          onPressed: onApprove,
                          icon: const Icon(Icons.check),
                          label: const Text('Approve'),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
