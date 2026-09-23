import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/money.dart';
import '../../../wallet/domain/entities/nur_pay_qr.dart';

/// Одноразовый платёжный код на экране юзера.
class PaymentQrState {
  const PaymentQrState({required this.limit, this.qr, this.createdAt});

  final Money limit;
  final PaymentQr? qr;
  final DateTime? createdAt;

  /// Сколько код ещё действует.
  Duration remaining(DateTime now) {
    final born = createdAt;
    if (born == null) return Duration.zero;
    final left = PaymentQrCubit.lifetime - now.difference(born);
    return left.isNegative ? Duration.zero : left;
  }

  double progress(DateTime now) =>
      remaining(now).inMilliseconds / PaymentQrCubit.lifetime.inMilliseconds;
}

/// Держит действующий платёжный код и сам обновляет его.
///
/// Сервер считает возраст по времени внутри nonce и не даёт допуска,
/// поэтому код перевыпускается раньше, чем истечёт.
class PaymentQrCubit extends Cubit<PaymentQrState> {
  PaymentQrCubit() : super(const PaymentQrState(limit: Money.zero));

  static const lifetime = Duration(seconds: 30);

  Timer? _timer;

  /// Запускает выпуск кодов с заданным лимитом.
  void start({
    required Money limit,
    required String userId,
    required String paymentSecret,
  }) {
    _timer?.cancel();
    _issue(limit: limit, userId: userId, paymentSecret: paymentSecret);
    _timer = Timer.periodic(
      lifetime,
      (_) => _issue(limit: limit, userId: userId, paymentSecret: paymentSecret),
    );
  }

  void _issue({
    required Money limit,
    required String userId,
    required String paymentSecret,
  }) {
    emit(
      PaymentQrState(
        limit: limit,
        qr: PaymentQr.sign(
          userId: userId,
          maxAmount: limit,
          paymentSecret: paymentSecret,
        ),
        createdAt: DateTime.now(),
      ),
    );
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
