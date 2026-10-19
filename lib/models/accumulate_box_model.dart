// Project imports:
import '../utils/parser.dart';
import 'sub_product_model.dart';

/// One level of the top-up rewards, from the accumulate-box-listing API:
/// topping up [requiredTopupAmount] in all unlocks its blind box, [image],
/// and the prizes it can give, [subProducts].
class AccumulateBoxModel {
  bool isAvailable = false;

  /// Not reached yet: less than [requiredTopupAmount] topped up.
  bool isLocked = true;
  double requiredTopupAmount = 0;

  /// All the player's top-ups so far.
  double currentTopupAmount = 0;
  String? image;
  int? mainProductId;
  String? name;
  List<SubProductModel> subProducts = [];

  AccumulateBoxModel.fromJson(Map<String, dynamic> json) {
    isAvailable = parseBool(json['is_available']);
    isLocked = parseBool(json['is_locked'], true);
    requiredTopupAmount = parseDouble(json['required_topup_amount']);
    currentTopupAmount = parseDouble(json['current_topup_amount']);
    image = json['accumulate_box_image']?.toString();

    final dynamic mainProduct = json['main_product'];
    if (mainProduct is Map) {
      mainProductId = int.tryParse('${mainProduct['id']}');
      name = mainProduct['name']?.toString();
      subProducts = SubProductModel.listFromJson(mainProduct['sub_products']);
    }
  }

  /// Stand-in values for the page's loading skeleton.
  AccumulateBoxModel.placeholder() {
    requiredTopupAmount = 1000;
    currentTopupAmount = 500;
    subProducts = List.generate(4, (_) => SubProductModel.placeholder());
  }

  /// Reached and still to claim.
  bool get canClaim => isAvailable && !isLocked;

  /// How far [currentTopupAmount] is towards [requiredTopupAmount], 0 to 1.
  double get progress => requiredTopupAmount <= 0
      ? 1
      : (currentTopupAmount / requiredTopupAmount).clamp(0, 1).toDouble();

  /// The levels in an API list, or in its `listing`; anything that isn't
  /// one is skipped.
  static List<AccumulateBoxModel> listFromJson(dynamic data) {
    final dynamic list = data is Map ? data['listing'] : data;

    return list is List
        ? [
            for (final item in list)
              if (item is Map)
                AccumulateBoxModel.fromJson(Map<String, dynamic>.from(item)),
          ]
        : [];
  }
}
