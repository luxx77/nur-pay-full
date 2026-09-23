import '../../../../core/money.dart';
import '../../domain/entities/nur_pay_qr.dart';
import '../../domain/entities/operation.dart';
import '../../domain/entities/public_user.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_data_source.dart';
import '../models/operation_dto.dart';

class WalletRepositoryImpl implements WalletRepository {
  const WalletRepositoryImpl(this._remote);

  final WalletRemoteDataSource _remote;

  @override
  Future<Money> balance() async {
    final json = await _remote.balance();
    return Money(json['balance'] as int);
  }

  @override
  Future<List<Operation>> operations({int limit = 50, int offset = 0}) async =>
      OperationDto.listFrom(
        await _remote.operations(limit: limit, offset: offset),
      );

  @override
  Future<List<Operation>> operation(int id) async =>
      OperationDto.listFrom(await _remote.operation(id));

  @override
  Future<PublicUser> userByQr(String publicQrUuid) async {
    final json = await _remote.userByQr(publicQrUuid);
    return PublicUser(
      userId: json['user_id'] as String,
      isMerchant: json['user_type'] == 'merchant',
      displayName: json['display_name'] as String?,
      phone: json['phone'] as String?,
    );
  }

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
