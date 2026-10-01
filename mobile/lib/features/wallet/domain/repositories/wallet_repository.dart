import '../../../../core/money.dart';
import '../entities/nur_pay_qr.dart';
import '../entities/operation.dart';
import '../entities/public_user.dart';
import '../entities/wallet_snapshot.dart';

/// Операции кошелька. Всё, что меняет деньги, возвращает проводки —
/// ровно те, что потом появятся в истории.
abstract interface class WalletRepository {
  /// Баланс и история разом — offline-first: без сети отдаёт последний
  /// сохранённый снимок вместо ошибки, если он есть.
  Future<WalletSnapshot> loadSnapshot({int limit});

  /// Операция целиком: основная проводка и, если она ваша, комиссия.
  Future<List<Operation>> operation(int id);

  /// Кто стоит за отсканированным постоянным QR.
  Future<PublicUser> userByQr(String publicQrUuid);

  /// Кто из этих номеров телефонов уже пользуется Nur Pay — для экрана
  /// «выбрать из контактов».
  Future<List<PublicUser>> lookupPhones(List<String> phones);

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
