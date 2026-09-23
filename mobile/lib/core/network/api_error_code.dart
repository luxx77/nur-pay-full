/// Коды ошибок, которые возвращает бэкенд.
///
/// Решения принимаются по коду, а не по тексту: message — для логов.
abstract final class ApiErrorCode {
  static const badRequest = 'bad_request';
  static const notFound = 'not_found';
  static const internal = 'internal_error';
  static const unauthorized = 'unauthorized';
  static const forbidden = 'forbidden';

  /// Тип в заголовке не совпал с типом в базе — надо разлогинить.
  static const userTypeMismatch = 'user_type_mismatch';

  static const insufficientFunds = 'insufficient_funds';
  static const codeAlreadyUsed = 'code_already_used';
  static const qrExpired = 'qr_expired';
  static const nonceUsed = 'nonce_used';
  static const amountExceedsMax = 'amount_exceeds_max';
  static const invalidSignature = 'invalid_signature';

  /// Не от сервера: запрос не дошёл или оборвался.
  static const network = 'network_error';
}
