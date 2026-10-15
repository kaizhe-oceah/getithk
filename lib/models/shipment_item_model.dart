// Project imports:
import 'backpack_model.dart';

/// A backpack stock picked to ship, and how many of it.
class ShipmentItemModel {
  final BackpackModel stock;
  int quantity;

  ShipmentItemModel({required this.stock, required this.quantity});

  double get totalAmount => stock.amount * quantity;
}
