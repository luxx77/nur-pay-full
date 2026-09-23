import 'api_error_code.dart';

/// Ошибка от бэкенда или сети.
///
/// Текст для человека — на туркменском: он идёт прямо в интерфейс.
class ApiException implements Exception {
  const ApiException({
    required this.code,
    required this.message,
    this.statusCode,
  });

  const ApiException.network()
    : code = ApiErrorCode.network,
      message = 'no connection',
      statusCode = null;

  final String code;

  /// Техническое сообщение сервера — для логов.
  final String message;

  final int? statusCode;

  /// Сессия недействительна: дальше работать нельзя, нужен новый вход.
  bool get requiresLogout =>
      code == ApiErrorCode.userTypeMismatch ||
      code == ApiErrorCode.unauthorized;

  /// Нет связи с сервером.
  bool get isNetwork => code == ApiErrorCode.network;

  /// Что показать пользователю.
  String get userMessage => switch (code) {
    ApiErrorCode.network => 'Aragatnaşyk ýok. Soňrak synanyşyň.',
    ApiErrorCode.insufficientFunds => 'Balansda ýeterlik pul ýok',
    ApiErrorCode.codeAlreadyUsed => 'Kod nädogry ýa-da eýýäm ulanyldy',
    ApiErrorCode.qrExpired => 'Kodyň möhleti gutardy. Täze kod soraň.',
    ApiErrorCode.nonceUsed => 'Bu kod boýunça eýýäm tölendi',
    ApiErrorCode.amountExceedsMax => 'Möçber rugsat berlen çäkden ýokary',
    ApiErrorCode.invalidSignature => 'Kod nädogry',
    ApiErrorCode.notFound => 'Tapylmady',
    ApiErrorCode.forbidden => 'Bu amal siziň hasabyňyz üçin elýeterli däl',
    ApiErrorCode.userTypeMismatch => 'Hasap üýtgedi, täzeden giriň',
    _ => 'Näbelli ýalňyşlyk. Täzeden synanyşyň.',
  };

  @override
  String toString() => 'ApiException($code, $statusCode): $message';
}
