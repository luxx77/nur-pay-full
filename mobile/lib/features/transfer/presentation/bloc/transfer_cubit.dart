import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/money.dart';
import '../../../../core/network/api_exception.dart';
import '../../../wallet/domain/entities/nur_pay_qr.dart';
import '../../../wallet/domain/entities/operation.dart';
import '../../../wallet/domain/entities/public_user.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';

/// Ход перевода: от отсканированного кода до готового чека.
class TransferState {
  const TransferState({
    this.recipient,
    this.recipientQrUuid,
    this.amount = Money.zero,
    this.result = const [],
    this.busy = false,
    this.error,
  });

  final PublicUser? recipient;
  final String? recipientQrUuid;
  final Money amount;

  /// Проводки проведённого перевода.
  final List<Operation> result;

  final bool busy;
  final ApiException? error;

  TransferState copyWith({
    PublicUser? recipient,
    String? recipientQrUuid,
    Money? amount,
    List<Operation>? result,
    bool? busy,
    ApiException? error,
    bool clearError = false,
  }) => TransferState(
    recipient: recipient ?? this.recipient,
    recipientQrUuid: recipientQrUuid ?? this.recipientQrUuid,
    amount: amount ?? this.amount,
    result: result ?? this.result,
    busy: busy ?? this.busy,
    error: clearError ? null : (error ?? this.error),
  );
}

class TransferCubit extends Cubit<TransferState> {
  TransferCubit(this._wallet) : super(const TransferState());

  final WalletRepository _wallet;

  void reset() => emit(const TransferState());

  /// Кто стоит за кодом. Имя берём у сервера, а не из самого QR: иначе
  /// его можно было бы подменить в коде.
  Future<bool> resolve(StaticQr qr) async {
    emit(state.copyWith(busy: true, clearError: true));
    try {
      final recipient = await _wallet.userByQr(qr.publicQrUuid);
      emit(
        TransferState(recipient: recipient, recipientQrUuid: qr.publicQrUuid),
      );
      return true;
    } on ApiException catch (error) {
      emit(state.copyWith(busy: false, error: error));
      return false;
    }
  }

  void setAmount(Money amount) => emit(state.copyWith(amount: amount));

  Future<bool> submit() async {
    final qrUuid = state.recipientQrUuid;
    if (qrUuid == null) return false;

    emit(state.copyWith(busy: true, clearError: true));
    try {
      final entries = await _wallet.transfer(
        recipientQrUuid: qrUuid,
        amount: state.amount,
      );
      emit(state.copyWith(busy: false, result: entries));
      return true;
    } on ApiException catch (error) {
      emit(state.copyWith(busy: false, error: error));
      return false;
    }
  }
}
