import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../../wallet/domain/entities/operation.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';

/// Операция целиком: основная проводка и, если она ваша, комиссия.
class OperationDetailsState {
  const OperationDetailsState({
    this.entries = const [],
    this.loading = true,
    this.error,
  });

  final List<Operation> entries;
  final bool loading;
  final ApiException? error;

  /// Основная проводка операции.
  Operation? get main =>
      entries.where((e) => !e.isFee).firstOrNull ?? entries.firstOrNull;

  /// Комиссия, если её платил тот, кто смотрит.
  Operation? get fee => entries.where((e) => e.isFee).firstOrNull;
}

class OperationDetailsCubit extends Cubit<OperationDetailsState> {
  OperationDetailsCubit(this._wallet) : super(const OperationDetailsState());

  final WalletRepository _wallet;

  Future<void> load(int id) async {
    emit(const OperationDetailsState());
    try {
      emit(
        OperationDetailsState(
          entries: await _wallet.operation(id),
          loading: false,
        ),
      );
    } on ApiException catch (error) {
      emit(OperationDetailsState(loading: false, error: error));
    }
  }
}
