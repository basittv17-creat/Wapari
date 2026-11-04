import 'package:flutter_test/flutter_test.dart';
import 'package:wapari/main.dart';

void main() {
  test('converts sack weight, extra kilos, maunds and price correctly', () {
    final account = TradeAccount(
      id: 'test-1',
      name: 'محمد علی',
      fatherName: 'احمد علی',
      address: '',
      phone: '',
      commodity: 'Wheat',
      bagWeightKg: 50,
      bagCount: 10,
      extraKg: 25,
      rateMode: 'kg',
      rateValue: 220,
      createdAt: DateTime(2026, 11, 4),
    );

    expect(account.totalBagWeight, 500);
    expect(account.totalWeight, 525);
    expect(account.maunds, 13);
    expect(account.remainingKg, 5);
    expect(account.kgRate, 220);
    expect(account.maundRate, 8800);
    expect(account.totalPrice, 115500);
  });

  test('maund rate is converted to the equivalent per kg rate', () {
    final account = TradeAccount(
      id: 'test-2',
      name: 'Test',
      fatherName: '',
      address: '',
      phone: '',
      commodity: 'Rice',
      bagWeightKg: 40,
      bagCount: 1,
      extraKg: 0,
      rateMode: 'maund',
      rateValue: 700,
      createdAt: DateTime(2026, 11, 4),
    );

    expect(account.kgRate, 17.5);
    expect(account.maundRate, 700);
    expect(account.totalPrice, 700);
  });
}
