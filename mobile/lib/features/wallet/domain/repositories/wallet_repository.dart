import '../../../../core/money.dart';
import '../entities/nur_pay_qr.dart';
import '../entities/operation.dart';
import '../entities/public_user.dart';

/// Операции кошелька. Всё, что меняет деньги, возвращает проводки —
/// ровно те, что потом появятся в истории.
abstract interface class WalletRepository {
  Future<Money> balance();

  Future<List<Operation>> operations({int limit, int offset});

  /// Операция целиком: основная проводка и, если она ваша, комиссия.
  Future<List<Operation>> operation(int id);

  /// Кто стоит за отсканированным постоянным QR.
  Future<PublicUser> userByQr(String publicQrUuid);

  Future<List<Operation>> transfer({
    required String recipientQrUuid,
    required Money amount,
  });

  Future<List<Operation>> activate(String code);

  /// Приём оплаты мерчантом по отсканированному коду юзера.
  Future<List<Operation>> acceptPayment({
    required PaymentQr qr,
    required Money amount,
  });
}
