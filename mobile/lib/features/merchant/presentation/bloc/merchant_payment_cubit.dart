import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/money.dart';
import '../../../../core/network/api_exception.dart';
import '../../../wallet/domain/entities/nur_pay_qr.dart';
import '../../../wallet/domain/entities/operation.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';

/// Приём оплаты кассой: сумма набирается до сканирования, потому что QR
/// клиента суммы не содержит.
class MerchantPaymentState {
  const MerchantPaymentState({
    this.amount = Money.zero,
    this.scanned,
    this.result = const [],
    this.busy = false,
    this.error,
  });

  final Money amount;

  /// Последний прочитанный код. Нужен экрану отказа: лимит известен
  /// только из самого QR — сервер в ошибке цифр не присылает.
  final PaymentQr? scanned;

  /// Проводки проведённой оплаты: списание и комиссия.
  final List<Operation> result;

  final bool busy;
  final ApiException? error;

  MerchantPaymentState copyWith({
    Money? amount,
    PaymentQr? scanned,
    List<Operation>? result,
    bool? busy,
    ApiException? error,
    bool clearError = false,
  }) => MerchantPaymentState(
    amount: amount ?? this.amount,
    scanned: scanned ?? this.scanned,
    result: result ?? this.result,
    busy: busy ?? this.busy,
    error: clearError ? null : (error ?? this.error),
  );
}

class MerchantPaymentCubit extends Cubit<MerchantPaymentState> {
  MerchantPaymentCubit(this._wallet) : super(const MerchantPaymentState());

  final WalletRepository _wallet;

  void setAmount(Money amount) => emit(state.copyWith(amount: amount));

  void reset() => emit(const MerchantPaymentState());

  /// Отправляет то, что прочитала камера, как есть: проверка подписи,
  /// срока и лимита — на сервере.
  Future<bool> charge(PaymentQr qr) async {
    emit(state.copyWith(busy: true, scanned: qr, clearError: true));
    try {
      final entries = await _wallet.acceptPayment(qr: qr, amount: state.amount);
      emit(state.copyWith(busy: false, result: entries));
      return true;
    } on ApiException catch (error) {
      emit(state.copyWith(busy: false, error: error));
      return false;
    }
  }
}
