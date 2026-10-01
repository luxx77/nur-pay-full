/// Пути маршрутов.
///
/// Вкладки живут в оболочках, сценарии открываются поверх них на корневом
/// навигаторе — так у каждого сценария свой стек, а нижняя панель не мигает
/// посреди оплаты.
abstract final class AppRoutes {
  /// Пока читаем сессию с устройства.
  static const splash = '/';

  // ── Вход ──────────────────────────────────────────────────────────────────
  static const phone = '/auth/phone';
  static const otp = '/auth/otp';
  static const pinCreate = '/auth/pin-create';

  /// Экраны входа — по ним проверяется, можно ли пускать дальше.
  static const authRoutes = {phone, otp, pinCreate};

  // ── Вкладки клиента ───────────────────────────────────────────────────────
  static const home = '/home';
  static const history = '/history';
  static const profile = '/profile';

  /// Шторка фильтра истории.
  static const historyFilter = '/history/filter';

  // ── Вкладки торговой точки ────────────────────────────────────────────────
  static const merchantHome = '/merchant';
  static const merchantHistory = '/merchant/history';
  static const merchantProfile = '/merchant/profile';

  // ── Оплата в магазине ─────────────────────────────────────────────────────
  static const payLimit = '/pay/limit';
  static const payQr = '/pay/qr';

  // ── Перевод ───────────────────────────────────────────────────────────────
  /// Перевод начинается со сканера или со списка контактов — получатель
  /// в обоих случаях определяется по его постоянному QR.
  static const transferScan = '/transfer/scan';
  static const transferContacts = '/transfer/contacts';
  static const transferAmount = '/transfer/amount';
  static const transferConfirm = '/transfer/confirm';
  static const transferSuccess = '/transfer/success';

  // ── Пополнение ────────────────────────────────────────────────────────────
  static const topUpMethod = '/topup/method';
  static const topUpCode = '/topup/code';
  static const topUpAgent = '/topup/agent';
  static const topUpSuccess = '/topup/success';

  // ── QR и операции ─────────────────────────────────────────────────────────
  static const myQr = '/qr/my';
  static const transaction = '/transaction';

  /// Чек конкретной операции.
  static String transactionOf(int id) => '$transaction?id=$id';

  // ── Касса ─────────────────────────────────────────────────────────────────
  static const merchantAmount = '/pos/amount';
  static const merchantScanAccept = '/pos/scan';
  static const merchantResult = '/pos/result';
  static const merchantLimitExceeded = '/pos/limit-exceeded';
}
