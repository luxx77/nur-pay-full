/// Роль, в которой открыто приложение.
///
/// * [AppRole.customer] — обычный пользователь, синяя схема;
/// * [AppRole.merchant] — торговая точка, зелёная схема.
///
/// Роль задаёт и цветовую схему, и состав вкладок.
enum AppRole { customer, merchant }

extension AppRoleX on AppRole {
  bool get isMerchant => this == AppRole.merchant;
  bool get isCustomer => this == AppRole.customer;

  /// Подпись роли в интерфейсе.
  String get label => isMerchant ? 'Söwda nokady' : 'Müşderi';

  /// Значение для заголовка `user_type`: на бэкенде роль клиента
  /// называется `user`, а не `customer`.
  String get apiValue => isMerchant ? 'merchant' : 'user';
}

/// Разбор роли из API. Системные счета в приложение не заходят.
AppRole appRoleFromApi(String value) =>
    value == 'merchant' ? AppRole.merchant : AppRole.customer;
