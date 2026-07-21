class ExpenseClaim {
  const ExpenseClaim({
    this.id,
    required this.claimTitle,
    required this.category,
    required this.amount,
    required this.userId,
    this.approve = 0,
  });

  final int? id;
  final String claimTitle;
  final String category;
  final double amount;
  final String userId;
  final int approve;

  bool get isApproved => approve == 1;

  ExpenseClaim copyWith({
    int? id,
    String? claimTitle,
    String? category,
    double? amount,
    String? userId,
    int? approve,
  }) {
    return ExpenseClaim(
      id: id ?? this.id,
      claimTitle: claimTitle ?? this.claimTitle,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      userId: userId ?? this.userId,
      approve: approve ?? this.approve,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'claimTitle': claimTitle,
      'category': category,
      'amount': amount,
      'userId': userId,
      'approve': approve,
    };
  }

  factory ExpenseClaim.fromMap(Map<String, dynamic> map) {
    return ExpenseClaim(
      id: map['id'] as int?,
      claimTitle: map['claimTitle'] as String,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      userId: map['userId'] as String,
      approve: map['approve'] as int,
    );
  }
}
