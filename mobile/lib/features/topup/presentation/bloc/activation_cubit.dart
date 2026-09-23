import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../wallet/domain/entities/operation.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';

/// Пополнение кодом активации.
class ActivationState {
  const ActivationState({
    this.result = const [],
    this.busy = false,
    this.error,
  });

  /// Проводки зачисления и комиссии.
  final List<Operation> result;

  final bool busy;
  final ApiException? error;
}

class ActivationCubit extends Cubit<ActivationState> {
  ActivationCubit(this._wallet) : super(const ActivationState());

  final WalletRepository _wallet;

  /// Номинал карты известен только после погашения: спрашивать его
  /// заранее нельзя, иначе коды можно было бы перебирать, не тратя.
  Future<bool> activate(String code) async {
    emit(const ActivationState(busy: true));
    try {
      final entries = await _wallet.activate(code);
      emit(ActivationState(result: entries));
      return true;
    } on ApiException catch (error) {
      emit(ActivationState(error: error));
      return false;
    }
  }
}
