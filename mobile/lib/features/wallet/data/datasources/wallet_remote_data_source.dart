import '../../../../core/money.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/nur_pay_qr.dart';

/// Голые вызовы API кошелька. Никакой логики — только маршруты и тела.
class WalletRemoteDataSource {
  const WalletRemoteDataSource(this._client);

  final ApiClient _client;

  Future<Map<String, dynamic>> me() => _client.get('/me');

  Future<Map<String, dynamic>> balance() => _client.get('/balance');

  Future<Map<String, dynamic>> userByQr(String publicQrUuid) =>
      _client.get('/users/by-qr/$publicQrUuid');

  Future<Map<String, dynamic>> operations({
    required int limit,
    required int offset,
  }) => _client.get('/operations', query: {'limit': limit, 'offset': offset});

  Future<Map<String, dynamic>> operation(int id) =>
      _client.get('/operations/$id');

  Future<Map<String, dynamic>> transfer({
    required String recipientQrUuid,
    required Money amount,
  }) => _client.post(
    '/transfers',
    body: {'recipient_qr_uuid': recipientQrUuid, 'amount': amount.minor},
  );

  Future<Map<String, dynamic>> activate(String code) =>
      _client.post('/activation-codes/activate', body: {'code': code});

  Future<Map<String, dynamic>> acceptPayment({
    required PaymentQr qr,
    required Money amount,
  }) => _client.post(
    '/merchant/payments',
    body: {
      'user_id': qr.userId,
      'max_amount': qr.maxAmount.minor,
      'nonce': qr.nonce,
      'hash': qr.hash,
      'amount': amount.minor,
    },
  );
}
