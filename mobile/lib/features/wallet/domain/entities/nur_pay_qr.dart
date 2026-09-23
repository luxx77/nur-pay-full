import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/money.dart';

/// Содержимое QR-кодов Nur Pay.
///
/// Формат обязан совпадать с бэкендом побайтово: подпись считается по
/// канонической строке `<user_id>.<max_amount>.<nonce>`.
sealed class NurPayQr {
  const NurPayQr();

  static const scheme = 'nurpay';

  /// Читает отсканированный код. `null` — код не наш.
  static NurPayQr? tryParse(String raw) {
    final uri = Uri.tryParse(raw.trim());
    if (uri == null || uri.scheme != scheme) return null;

    final q = uri.queryParameters;
    return switch (uri.host) {
      'user' when q['q'] != null => StaticQr(publicQrUuid: q['q']!),
      'pay' => _parsePayment(q),
      _ => null,
    };
  }

  static PaymentQr? _parsePayment(Map<String, String> q) {
    final userId = q['u'];
    final nonce = q['n'];
    final hash = q['h'];
    final maxAmount = int.tryParse(q['m'] ?? '');
    if (userId == null || nonce == null || hash == null || maxAmount == null) {
      return null;
    }
    return PaymentQr(
      userId: userId,
      maxAmount: Money(maxAmount),
      nonce: nonce,
      hash: hash,
    );
  }

  String encode();
}

/// Постоянный QR: по нему получают переводы.
///
/// Несёт только `public_qr_uuid` — имя владельца спрашивается у сервера,
/// чтобы его нельзя было подменить в самом коде.
class StaticQr extends NurPayQr {
  const StaticQr({required this.publicQrUuid});

  final String publicQrUuid;

  @override
  String encode() => Uri(
    scheme: NurPayQr.scheme,
    host: 'user',
    queryParameters: {'q': publicQrUuid},
  ).toString();
}

/// Одноразовый QR оплаты мерчанту.
class PaymentQr extends NurPayQr {
  const PaymentQr({
    required this.userId,
    required this.maxAmount,
    required this.nonce,
    required this.hash,
  });

  /// Собирает и подписывает новый код.
  ///
  /// `nonce` — uuid v7: время генерации лежит внутри него, по нему
  /// сервер и считает возраст кода.
  factory PaymentQr.sign({
    required String userId,
    required Money maxAmount,
    required String paymentSecret,
  }) {
    final nonce = const Uuid().v7();
    return PaymentQr(
      userId: userId,
      maxAmount: maxAmount,
      nonce: nonce,
      hash: signature(
        userId: userId,
        maxAmount: maxAmount,
        nonce: nonce,
        paymentSecret: paymentSecret,
      ),
    );
  }

  final String userId;
  final Money maxAmount;
  final String nonce;
  final String hash;

  /// HMAC-SHA256 на `payment_secret` по `<user_id>.<max_amount>.<nonce>`.
  /// Сумма — целое в теңңе, результат — hex нижним регистром.
  static String signature({
    required String userId,
    required Money maxAmount,
    required String nonce,
    required String paymentSecret,
  }) => Hmac(
    sha256,
    utf8.encode(paymentSecret),
  ).convert(utf8.encode('$userId.${maxAmount.minor}.$nonce')).toString();

  @override
  String encode() => Uri(
    scheme: NurPayQr.scheme,
    host: 'pay',
    queryParameters: {
      'u': userId,
      'm': '${maxAmount.minor}',
      'n': nonce,
      'h': hash,
    },
  ).toString();
}
