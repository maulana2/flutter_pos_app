import 'package:pos_app/app/data/models/product_model.dart';
import 'package:pos_app/app/modules/checkout/controllers/checkout_controller.dart';

class TransactionModel {
  final String id;
  final DateTime date;
  final Map<Product, int> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double grandTotal;
  final PaymentMethod paymentMethod;
  final double cashAmount;
  final double cashChange;
  final OrderType orderType;
  final String notes;

  TransactionModel({
    required this.id,
    required this.date,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.grandTotal,
    required this.paymentMethod,
    required this.cashAmount,
    required this.cashChange,
    required this.orderType,
    required this.notes,
  });
}
