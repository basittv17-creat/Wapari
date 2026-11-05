import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  test('daily reports include only accounts created within the last 24 hours', () {
    final now = DateTime(2026, 11, 5, 12);
    TradeAccount makeAccount(String id, DateTime createdAt) => TradeAccount(
      id: id, name: id, fatherName: '', address: '', phone: '',
      commodity: 'Wheat', bagWeightKg: 50, bagCount: 2, extraKg: 0,
      rateMode: 'maund', rateValue: 4000, createdAt: createdAt,
    );

    final accounts = [
      makeAccount('inside', now.subtract(const Duration(hours: 23))),
      makeAccount('boundary', now.subtract(const Duration(hours: 24))),
      makeAccount('old', now.subtract(const Duration(hours: 24, minutes: 1))),
      makeAccount('future', now.add(const Duration(minutes: 1))),
    ];

    final result = accountsCreatedInLast24Hours(accounts, now: now);
    expect(result.map((e) => e.id), ['inside', 'boundary']);
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

  test('large transfer payload is split below one MB and can be reassembled', () {
    final original = Uint8List.fromList(List<int>.generate(1600000, (i) => i % 251));
    final chunks = createTransferChunks(original, transferId: 'test-transfer');
    expect(chunks.length, greaterThan(1));
    expect(chunks.every((chunk) => chunk.length < 1000000), isTrue);
    final restored = BytesBuilder(copy: false);
    for (final chunk in chunks) {
      final envelope = jsonDecode(utf8.decode(chunk)) as Map<String, dynamic>;
      expect(envelope['transferId'], 'test-transfer');
      restored.add(base64Decode(envelope['data'] as String));
    }
    expect(restored.takeBytes(), original);
  });

  test('backup merge updates matching ID, adds new accounts, preserves receiver accounts and is idempotent', () async {
    SharedPreferences.setMockInitialValues({});
    final original = TradeAccount(
      id: 'same-id', name: 'Ali', fatherName: '', address: '', phone: '',
      commodity: 'Wheat', bagWeightKg: 50, bagCount: 10, extraKg: 0,
      rateMode: 'kg', rateValue: 100, createdAt: DateTime(2026, 11, 4),
    );
    final unrelated = TradeAccount(
      id: 'receiver-only', name: 'Other', fatherName: '', address: '', phone: '',
      commodity: 'Rice', bagWeightKg: 40, bagCount: 3, extraKg: 0,
      rateMode: 'kg', rateValue: 80, createdAt: DateTime(2026, 11, 3),
    );
    await LocalStore.saveAccount(original);
    await LocalStore.saveAccount(unrelated);
    final newer = TradeAccount(
      id: 'same-id', name: 'Ali', fatherName: '', address: '', phone: '',
      commodity: 'Wheat', bagWeightKg: 50, bagCount: 15, extraKg: 0,
      rateMode: 'kg', rateValue: 100, createdAt: DateTime(2026, 11, 4),
    );
    final added = TradeAccount(id: 'sender-new', name: 'New sender account', fatherName: '', address: '', phone: '', commodity: 'Corn', bagWeightKg: 40, bagCount: 5, extraKg: 0, rateMode: 'kg', rateValue: 90, createdAt: DateTime(2026, 11, 5));
    final backup = jsonEncode({
      'format': 'wapari-backup', 'version': 1, 'batchId': 'batch-1',
      'exportedAt': DateTime(2026, 11, 5).toIso8601String(),
      'accounts': [newer.toJson(), added.toJson()],
    });
    final first = await LocalStore.importBackup(backup);
    expect(first.updated, 1);
    expect(first.added, 1);
    expect((await LocalStore.loadAccounts()).firstWhere((e) => e.id == 'same-id').bagCount, 15);
    expect((await LocalStore.loadAccounts()).any((e) => e.id == 'receiver-only'), isTrue);
    expect((await LocalStore.loadAccounts()).any((e) => e.id == 'sender-new'), isTrue);
    expect((await LocalStore.loadMergeHistory()).length, 1);
    final second = await LocalStore.importBackup(backup);
    expect(second.duplicateBatch, isTrue);
    expect((await LocalStore.loadAccounts()).length, 3);
  });

}
