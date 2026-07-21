import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/expense_claim.dart';

class JsonReportService {
  Future<File> reportFileForUser(String userId) async {
    final directory = await getApplicationDocumentsDirectory();
    return File(
      '${directory.path}${Platform.pathSeparator}${userId}_expense_report.json',
    );
  }

  Future<File> exportApprovedClaims({
    required String userId,
    required List<ExpenseClaim> claims,
  }) async {
    final file = await reportFileForUser(userId);
    const encoder = JsonEncoder.withIndent('  ');
    final json = encoder.convert(claims.map((claim) => claim.toMap()).toList());
    return file.writeAsString(json);
  }

  Future<String> readReport(String userId) async {
    final file = await reportFileForUser(userId);
    if (!await file.exists()) {
      return 'No report file has been exported yet.';
    }
    return file.readAsString();
  }
}
