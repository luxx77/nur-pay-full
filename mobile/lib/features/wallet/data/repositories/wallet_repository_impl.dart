import '../../../../core/money.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/nur_pay_qr.dart';
import '../../domain/entities/operation.dart';
import '../../domain/entities/public_user.dart';
import '../../domain/entities/wallet_snapshot.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_local_data_source.dart';
import '../datasources/wallet_remote_data_source.dart';
import '../models/operation_dto.dart';

class WalletRepositoryImpl implements WalletRepository {
  const WalletRepositoryImpl(this._remote, this._local);

  final WalletRemoteDataSource _remote;
  final WalletLocalDataSource _local;

  @override
  Future<WalletSnapshot> loadSnapshot({int limit = 50}) async {
    try {
      final results = await Future.wait([
        _remote.balance(),
        _remote.operations(limit: limit, offset: 0),
      ]);
      final balance = Money(results[0]['balance'] as int);
      // Комиссию в списках не показываем — она не отдельная операция
      // для пользователя, а часть суммы той, к которой относится.
      final operations = OperationDto.listFrom(
        results[1],
      ).where((op) => !op.isFee).toList();
      final updatedAt = DateTime.now();
      await _local.save(
        balance: balance,
        operations: operations,
        updatedAt: updatedAt,
      );
      return WalletSnapshot(
        balance: balance,
        operations: operations,
        updatedAt: updatedAt,
        isStale: false,
      );
    } on ApiException catch (error) {
      if (!error.isNetwork) rethrow;
      final cached = await _local.read();
      if (cached == null) rethrow;
      return WalletSnapshot(
        balance: cached.balance,
        operations: cached.operations,
        updatedAt: cached.updatedAt,
        isStale: true,
      );
    }
  }

  @override
  Future<List<Operation>> operation(int id) async =>
      OperationDto.listFrom(await _remote.operation(id));

  @override
  Future<PublicUser> userByQr(String publicQrUuid) async {
    final json = await _remote.userByQr(publicQrUuid);
    return _userFrom(json);
  }

  @override
  Future<List<PublicUser>> lookupPhones(List<String> phones) async {
    if (phones.isEmpty) return const [];
    final json = await _remote.lookupPhones(phones);
    final matches = json['matches'] as List<dynamic>? ?? const [];
    return matches
        .map((raw) => _userFrom(raw as Map<String, dynamic>))
        .toList();
  }

  PublicUser _userFrom(Map<String, dynamic> json) => PublicUser(
    userId: json['user_id'] as String,
    isMerchant: json['user_type'] == 'merchant',
    publicQrUuid: json['public_qr_uuid'] as String,
    displayName: json['display_name'] as String?,
    phone: json['phone'] as String?,
  );

  @override
  Future<List<Operation>> transfer({
    required String recipientQrUuid,
    required Money amount,
  }) async => OperationDto.listFrom(
    await _remote.transfer(recipientQrUuid: recipientQrUuid, amount: amount),
  );

  @override
  Future<List<Operation>> activate(String code) async =>
      OperationDto.listFrom(await _remote.activate(code));

  @override
  Future<List<Operation>> acceptPayment({
    required PaymentQr qr,
    required Money amount,
  }) async => OperationDto.listFrom(
    await _remote.acceptPayment(qr: qr, amount: amount),
  );
}
