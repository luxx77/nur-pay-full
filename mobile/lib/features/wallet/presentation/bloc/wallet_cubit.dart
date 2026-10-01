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
    this.updatedAt,
    this.stale = false,
  });

  /// `null`, пока баланс ни разу не загрузили.
  final Money? balance;

  final List<Operation> operations;
  final bool loading;
  final ApiException? error;

  /// Когда баланс и история были получены в последний раз — хоть с сервера,
  /// хоть из локального кеша. Отдельно от `error`, чтобы было что показать
  /// в бэннере «Aragatnaşyk ýok», даже когда сам запрос не падал.
  final DateTime? updatedAt;

  /// `true` — на экране сохранённый ранее снимок, а не свежий ответ сервера.
  final bool stale;

  bool get isEmpty => balance == null && operations.isEmpty;

  WalletState copyWith({
    Money? balance,
    List<Operation>? operations,
    bool? loading,
    ApiException? error,
    bool clearError = false,
    DateTime? updatedAt,
    bool? stale,
  }) => WalletState(
    balance: balance ?? this.balance,
    operations: operations ?? this.operations,
    loading: loading ?? this.loading,
    error: clearError ? null : (error ?? this.error),
    updatedAt: updatedAt ?? this.updatedAt,
    stale: stale ?? this.stale,
  );
}

class WalletCubit extends Cubit<WalletState> {
  WalletCubit(this._wallet) : super(const WalletState());

  static const _historyLimit = 50;

  final WalletRepository _wallet;

  /// Читает баланс и историю разом: после любой операции меняется и то,
  /// и другое, поэтому обновлять их порознь незачем.
  ///
  /// Без сети отдаёт последний сохранённый снимок вместо ошибки — это
  /// offline-first: падаем только если и сервер недоступен, и кеш пуст.
  ///
  /// Повторный вызов во время загрузки игнорируется: вкладки оболочки
  /// живут одновременно и на старте просят обновление все сразу.
  Future<void> refresh() async {
    if (state.loading) return;
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final snapshot = await _wallet.loadSnapshot(limit: _historyLimit);
      emit(
        state.copyWith(
          balance: snapshot.balance,
          operations: snapshot.operations,
          updatedAt: snapshot.updatedAt,
          stale: snapshot.isStale,
          loading: false,
        ),
      );
    } on ApiException catch (error) {
      emit(state.copyWith(loading: false, error: error, stale: false));
    }
  }
}
