// Project imports:
import 'backpack_model.dart';

/// A backpack stock picked to ship or exchange, and how many of it.
class ShipmentItemModel {
  final BackpackModel stock;
  int quantity;

  ShipmentItemModel({required this.stock, required this.quantity});

  /// Every piece of [stock].
  ShipmentItemModel.all(this.stock) : quantity = stock.quantity;

  double get totalAmount => stock.amount * quantity;

  /// The stock ids it stands for: the first [quantity] of the stock's.
  List<int> get stockIds =>
      stock.stockIds.take(quantity).map(int.tryParse).nonNulls.toList();
}
