// Project imports:
import '../utils/parser.dart';

/// A top-up package, from the topup-bonus-listing API: pay [amount] (in the
/// player's currency), get [creditedAmount] pts, [bonusAmount] of them the
/// [rate]% bonus.
class TopupBonusModel {
  int? id;
  double amount = 0;

  /// Bonus percentage, e.g. 5 for +5%.
  double rate = 0;
  double bonusAmount = 0;
  double creditedAmount = 0;

  TopupBonusModel.fromJson(Map<String, dynamic> json) {
    id = int.tryParse('${json['id']}');
    amount = parseDouble(json['amount']);
    rate = parseDouble(json['rate']);
    bonusAmount = parseDouble(json['bonus_amount']);
    creditedAmount = parseDouble(json['credited_amount']);
  }

  /// Stand-in values for the page's loading skeleton.
  TopupBonusModel.placeholder() {
    amount = 100;
    rate = 5;
    bonusAmount = 100;
    creditedAmount = 2100;
  }

  /// The packages in an API `data` list; anything that isn't one is skipped.
  static List<TopupBonusModel> listFromJson(dynamic data) => data is List
      ? [
          for (final item in data)
            if (item is Map)
              TopupBonusModel.fromJson(Map<String, dynamic>.from(item)),
        ]
      : [];
}
