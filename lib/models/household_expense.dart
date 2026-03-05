class HouseholdExpense {
  final int? id;
  final int dayEntryId;
  final String description;
  final double amount;

  HouseholdExpense({
    this.id,
    required this.dayEntryId,
    required this.description,
    required this.amount,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'day_entry_id': dayEntryId,
        'description': description,
        'amount': amount,
      };

  factory HouseholdExpense.fromMap(Map<String, dynamic> map) => HouseholdExpense(
        id: map['id'],
        dayEntryId: map['day_entry_id'],
        description: map['description'],
        amount: map['amount'],
      );
}
