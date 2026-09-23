import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/money.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/operation.dart';
import '../../domain/repositories/wallet_repository.dart';

/// Баланс и история — то, что показывают главный экран и вкладка истории.
class WalletState {
  const WalletState({
    this.balance,
    this.operations = const [],
    this.loading = false,
    this.error,
  });

  /// `null`, пока баланс ни разу не загрузили.
  final Money? balance;

  final List<Operation> operations;
  final bool loading;
  final ApiException? error;

  bool get isEmpty => balance == null && operations.isEmpty;

  WalletState copyWith({
    Money? balance,
    List<Operation>? operations,
    bool? loading,
    ApiException? error,
    bool clearError = false,
  }) => WalletState(
    balance: balance ?? this.balance,
    operations: operations ?? this.operations,
    loading: loading ?? this.loading,
    error: clearError ? null : (error ?? this.error),
  );
}

class WalletCubit extends Cubit<WalletState> {
  WalletCubit(this._wallet) : super(const WalletState());

  static const _historyLimit = 50;

  final WalletRepository _wallet;

  /// Читает баланс и историю разом: после любой операции меняется и то,
  /// и другое, поэтому обновлять их порознь незачем.
  ///
  /// Повторный вызов во время загрузки игнорируется: вкладки оболочки
  /// живут одновременно и на старте просят обновление все сразу.
  Future<void> refresh() async {
    if (state.loading) return;
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final results = await Future.wait([
        _wallet.balance(),
        _wallet.operations(limit: _historyLimit),
      ]);
      emit(
        state.copyWith(
          balance: results[0] as Money,
          operations: results[1] as List<Operation>,
          loading: false,
        ),
      );
    } on ApiException catch (error) {
      emit(state.copyWith(loading: false, error: error));
    }
  }
}
