import '../app_role.dart';

/// Кто сейчас работает в приложении.
///
/// [paymentSecret] подписывает платёжный QR и хранится только на
/// устройстве — в сеть он больше не уходит.
class Session {
  const Session({
    required this.userId,
    required this.role,
    required this.publicQrUuid,
    required this.paymentSecret,
    this.phone,
    this.displayName,
  });

  final String userId;
  final AppRole role;
  final String publicQrUuid;
  final String paymentSecret;
  final String? phone;
  final String? displayName;

  /// Имя для интерфейса: у мерчанта — название точки, у юзера — номер.
  String get title => displayName ?? phone ?? 'Nur Pay';

  Session copyWith({AppRole? role}) => Session(
    userId: userId,
    role: role ?? this.role,
    publicQrUuid: publicQrUuid,
    paymentSecret: paymentSecret,
    phone: phone,
    displayName: displayName,
  );

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'user_type': role.apiValue,
    'public_qr_uuid': publicQrUuid,
    'payment_secret': paymentSecret,
    'phone': phone,
    'display_name': displayName,
  };

  factory Session.fromJson(Map<String, dynamic> json) => Session(
    userId: json['user_id'] as String,
    role: appRoleFromApi(json['user_type'] as String),
    publicQrUuid: json['public_qr_uuid'] as String,
    paymentSecret: json['payment_secret'] as String,
    phone: json['phone'] as String?,
    displayName: json['display_name'] as String?,
  );
}
